local json = require "scripts.json"
local mysplit = require "scripts.split"
local cropString = require "scripts.crop_string"

function executeCallback(line)
    if (line == '') then
      print(json.encode({ status = "None" }))
      return true
    end
    outt = mysplit(line,'\023')
    player_name = outt[1]
    song_name =  outt[3]
    artist = outt[2]
    position = outt[4]
    duration = outt[5]
    status = outt[6]
    art = outt[7]
    if (duration == nil or position == nil) then
      return false
    end
    local totalDurationSeconds = timeToSeconds(duration)
    local currentPositionSeconds = timeToSeconds(position)
    local percentagePlayed = (currentPositionSeconds / totalDurationSeconds) * 100

    icon = " "
    if (song_name == nil or string.find(song_name,"0:00")) then
      return false	
    end
    if (status == 'Paused') then
	    icon = " "
    end
    if (player_name == 'spotify') then
    	info = { 
        artist = artist,
        song_name = song_name,
        --artist = cropString(artist, 20),
        --song_name = cropString(song_name, 20),
        status = status,
        position = position,
        duration = duration,
        percentage = percentagePlayed,
        total_duration = totalDurationSeconds,
        art = art
    	}
      if (artist == "Advertisement") then
        info.art = info.status
        info.status = info.duration
        info.duration = info.position
        info.position = info.song_name
        info.total_duration = timeToSeconds(info.duration)
        info.percentage = (timeToSeconds(info.position) / info.total_duration) * 100
      end
      print(json.encode(info))
    end
    return true
end

-- Function to convert time in the format mm:ss to seconds
function timeToSeconds(time)
  if (time == nil) then
    return 0
  end
  local minutes, seconds = time:match("(%d+):(%d+)")
  if (minutes == nil or seconds == nil) then
    return 0
  end
  return tonumber(minutes) * 60 + tonumber(seconds)
end

function main()
    while true do
        local handle = io.popen("playerctl metadata --format '{{ playerName }}\023{{ artist }}\023{{ title }}\023{{ duration(position) }}\023{{ duration(mpris:length) }}\023{{ status }}\023{{ mpris:artUrl }}' --player spotify --follow", "r")
        
        local closed = false

        for line in handle:lines() do
            local res = executeCallback(line)
            if not res then
                closed = true
                break
            end
        end

	local handle2 = io.popen("pkill -f playerctl")
  handle:close()
	handle2:close()
    end
end

main()
