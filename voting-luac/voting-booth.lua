-- Backup voting results to network
-- service for disaster recovery.
-- SX
if event.type == "digiline" and event.channel == "config" then
  mem.backup_url = event.msg
end
local function encodechar(b)
        if b < 32 or b > 126 then
                return ""
        elseif (b>47 and b<58)or(b>64 and b<91)or(b>96 and b<123) then
                return string.char(b)
        else
                return string.format("%%%02X", b)
        end
end
local function urlencode(str)
        local res = ""
        for i=1,#str do
                res = res .. encodechar(str:byte(i))
        end
        return res
end
local function backup(name, value)
  if mem.backup_url then
    digiline_send("nic", mem.backup_url .. "/" .. urlencode(name) .. "/" .. urlencode(value))
  end
end

-- Countdown until voting system activation
-- SX

local function plural(value)
  return value > 1 and "s" or ""
end
local function fmtepoch(value)
  local s = value % 60
  local m = math.floor(value / 60) % 60
  local h = math.floor(value / 60 / 60) % 24
  local d = math.floor(value / 60 / 60 / 24)
  return string.format("%d day%s %d hour%s %d minute%s %d second%s", 
    d, plural(d), h, plural(h), m, plural(m), s, plural(s)
  )
end
local function countdown(value)
  return math.max(0, value - os.time())
end
local function show_countdown(remain, voting_active)
  digiline_send("touch",{
    {
      command="clear",
    },{
      label="Haunted House voting will start in:",
      command="addlabel",
      X=2.3, W=1.2, Y=1.5, H=0.8,
    },{
      label=fmtepoch(remain),
      command="addlabel",
      X=2.3, W=1.2, Y=2.3, H=0.8,
    },{
      label="Return",
      command="addbutton_exit",
      name="buttonexit1",
      W=1.6, H=0.8, X=3.2, Y=4,
    },{X=7.18,label="Created with SX Digi labs Touch Designer",Y=8.11,command="addlabel"}
  })
end

-- Public voting system by 6r1d
-- Uses SX's Digilabs Touch Designer and
-- Michal Kottman's sorted pairs implementation.

-- Sorted pairs from
-- https://stackoverflow.com/questions/15706270/
function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

local show_main_menu = function(remain)
    local menu = {
      {
        command="clear",
      },{
        label="Public voting system",
        name="voting_system_title",
        command="addlabel",
        X=3.6, W=1.2, Y=0.8, H=0.8,
      },{
        label="You can vote for anyone except yourself.",
        name="description_1",
        command="addlabel",
        X=0.8, W=1.2, Y=2, H=0.8,
      },{
        label="last vote will replace a previous one.",
        name="description_2",
        command="addlabel",
        X=0.8, W=1.2, Y=2.4, H=0.8,
      },{
        label=remain > 0 and "Voting ends in " .. fmtepoch(remain) or "Voting has ended",
        command="addlabel",
        X=5.3, W=1.2, Y=2, H=0.8,
      },{
        label="Results",
        name="btn_results",
        command="addbutton",
        X=5.2, W=1.6, Y=5.2, H=0.8,
      }, {X=6.3, label="SX Digi labs Touch Designer", Y=7.8, command="addlabel"}
    }
    if remain > 0 then
      table.insert(menu,{
        label="Vote",
        name="btn_show_vote_menu",
        command="addbutton",
        X=3.6, W=1.6, Y=5.2, H=0.8,
      })
    end
    digiline_send("touch", menu)
end

local show_vote_menu = function()
    digiline_send("touch",{
      {
        command="clear",
      },{
        label="Voting",
        name="label_title",
        command="addlabel",
        X=4.4, W=1.2, Y=0.8, H=0.8,
      },{
        command="addfield",
        label="Candidate:",
        name="field_candidate",
        default="",
        X=1.1, W=1.6, Y=2.4, H=0.8,
      },{
        label="Vote",
        name="btn_record_vote",
        command="addbutton",
        X=0.8, W=1.6, Y=3.2, H=0.8,
      },{
        label="Cancel",
        name="btn_return",
        command="addbutton",
        X=2.4, W=1.6, Y=3.2, H=0.8,
      }, {X=6.3, label="SX Digi labs Touch Designer", Y=7.8, command="addlabel"}
    })
end

local record_vote = function(user, candidate)
    backup(user, candidate)
    mem.votes[user] = candidate
    digiline_send("touch",{
      {
        command="clear",
      },{
        label="Thanks for voting",
        name="label_title",
        command="addlabel",
        X=3.6, W=1.2, Y=0.8, H=0.8,
      },{
        label="You voted for " .. candidate,
        name="label_desc",
        command="addlabel",
        X=0.8, W=1.2, Y=1.6, H=0.8,
      },{
        label="Return",
        name="btn_return",
        command="addbutton",
        X=0.8, W=1.6, Y=2.4, H=0.8,
      }, {X=6.3, label="SX Digi labs Touch Designer", Y=7.8, command="addlabel"}
    })
end

local invalidate_vote = function()
    digiline_send("touch",{
      {
        command="clear",
      },{
        label="You can't vote for yourself",
        name="label_title",
        command="addlabel",
        X=3.2, W=1.2, Y=2.8, H=0.8,
      },{
        label="Understood",
        name="btn_return",
        command="addbutton",
        X=4, W=1.8, Y=4.4, H=0.8,
      }, {X=6.3, label="SX Digi labs Touch Designer", Y=7.8, command="addlabel"}
    })
end

local dict_to_list = function(player_votes)
    local vote_list = {}
    -- Create a list of votes
    for voted, vote_cnt in spairs(player_votes, function(t,a,b) return t[b] < t[a] end) do
    -- for voted, vote_cnt in pairs(player_votes) do
        vote_list[#vote_list+1] = voted .. ": " .. vote_cnt
    end
    return vote_list
end

local show_stats = function()
    local vote_num = {}    
    -- Count a total number of votes
    for voter, voted in pairs(mem.votes) do
      if vote_num[voted] ~= nil then
        vote_num[voted] = vote_num[voted] + 1
      else
        vote_num[voted] = 1
      end
    end
    -- Convert a table with player's total votes to a list
    local vote_list = dict_to_list(vote_num)
    -- Refresh a touchscreen
    digiline_send("touch",{
      {
        command="clear",
      }, {
        selected_id=1,
        label="Contest results",
        listelements=vote_list,
        command="addtextlist",
        name="tl_contest_results",
        transparent=false,
       X=0.8, W=4.6, Y=0.8, H=3.8,
      }, {
        label="Return",
        name="btn_return",
        command="addbutton",
        X=0.8, W=1.6, Y=6.8, H=0.8,
      }, {X=6.3, label="SX Digi labs Touch Designer", Y=7.8, command="addlabel"}
    })
end

local start_epoch = 1603238400
local time_to_start = countdown(start_epoch)
local voting_ends = countdown(start_epoch + (20 * 60 * 60 * 24))

-- Handle LuaC Execute event
if event.type == "program" then
    -- Init votes table if it is empty
    if (mem.votes == nil) then
        mem.votes = {}
    end
    show_main_menu(voting_ends)
end

-- Handle buttons and inputs
if time_to_start > 0 then
    -- No voting yet, display countdown
    show_countdown(time_to_start)
    interrupt(1)
elseif event.type == "digiline" and event.channel == "touch" then
    -- Save clicker
    user = event.msg.clicker
    -- Show vote menu
    if (event.msg.btn_show_vote_menu) then
        if voting_ends > 0 then show_vote_menu() else show_main_menu(voting_ends) end
    end
    -- Performs a voting process
    if (voting_ends > 0 and event.msg.btn_record_vote ~= nil) then
        if (event.msg.field_candidate ~= user) then
            record_vote(user, event.msg.field_candidate)
        else
            invalidate_vote()
        end
    end
    -- Returns to main menu
    if (event.msg.btn_return ~= nil) then
        show_main_menu(voting_ends)
    end

    if (event.msg.btn_results ~= nil) then
        show_stats()
    end
end

if event.type == "digiline" and event.channel == "deletekey" and event.msg then
  mem.votes[event.msg] = nil
end

