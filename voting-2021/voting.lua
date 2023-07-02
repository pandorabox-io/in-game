--	########
--	Ingame Voting System
--	for Pandorabox Minetest server
--
--	Usage:
--	Connect:
--	a keyboard to enter the security key, channel: key
--	a touchscreen for voting (Best with a ratelimiter 10/s only to the LUAc), channel: ts
--	a NIC for connection to the voting bot, channel: nic
--	a digiline:lcd for feedback, channel mon
--	
--	Enter security code on keyboard
--	Adjust digiline channels and settings
--	Vote on ;)
--	########


-- ########
-- Interrupt digiline message queue based on Chi's
-- ########

if not mem.mesq then mem.mesq = {} end

function dgl_enqueue(in_chan, in_mes)
	table.insert(mem.mesq, {chan = in_chan, mes = in_mes})
end

function dgl_dequeue()
	if #mem.mesq ~= 0 then
		digiline_send(mem.mesq[1].chan, mem.mesq[1].mes)
		table.remove(mem.mesq, 1)
	end
end

if event.type == "program" then
	mem.mesq = {}
	mem.intr_dequeue = 0
	interrupt(heat)
elseif event.type == "interrupt" then
	dgl_dequeue()
	interrupt(heat)
	return
end


-- ########
-- Settings
-- ########
local topics = {
	"Cast 1 point",
	"Cast 3 points",
	"Cast 5 points"
}

local choices = {
	"Anime Santa",
	"Tree",
	"Snowman",
	"Snoopy Santa",
	"Snowflake",
	"Merry Christmas",
	"Gremlin Santa",
	"Australian Christmas"
}

local keyboard_channel = "key"
local touchscreen_channel = "ts"
local feedback_monitor_channel = "mon"
local network_interface = "nic"

local button_marker = "*"

-- ########
-- Functionality
-- ########

function table.contains(table, value)
  for key, v in pairs(table) do
    if v == value then
      return key
    end
  end
  return false
end

if event.type == "program" then
	-- Table geometry
	local ts_params = {
		x = {min = 0.5, max = 12.5},
		y = {min = 0.5, max = 9.5}
	}
	ts_params.x.extend = (ts_params.x.max - ts_params.x.min) / (#topics + 1)
	ts_params.y.extend = (ts_params.y.max - ts_params.y.min) / (#choices + 1)

	ts_params.x.start = {ts_params.x.min}
	for i, v in ipairs(topics) do
		table.insert(ts_params.x.start, ts_params.x.start[#ts_params.x.start] + ts_params.x.extend)
	end
	ts_params.y.start = {ts_params.y.min}
	for j, w in ipairs(choices) do
		table.insert(ts_params.y.start, ts_params.y.start[#ts_params.y.start] + ts_params.y.extend)
	end

	-- Draw touchscreen
	local ts_msg = {
		{command = "clear"},
		{command = "realcoordinates", enabled = true},
		{command = "addlabel", label = "Choices ~ Topics", X=ts_params.x.start[1],Y=ts_params.y.start[1] + 1/2 * ts_params.y.extend}
	}
	for i, v in ipairs(topics) do
		table.insert(ts_msg, {command = "addlabel", label = v, X=ts_params.x.start[i+1],Y=ts_params.y.start[1] + 1/2 * ts_params.y.extend})
	end
	for j, w in ipairs(choices) do
		table.insert(ts_msg, {command = "addlabel", label = w, X=ts_params.x.start[1],Y=ts_params.y.start[j+1] + 1/2 * ts_params.y.extend})
	end
	dgl_enqueue(touchscreen_channel, ts_msg)

	for i, v in ipairs(topics) do
		ts_msg = {}
		for j, w in ipairs(choices) do
			table.insert(ts_msg, {
				command = "addbutton",
				name = tostring(i) .. "_" .. tostring(j),
				label = button_marker,
				X = ts_params.x.start[i+1],
				Y = ts_params.y.start[j+1],
				W = ts_params.x.extend,
				H = ts_params.y.extend
			})
		end
		dgl_enqueue(touchscreen_channel, ts_msg)
	end
-- Add key - persistent, enter after LUAc placement
elseif event.channel == keyboard_channel then
	mem.key = event.msg
-- Cast vote on click
elseif event.channel == touchscreen_channel then
	if event.msg.clicker ~= nil then
		local button_name = table.contains(event.msg, button_marker)
		if button_name then
			local i_separator = button_name:find("_", nil, true)
			local topic = tonumber(button_name:sub(1, i_separator - 1))
			local choice = tonumber(button_name:sub(i_separator + 1))
			digiline_send(feedback_monitor_channel, event.msg.clicker .. "\n" .. topics[topic] .. "\nfor " .. choices[choice])
			digiline_send(network_interface, "https://pandorabox.io/api/vote?key=" .. mem.key .. "&id=" .. tostring(topic - 1) .. "&choice=" .. tostring(choice - 1) .."&uid=" .. event.msg.clicker)
		end
	end
end

-- MIT License
-- 
-- Copyright (c) 2021 Florian Finke
-- 
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
