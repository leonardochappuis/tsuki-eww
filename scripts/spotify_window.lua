local json = require "scripts.json"

local client_id = "b97e3a26e5f34d9c832ec64754b3ed89"
local client_secret = "29eb94dfccf8440fb4e7444c8f307d22"
local access_token = ''

local key = 'Yjk3ZTNhMjZlNWYzNGQ5YzgzMmVjNjQ3NTRiM2VkODk6MjllYjk0ZGZjY2Y4NDQwZmI0ZTc0NDRjOGYzMDdkMjI='
local searchUrl = "https://api.spotify.com/v1/search"

local char_to_hex = function(c)
  return string.format("%%%02X", string.byte(c))
end

local function urlencode(url)
  if url == nil then
    return
  end
  url = url:gsub("\n", "\r\n")
  url = url:gsub("([^%w ])", char_to_hex)
  url = url:gsub(" ", "+")
  return url
end

function getBase64Key()
  local combined = client_id .. ":" .. client_secret
  local handle = io.popen('echo -n "'.. combined ..'" | openssl base64')
  local b64 = ''
  for line in handle:lines() do
      b64 = b64 .. line
  end
  return b64
end

function getAccessToken()
  local base64 = getBase64Key()
  
  local handle = io.popen('curl -X "POST" -H "Authorization: Basic "' .. base64 ..' -d grant_type=client_credentials https://accounts.spotify.com/api/token')
  local line = handle:lines()
  local encoded = line()
  local decoded = json.decode(encoded)

  access_token = decoded.access_token
end

function search(term)
  local handle = io.popen('curl -H "Authorization: Bearer '.. access_token ..'" "https://api.spotify.com/v1/search?q='.. urlencode(term) .. '&type=track,artist,album,playlist&limit=5"')
  local package = ''
  for line in handle:lines() do
      package = package .. line
  end
  return package
end

-- function getPlaylists()
--   local handle = io.popen('curl -H "Authorization: Bearer '.. access_token ..'" "https://api.spotify.com/v1/me/playlists"')
--   local package = ''
--   for line in handle:lines() do
--       package = package .. line
--   end
--   return package
-- end

function writeSongSearchResults(result)
  local decoded = json.decode(result)

  local encodedz = json.encode(decoded.tracks.items)
  local file = io.open('cache/search_results.txt', 'w')
  if file then
      file:write(encodedz)
      file:close()
  else
      print("Error opening the file for writing.")
  end
  os.execute([[result=$(jq '.' ~/.config/eww/cache/search_results.txt) && eww update spotify_search_results="$result"]])
end

function writeArtistSearchResults(result)
  local decoded = json.decode(result)

  local encodedz = json.encode(decoded.artists.items)
  local file = io.open('cache/search_results.txt', 'w')
  if file then
      file:write(encodedz)
      file:close()
  else
      print("Error opening the file for writing.")
  end
  os.execute([[result=$(jq '.' ~/.config/eww/cache/search_results.txt) && eww update spotify_search_results_artists="$result"]])
end

function writeAlbumSearchResults(result)
  local decoded = json.decode(result)

  local encodedz = json.encode(decoded.albums.items)
  local file = io.open('cache/search_results.txt', 'w')
  if file then
      file:write(encodedz)
      file:close()
  else
      print("Error opening the file for writing.")
  end
  os.execute([[result=$(jq '.' ~/.config/eww/cache/search_results.txt) && eww update spotify_search_results_albums="$result"]])
end

function writePlaylistSearchResults(result)
  local decoded = json.decode(result)

  local encodedz = json.encode(decoded.playlists.items)
  local file = io.open('cache/search_results.txt', 'w')
  if file then
      file:write(encodedz)
      file:close()
  else
      print("Error opening the file for writing.")
  end
  os.execute([[result=$(jq '.' ~/.config/eww/cache/search_results.txt) && eww update spotify_search_results_playlists="$result"]])
end

getAccessToken()
if (arg[1] == 'search') then
  if (arg[2] == '' or arg[2] == nil) then
    print('error, no arg')
    return
  end
  print(arg[2])
  os.execute("eww update spotify_searching=true")
  local result = search(arg[2])
  local decoded = json.decode(result)
  local encoded = json.encode(decoded)

  writeSongSearchResults(result)
  writeArtistSearchResults(result)
  writeAlbumSearchResults(result)
  writePlaylistSearchResults(result)

  os.execute("eww update spotify_searching=false")
end

-- if (arg[1] == 'playlists') then
--   local result = getPlaylists()
--   print(result)
-- end