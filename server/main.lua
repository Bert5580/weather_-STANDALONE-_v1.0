local resourceName = GetCurrentResourceName()

-- State is the source of truth on server, replicated to clients
local State = {
  weather     = nil,
  freezeWx    = false,
  hour        = 12,
  minute      = 0,
  freezeTime  = false
}

-- Safe helpers
local function clamp(n, min, max)
  n = tonumber(n or 0) or 0
  if n < min then return min end
  if n > max then return max end
  return n
end

local function hasPerms(src)
  if not Config.RequireAce then
    return true
  end
  -- allow console implicitly
  if src == 0 then
    return true
  end
  return IsPlayerAceAllowed(src, Config.AceObject)
end

local function normalizeWx(w)
  if type(w) ~= 'string' then return nil end
  local up = w:upper()
  for _, allowed in ipairs(Config.AllowedWeathers) do
    if up == allowed then
      return up
    end
  end
  return nil
end

local function broadcastState(target)
  local payload = {
    weather    = State.weather,
    freezeWx   = State.freezeWx,
    hour       = State.hour,
    minute     = State.minute,
    freezeTime = State.freezeTime
  }
  if target then
    TriggerClientEvent('weather:update', target, payload)
  else
    TriggerClientEvent('weather:update', -1, payload)
  end
end

local function log(msg)
  print(('[%s] %s'):format(resourceName, msg))
end

AddEventHandler('onResourceStart', function(res)
  if res ~= resourceName then return end
  State.weather   = normalizeWx(Config.DefaultWeather) or 'EXTRASUNNY'
  State.freezeWx  = (Config.FreezeWeather == true)
  State.hour      = clamp(Config.DefaultHour, 0, 23)
  State.minute    = clamp(Config.DefaultMinute, 0, 59)
  State.freezeTime= (Config.FreezeTime == true)

  log(('Started. Default Wx=%s, FreezeWx=%s, Time=%02d:%02d, FreezeTime=%s'):
      format(State.weather, tostring(State.freezeWx), State.hour, State.minute, tostring(State.freezeTime)))

  -- push to everyone connected
  broadcastState()
end)

AddEventHandler('playerJoining', function()
  local src = source
  if src and tonumber(src) then
    broadcastState(src)
  end
end)

-- /weather [type]
RegisterCommand(Config.Commands.Weather, function(src, args)
  if not hasPerms(src) then
    TriggerClientEvent('chat:addMessage', src, { args = { Config.Locale.Prefix, Config.Locale.NoPerms } })
    return
  end

  local typeArg = args[1]
  local normalized = normalizeWx(typeArg)
  if not normalized then
    TriggerClientEvent('chat:addMessage', src, { args = { Config.Locale.Prefix, Config.Locale.InvalidWx:format(table.concat(Config.AllowedWeathers, ', ')) } })
    return
  end

  if State.weather == normalized then
    TriggerClientEvent('chat:addMessage', src, { args = { Config.Locale.Prefix, ('Weather already %s.'):format(normalized) } })
    return
  end

  State.weather = normalized
  broadcastState()

  TriggerClientEvent('chat:addMessage', src, { args = { Config.Locale.Prefix, Config.Locale.AppliedWx:format(normalized) } })
  log(('Weather changed by %s to %s'):format(src == 0 and 'console' or ('player '..src), normalized))
end, false)

-- /freezewx [on|off]
RegisterCommand(Config.Commands.FreezeWx, function(src, args)
  if not hasPerms(src) then
    TriggerClientEvent('chat:addMessage', src, { args = { Config.Locale.Prefix, Config.Locale.NoPerms } })
    return
  end

  local val = tostring(args[1] or ''):lower()
  local newState = (val == 'on' or val == 'true' or val == '1')
  State.freezeWx = newState
  broadcastState()

  local msg = newState and Config.Locale.FreezeOn or Config.Locale.FreezeOff
  TriggerClientEvent('chat:addMessage', src, { args = { Config.Locale.Prefix, msg } })
  log(('FreezeWx set to %s by %s'):format(tostring(newState), src == 0 and 'console' or ('player '..src)))
end, false)

-- /settime [hour] [minute]
RegisterCommand(Config.Commands.Time, function(src, args)
  if not hasPerms(src) then
    TriggerClientEvent('chat:addMessage', src, { args = { Config.Locale.Prefix, Config.Locale.NoPerms } })
    return
  end

  if not args[1] or not args[2] then
    TriggerClientEvent('chat:addMessage', src, { args = { Config.Locale.Prefix, Config.Locale.InvalidUsage .. ' /'..Config.Commands.Time..' [hour 0-23] [minute 0-59]' } })
    return
  end

  local h = clamp(tonumber(args[1]), 0, 23)
  local m = clamp(tonumber(args[2]), 0, 59)

  State.hour   = h
  State.minute = m
  broadcastState()
  TriggerClientEvent('chat:addMessage', src, { args = { Config.Locale.Prefix, Config.Locale.TimeSet:format(h, m) } })
  log(('Time set by %s to %02d:%02d'):format(src == 0 and 'console' or ('player '..src), h, m))
end, false)

-- /freezetime [on|off]
RegisterCommand(Config.Commands.FreezeTime, function(src, args)
  if not hasPerms(src) then
    TriggerClientEvent('chat:addMessage', src, { args = { Config.Locale.Prefix, Config.Locale.NoPerms } })
    return
  end

  local val = tostring(args[1] or ''):lower()
  local newState = (val == 'on' or val == 'true' or val == '1')
  State.freezeTime = newState
  broadcastState()

  local msg = newState and Config.Locale.TimeFreezeOn or Config.Locale.TimeFreezeOff
  TriggerClientEvent('chat:addMessage', src, { args = { Config.Locale.Prefix, msg } })
  log(('FreezeTime set to %s by %s'):format(tostring(newState), src == 0 and 'console' or ('player '..src)))
end, false)

-- /wxstate
RegisterCommand(Config.Commands.GetState, function(src)
  local msg = Config.Locale.CurrentState:format(
    State.weather,
    tostring(State.freezeWx),
    State.hour, State.minute,
    tostring(State.freezeTime)
  )
  TriggerClientEvent('chat:addMessage', src, { args = { Config.Locale.Prefix, msg } })
end, false)

-- Provide suggestions (client can still disable, but common for chat resources)
if RegisterKeyMapping ~= nil and ExecuteCommand ~= nil then
  -- No key mappings for chat commands, but keep this as placeholder for custom binds if needed
end

-- Allow other resources to query state (export compatible)
exports('GetWeatherState', function()
  -- Return a copy to avoid accidental mutation
  return {
    weather    = State.weather,
    freezeWx   = State.freezeWx,
    hour       = State.hour,
    minute     = State.minute,
    freezeTime = State.freezeTime
  }
end)

-- Allow programmatic change by other scripts (with basic validation)
RegisterNetEvent('weather:set', function(newWx)
  local src = source
  if not hasPerms(src) then return end
  local normalized = normalizeWx(newWx)
  if not normalized then return end
  State.weather = normalized
  broadcastState()
  log(('Weather changed by event from %s to %s'):format(src == 0 and 'console' or ('player '..src), normalized))
end)
