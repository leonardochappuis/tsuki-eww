local json = require "scripts.json"
local mysplit = require "scripts.split"
local cropString = require "scripts.crop_string"

function executeCallback(line, monitor)
  print("monitor "..monitor)
  print(line)
end

workspaces = {}

function main()
    local handle = io.popen("hyprland-workspaces DP-1")
    table.insert(workspaces, {})
    local handle2 = io.popen("hyprland-workspaces HDMI-A-1")
    table.insert(workspaces, {})
    local co1 = coroutine.create(function ()
          workspaces[1] = {text = "x"}
      end
    )    
    local co2 = coroutine.create(function ()
        workspaces[2] = {text = "y"}
      end
    )    
    while(true) do
      coroutine.resume(co1)
      coroutine.resume(co2)
      print(workspaces[1].text)
      print(workspaces[2].text)
    end
end
main()