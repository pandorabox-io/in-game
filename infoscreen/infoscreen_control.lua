local function global_write(key, value)
  digiline_send("mem", {command = "SET", name = key, value = value })
end

local function global_read(key)
  digiline_send("mem", {command = "GET", name = key})
end

local touch = {}
function touch:on_save(msg, player)
  -- this is called when touch screen form is submitted with "save" event
  -- should save  data submitted from touch screen to local memory
  mem = {
    event_name = msg.event_name or mem.event_name,
    start_date = msg.start_date or mem.start_date,
    end_date = msg.end_date or mem.end_date,
    contact = msg.contact or mem.contact,
    short_desc = msg.short_desc or mem.short_desc,
    long_desc = msg.long_desc or mem.long_desc,
  }
end

function touch:on_publish(msg, player)
  -- this is called when touch screen form is submitted with "publish" event
  -- should save  data submitted from touch screen to global memory
  self:on_save(msg, player)
  global_write("event_info", {
    event_name = msg.event_name or mem.event_name,
    start_date = msg.start_date or mem.start_date,
    end_date = msg.end_date or mem.end_date,
    contact = msg.contact or mem.contact,
    short_desc = msg.short_desc or mem.short_desc,
    long_desc = msg.long_desc or mem.long_desc,
  })
end

function touch:on_reset(msg, player)
  -- this is called when touch screen form is submitted with "reset" event
  -- should reset local memory and demo screens to current published state
  mem.io_pending_op = "on_receive_global_mem"
  global_read("event_info")
end

function touch:on_quit(msg, player)
  -- this is called when touch screen form is submitted with "reset" event
  -- should reset local memory and demo screens to current published state
end

function touch:on_receive_global_mem(msg)
  -- this is called when touch screen form is submitted with "reset" event
  -- should reset local memory and demo screens to current published state
  mem = {
    event_name = msg.event_name or mem.event_name,
    start_date = msg.start_date or mem.start_date,
    end_date = msg.end_date or mem.end_date,
    contact = msg.contact or mem.contact,
    short_desc = msg.short_desc or mem.short_desc,
    long_desc = msg.long_desc or mem.long_desc,
  }
end

function touch:handle_event(msg)
  local event = (msg.save and "save")
    or (msg.publish and "publish")
    or (msg.reset and "reset")
    or (msg.quit and "quit")
  self["on_" .. event](self, msg, msg.clicker)
end

local function on_receive_data(msg)
  local io_pending_op = mem.io_pending_op
  if io_pending_op then
    mem.io_pending_op = nil
    touch[io_pending_op](touch, msg)
  end
end

local function draw_touch()
  digiline_send("touch",{
    { command="clear" },{ command = "lock" },{
      label="Events & Contests global infoscreen controller",
      command="addlabel",
      X=0.7, W=1.2, Y=0.3, H=0.8,
    },{
      label="Short description for LCD",
      command="addtextarea",
      name="short_desc",
      default=mem.short_desc,
      W=2.6, H=1.4, X=1.2, Y=2.4,
    },{
      label="Long description for textline",
      command="addtextarea",
      name="long_desc",
      default=mem.long_desc,
      W=2.6, H=1.4, X=4, Y=2.4,
    },{
      label="Save",
      command="addbutton",
      name="save",
      X=3.2, W=1.6, Y=5.6, H=0.8,
    },{
      label="Save & Publish",
      command="addbutton",
      name="publish",
      X=4.8, W=1.6, Y=5.6, H=0.8,
    },{
      label="Reset",
      command="addbutton",
      name="reset",
      X=1.6, W=1.6, Y=5.6, H=0.8,
    },{
      label="End date",
      command="addfield",
      name="end_date",
      default=mem.end_date,
      W=2, H=0.8, X=3.1, Y=4.7,
    },{
      label="Start date",
      command="addfield",
      name="start_date",
      default=mem.start_date,
      W=2, H=0.8, X=1.1, Y=4.7,
    },{
      label="Contact name",
      command="addfield",
      name="contact",
      default=mem.contact,
      W=1.6, H=0.8, X=5.1, Y=4.7,
    },{
      label="Event name",
      command="addfield",
      name="event_name",
      default=mem.event_name,
      W=4.4, H=0.8, X=1.5, Y=1.5,
    },{X=7.18,label="Created with SX Digi labs Touch Designer",Y=8.11,command="addlabel"}
  })
end

local function draw_lcd()
  digiline_send("lcd", mem.short_desc)
end

local function draw_textline()
  digiline_send("textline", mem.long_desc)
end

if event.type == "digiline" then
  local msg = event.msg
  if event.channel == "touch" then
    touch:handle_event(msg)
  elseif event.channel == "mem" then
    on_receive_data(msg)
  end
elseif event.type == "program" then
  mem = {
    event_name = "Demo event",
    start_date = "",
    end_date = "",
    contact = "",
    short_desc = "This event demonstrates infoscreens usage for events",
    long_desc = 
"This event shows how to\n" ..
"use infoscreens control\n" ..
"to distribute information\n" ..
"about events around world",
  }
end

draw_touch()
draw_lcd()
draw_textline()
