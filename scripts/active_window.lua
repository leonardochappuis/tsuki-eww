local json = require "scripts.json"
local mysplit = require "scripts.split"
local cropString = require "scripts.crop_string"

function executeCallback(line)
  local stuff = json.decode(line)
  local titles = {}
  for i = 1, #stuff, 1 do
    local monitor = stuff[i]
    table.insert(titles, {})
    local window_title = monitor.title
    local normalized_title = string.gsub(window_title, '—', '-')

    if (string.find(normalized_title,'-') or string.len(window_title) > 30) then
      local normalized_title = string.gsub(window_title, '—', '-')
      local splitTitle = mysplit(normalized_title, '-')
      local lastPart = splitTitle[#splitTitle]
      if (lastPart == nil) then
        lastPart = ""
      end
      if (firstPart == nil) then
        firstPart = ""
      end
      splitTitle[#splitTitle] = nil
      local firstPart = table.concat(splitTitle, '-')
      local prettyTitle = ""
      if (firstPart ~= "" and lastPart ~= "") then
        prettyTitle = cropString(firstPart, 30) .. '-'.. lastPart
      end
      titles[i].title = prettyTitle
    else
      titles[i].title = window_title
    end
  end
  print(json.encode(titles))
end

function main()
    -- local hyprHandle = io.popen('hyprctl monitors -j | jq -r ".['..arg[1]..'].name"')
    -- local monitor = "DP-1"
    -- for line in hyprHandle:lines() do
    --   monitor = line
    -- end
    local handle = io.popen("hyprland-activewindow _")
    for line in handle:lines() do
        local res = executeCallback(line)
    end
end
main()