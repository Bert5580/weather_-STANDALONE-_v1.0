local function applyWeather(wtype, transitionSeconds)
  -- Defensive defaults
  local wt = type(wtype) == 'string' and wtype or 'CLEAR'
  local t = tonumber(transitionSeconds) or 0
  if t < 0 then t = 0 end

  -- Clear previous overrides and persist the new type after blending
  ClearOverrideWeather()
  ClearWeatherTypePersist()

  SetWeatherTypeOverTime(wt, t + 0.0)
  if t > 0 then
    Wait((t * 1000) + 250)
  end
  SetWeatherTypeNowPersist(wt)

  -- Disable dynamic weather oscillation (keeps it locked)
  SetOverrideWeather(wt)
end

RegisterNetEvent('weather:setWeather', function(wtype, transitionSeconds)
  if not wtype or type(wtype) ~= 'string' then return end
  applyWeather(wtype, transitionSeconds)
end)

-- Request sync on player load and on resource (re)start
CreateThread(function()
  -- Slight delay to ensure network is ready
  Wait(500)
  TriggerServerEvent('weather:requestSync')
end)

AddEventHandler('onClientResourceStart', function(res)
  if res == GetCurrentResourceName() then
    Wait(500)
    TriggerServerEvent('weather:requestSync')
  end
end)

-- (Optional) client-side chat suggestion for convenience
CreateThread(function()
  -- Only works if default chat is running; harmless otherwise.
  local examples = 'Types: EXTRASUNNY, CLEAR, NEUTRAL, SMOG, FOGGY, OVERCAST, CLOUDS, CLEARING, RAIN, THUNDER, SNOW, BLIZZARD, SNOWLIGHT, XMAS, HALLOWEEN'
  TriggerEvent('chat:addSuggestion', '/weather', 'Set the global weather. '..examples, {
    { name = 'weather_type', help = examples },
    { name = 'transition_seconds (optional)', help = 'Blend duration in seconds (default from config.lua)' }
  })
end)
