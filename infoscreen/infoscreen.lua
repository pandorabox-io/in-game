local SCREEN_TYPE = "LCD"
--local SCREEN_TYPE = "textline"
local UPDATE_INTERVAL = 5

--
-- Data / display handler code, not to be changed unless debugging or developing
--

local LF, DESC_KEY, INFO
if SCREEN_TYPE == "textline" then
  LF = "\n"
  DESC_KEY = "long_desc"
  INFO = "\n More information\n at Minigames Hub"
else
  LF = " | "
  DESC_KEY = "short_desc"
  INFO = "More information at Minigames Hub"
end

local function get_text(info)
  if not mem.info then
    return "No active events"
  end
  if mem.stage == 1 then
    return info.event_name .. LF .. info.start_date .. " - " .. info.end_date .. LF .. info.contact
  elseif mem.stage == 2 then
    return info[DESC_KEY]
  elseif mem.stage == 3 then
    return INFO
  else
    return "Invalid stage variable"
  end
end

local function draw()
  digiline_send("lcd", get_text(mem.info))
end

if event.type == "digiline" and event.channel == "mem" then
  mem.info = event.msg
  draw()
elseif event.type == "interrupt" or event.type == "program" then
  mem.stage = mem.stage and ((mem.stage % 3) + 1) or 1
  if mem.stage == 1 then
    --digiline_send("mem", {command = "GET", name = "event_info"})
  else
    draw()
  end
end
interrupt(UPDATE_INTERVAL)
