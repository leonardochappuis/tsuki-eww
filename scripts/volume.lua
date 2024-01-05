local iconDir = "$HOME/.config/eww/images/icons/volume"
local json = require "scripts.json"

function getVolume ()
  local handle = io.popen("pamixer --get-volume")
  local line = handle:lines()
  local currentVolume = tonumber(line())
  return currentVolume
end

function getMicVolume ()
  local handle = io.popen("pamixer --default-source --get-volume")
  local line = handle:lines()
  local currentVolume = tonumber(line())
  return currentVolume
end

function getMute ()
  local handle = io.popen("pamixer --get-mute")
  local line = handle:lines()
  local mute = line()
  return mute
end

function getMicMute ()
  local handle = io.popen("pamixer --default-source --get-mute")
  local line = handle:lines()
  local mute = line()
  return mute
end

function getIcon (currentVolume)
  if (currentVolume == 0 ) then
		return "volume-mute.png"
	elseif ((currentVolume > 0) and (currentVolume <= 30)) then
		return "volume-low.png"
  elseif ((currentVolume > 30) and (currentVolume <= 60)) then
		return "volume-mid.png"
	elseif ((currentVolume > 60) and (currentVolume <= 100)) then
		return "volume-high.png"
  end
end

function getMicIcon (currentVolume)
  if (currentVolume == 0 ) then
		return "microphone-mute.png"
	else
    return "microphone.png"
  end
end

function getTextIcon (currentVolume)
  if (currentVolume == 0 ) then
		return ""
	elseif ((currentVolume > 0) and (currentVolume <= 30)) then
		return ""
  elseif ((currentVolume > 30) and (currentVolume <= 60)) then
		return "󰕾"
	elseif ((currentVolume > 60) and (currentVolume <= 100)) then
		return ""
  end
end

function getTextMicIcon (currentVolume)
  if (currentVolume == 0 ) then
		return ""
	else
    return ""
  end
end

function notify (type)
  if (type == 'mic') then
    local icon = getMicIcon(getMicVolume())
    io.popen('dunstify -h int:value:$(pamixer --default-source --get-volume) -h "string:x-dunst-stack-tag:volume_notif" -u low -i "'.. iconDir .. '/' .. icon .. '" "Mic-Level : $(pamixer --default-source --get-volume) %"')
  else
    local icon = getIcon(getVolume())
    io.popen('dunstify -h int:value:$(pamixer --get-volume) -h "string:x-dunst-stack-tag:volume_notif" -u low -i "'.. iconDir .. '/' .. icon .. '" "Volume : $(pamixer --get-volume) %"')
  end
end

if (arg[1] == 'set') then
  if (arg[2] == 'up') then
    if (arg[3] == 'mic') then    
      os.execute("pamixer --default-source -i 5")
    else
      os.execute("pamixer -i 5")
    end
  elseif (arg[2] == 'down') then
    if (arg[3] == 'mic') then
      os.execute("pamixer --default-source -d 5")
    else
      os.execute("pamixer -d 5")
    end
  end
  notify(arg[3])
elseif (arg[1] == 'get') then
  local volume = getVolume()
  local micVolume = getMicVolume()
  local volumeIcon = getTextIcon(volume)
  local micVolumeIcon = getTextMicIcon(micVolume)
  local muted = getMute()
  local micMuted = getMicMute()

  local decoded = {
    volume = volume,
    micVolume = micVolume,
    volumeIcon = volumeIcon,
    micVolumeIcon = micVolumeIcon,
    muted = muted,
    micMuted = micMuted
  }
  print(json.encode(decoded))
elseif (arg[1] == 'toggle') then
  if (arg[2] == 'mic') then
    local mutedMic = getMicMute()
    if (mutedMic == 'false') then
      os.execute('pamixer --default-source -m && notify-send -h string:x-canonical-private-synchronous:sys-notify -u low -i "'.. iconDir .. '/microphone-mute.png" "Microphone Switched OFF"')
    elseif (mutedMic == 'true') then
      os.execute('pamixer -u --default-source u && notify-send -h string:x-canonical-private-synchronous:sys-notify -u low -i "'.. iconDir .. '/microphone.png" "Microphone Switched ON"')
    end
  else
    local muted = getMute()
    if (muted == 'false') then
      os.execute('pamixer -m && notify-send -h string:x-canonical-private-synchronous:sys-notify -u low -i "' .. iconDir .. '/volume-mute.png" "Volume Switched OFF"')
    elseif (muted == 'true') then
      os.execute('pamixer -u && notify-send -h string:x-canonical-private-synchronous:sys-notify -u low -i "' .. iconDir .. '/volume-high.png" "Volume Switched ON"')
    end
  end

end


