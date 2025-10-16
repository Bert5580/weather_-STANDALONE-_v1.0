local currentWeather = 'CLEAR'
local lastChangeAt = os.time()

-- Quick lookup set for valid types
local valid = {}
for _, w in ipairs(Config.ValidWeathers or {}) do
  valid[w] = true
end

-- Aliases (accept lowercase keys; we normalize input before lookup)
local aliases = {
  sunny = 'EXTRASUNNY',
  extrasunny = 'EXTRASUNNY',
  clear = 'CLEAR',
  neutral = 'NEUTRAL',
  smog = 'SMOG',
  fog = 'FOGGY',
  foggy = 'FOGGY',
  overcast = 'OVERCAST',
  clouds = 'CLOUDS',
  cloudy = 'CLOUDS',
  clearing = 'CLEARING',
  rain = 'RAIN',
  rainy = 'RAIN',
  thunder = 'THUNDER',
  storm = 'THUNDER',
  thunderstorm = 'THUNDER',
  snow = 'SNOW',
  blizzard = 'BLIZZARD',
  snowlight = 'SNOWLIGHT',
  light_snow = 'SNOWLIGHT',
  lightsnow = 'SNOWLIGHT',
  xmas = 'XMAS',
  christmas = 'XMAS',
  halloween = 'HALLOWEEN'
}

local function normalizeWeather(input)
  if type(input) ~= 'string' then return nil end
  local s = input:gsub('%s+', ''):gsub('%-', '_')
  local lower = s:lower()
  if aliases[lower] then return aliases[lower] end
  local upper = s:upper()
  if valid[upper] then return upper end
  return nil
end

local function hasPerm(source)
  if source == 0 then
    return Config.AllowConsoleAlways ~= false
  end
  return IsPlayerAceAllowed(source, Config.AcePermission or 'weather.admin')
end

local function broadcastWeather(wtype, transition)
  currentWeather = wtype
  lastChangeAt = os.time()
  TriggerClientEvent('weather:setWeather', -1, currentWeather, transition or Config.TransitionSeconds or 10)
  print(('[weather] Global weather set to %s (transition %ss)'):format(currentWeather, tostring(transition)))
end

RegisterNetEvent('weather:requestSync', function()
  local src = source
  if src and src > 0 then
    TriggerClientEvent('weather:setWeather', src, currentWeather, 0)
  end
end)

RegisterCommand('weather', function(source, args)
  if not args or not args[1] then
    if source == 0 then
      print('Usage: /weather [type]. Valid: ' .. table.concat(Config.ValidWeathers, ', '))
    else
      TriggerClientEvent('chat:addMessage', source, {
        args = {'^3WEATHER', 'Usage: /weather [type].'}
      })
    end
    return
  end

  local desired = normalizeWeather(args[1])
  if not desired then
    local msg = 'Invalid weather type. Valid: ' .. table.concat(Config.ValidWeathers, ', ')
    if source == 0 then print('[weather] ' .. msg) else
      TriggerClientEvent('chat:addMessage', source, { args = {'^1WEATHER', msg} })
    end
    return
  end

  local transition = tonumber(args[2]) or Config.TransitionSeconds or 10
  if transition < 0 then transition = 0 end
  broadcastWeather(desired, transition)
end, false)

-- Optional: print when resource starts
AddEventHandler('onResourceStart', function(res)
  if res ~= GetCurrentResourceName() then return end
  print('[weather] Resource started. Current weather: ' .. tostring(currentWeather))
end)
