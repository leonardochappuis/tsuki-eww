local key = "YOUR_KEY"
local id = "CITY_ID"
local unit = "metric"
local json = require "scripts.json"

handle = io.popen('curl -sf "http://api.openweathermap.org/data/2.5/weather?APPID="'.. key .. '"&id="' .. id .. '"&units="'.. unit ..'""')

for line in handle:lines() do
  local decoded = json.decode(line)
  
  decoded.main.temp = math.floor(decoded.main.temp)
  decoded.main.feels_like = math.floor(decoded.main.feels_like)
  decoded.main.temp_min = math.floor(decoded.main.temp_min)
  decoded.main.temp_max = math.floor(decoded.main.temp_max)

  local encoded = json.encode(decoded)
  print(encoded)
end

