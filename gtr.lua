-- GTR
-- based on earthsea + GTR engine
-- guitar kind of thing
engine.name = 'gtr'
local MusicUtil = require "musicutil"

local g = grid.connect()
local note_list = {}
local midi_in_device

local screen_framerate = 15
local screen_refresh_metro
local MAX_NUM_VOICES = 16

local buttons_down = {false,false,false}

local vel_pattern = { 7 , 5 , 5 , 5 , 1 , 5 , 5 , 5  }
local vp_len = 5
local vel_ptr = 0

local clockdiv = 2

local vel = 1.0

local notelist = {}
local noteidx = 1

function init()
  
  midi_in_device = midi.connect(1)
  midi_in_device.event = midi_event
  
  -- Add params
  
  params:add{type = "number", id = "midi_device", name = "MIDI Device", min = 1, max = 4, default = 1, action = function(value)
    midi_in_device.event = nil
    midi_in_device = midi.connect(value)
    midi_in_device.event = midi_event
  end}
  
  local channels = {"All"}
  for i = 1, 16 do table.insert(channels, i) end
  params:add{type = "option", id = "midi_channel", name = "MIDI Channel", options = channels}
  
  if g.device then gridredraw() end
  screen_refresh_metro = metro.init{ 
  event = function(stage)
		gridredraw()
    redraw()
  end ,
  time = 1 / screen_framerate }
  screen_refresh_metro:start()
  
  clock.run(do_bar)
  
end

function do_bar()
  clock.sync(4)
  clock.run(do_step)
end

function do_step()
  while true do
    vel_ptr = vel_ptr + 1
    if vel_ptr > vp_len then 
      vel_ptr = 1
    end
    if noteidx > #notelist then
        noteidx = 1
    end
    if #notelist > 0 then 
      vel = (vel_pattern[vel_ptr] - 1.0) / 6.0
      if vel > 0 then
        note_on(notelist[noteidx].note, 0 )
      end
      noteidx = noteidx + 1
    end
    clock.sync(1/clockdiv)
  end
end


-- MIDI input
function midi_event(data)
  local msg = midi.to_msg(data)
  local channel_param = params:get("midi_channel")
  
  if channel_param == 1 or (channel_param > 1 and msg.ch == channel_param - 1) then
    
    -- Note off
    if msg.type == "note_off" then
      -- note_off(msg.note)
      for idx = 1,#notelist do 
        if notelist[idx].note == msg.note then
          table.remove(notelist,idx)
          break
        end
      end
      --table.insert(notelist,#notelist + 1, { note=msg.note, vel=msg.vel / 127 })
    
    -- Note on
    elseif msg.type == "note_on" then
      -- note_on(msg.note, msg.vel / 127)
      table.insert(notelist,#notelist + 1, { note=msg.note, vel=msg.vel / 127 })
      
      
    -- Key pressure
    -- elseif msg.type == "key_pressure" then
    --   set_pressure(msg.note, msg.val / 127)
      
    -- Channel pressure
    -- elseif msg.type == "channel_pressure" then
    --    set_pressure_all(msg.val / 127)
      
    -- Pitch bend
    elseif msg.type == "pitchbend" then
      local bend_st = (util.round(msg.val / 2)) / 8192 * 2 -1 -- Convert to -1 to 1
      local bend_range = params:get("bend_range")
      -- set_pitch_bend_all(bend_st * bend_range)
      
    -- CC
    elseif msg.type == "cc" then
      -- Mod wheel
      if msg.cc == 1 then
        -- set_timbre_all(msg.val / 127)
      end
      
    end
  
  end
  
end



function note_on(note,vel)
  local hz = MusicUtil.note_num_to_freq(note)
  engine.note(hz, vel * 0.2 )
end

function note_off(note)
  
end

function g.key(x, y, z)
  --print("key",x,y,z)
  if x == 16 and z == 1 then 
    clockdiv = 9 - y 
  elseif y == 8 and z == 1 and x <= 8 then 
    vp_len = x
  elseif y < 8 and z == 1 and x <= 8 then 
    vel_pattern[x] = 8 - y
  end
	-- play_notes(x,y,z)
  gridredraw()
end

function gridredraw()
  g:all(0)
  draw_vel_pattern()
  g:led(16,9 - clockdiv,8)
  g:refresh()
end

function enc(n,delta)
  if n == 1 then
    mix:delta("output", delta)
  end
end

function key(n,z)
  
end

function redraw()
  screen.clear()
  screen.aa(0)
  screen.line_width(1)
	screen.move(100,10)
  screen.text("play")
  screen_playnotes()
  screen.update()
end



function screen_playnotes()
	

end

function draw_vel_pattern()
  g:led(vp_len,8,5)
  g:led(vel_ptr,8,10)
  for idx = 1,8 do 
    for ydx = 1,vel_pattern[idx] do 
      if idx <= vp_len then 
        g:led(idx,8 -  ydx , 4 )
      else 
        g:led(idx,8 -  ydx , 2 )
      end
    end
  end
end

function play_notes(x,y,z)
  
end

function makenote(state,id,hz,x,y,n) 

end

function log2(n)
  return math.log(n) / math.log(2)
end

function grid_note(e)
  
  gridredraw()
end



function cleanup()
	print("Done")
end
