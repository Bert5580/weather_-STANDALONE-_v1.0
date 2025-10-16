local CURRENT = {
  weather    = nil,
  freezeWx   = false,
  hour       = 12,
  minute     = 0,
  freezeTime = false
}

local function safeSetWeather(wType, freeze)
  -- Validate
  if type(wType) ~= 'string' or wType == '' then return end
  SetWeatherTypeOverTime(wType, 0.5)
  Citizen.Wait(600)
  SetWeatherTypeNowPersist(wType)
  SetWeatherTypeNow(wType)
  SetOverrideWeather(wType)

  if freeze then
    SetWeatherTypePersist(wType)
  else
    ClearOverrideWeather()
    ClearWeatherTypePersist()
  end
end

local function safeSetTime(hour, minute, freeze)
  hour = math.max(0, math.min(23, tonumber(hour) or 0))
  minute = math.max(0, math.min(59, tonumber(minute) or 0))

  NetworkClockTimeOverride(hour, minute, 0, freeze)
  if freeze then
    PauseClock(true)
  else
    PauseClock(false)
  end
end

RegisterNetEvent('weather:update', function(payload)
  if type(payload) ~= 'table' then return end

  local wx     = payload.weather or CURRENT.weather or 'EXTRASUNNY'
  local frzWx  = payload.freezeWx == true
  local hour   = tonumber(payload.hour) or CURRENT.hour or 12
  local minute = tonumber(payload.minute) or CURRENT.minute or 0
  local frzT   = payload.freezeTime == true

  CURRENT.weather    = wx
  CURRENT.freezeWx   = frzWx
  CURRENT.hour       = hour
  CURRENT.minute     = minute
  CURRENT.freezeTime = frzT

  -- Apply
  safeSetWeather(wx, frzWx)
  safeSetTime(hour, minute, frzT)
end)

-- On first tick, request a state push (the server automatically sends on join,
-- but in case of timing issues, we can wait a bit)
CreateThread(function()
  Wait(2500)
  -- no-op: server pushes automatically on playerJoining
end)
