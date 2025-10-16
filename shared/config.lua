-- ======================================================================
--  Weather (Standalone) - Shared Config
--  Cleaned & optimized
-- ======================================================================

Config = {}

-- Allowed weather types (GTA V natives expect uppercase names).
-- See: https://docs.fivem.net/natives/?_0xFHASH (WEATHER related)
Config.AllowedWeathers = {
  'EXTRASUNNY', 'CLEAR', 'NEUTRAL', 'SMOG', 'FOGGY',
  'OVERCAST', 'CLOUDS', 'CLEARING', 'RAIN', 'THUNDER',
  'SNOW', 'BLIZZARD', 'SNOWLIGHT', 'XMAS', 'HALLOWEEN'
}

-- Default state at resource start
Config.DefaultWeather = 'EXTRASUNNY'
Config.DefaultHour    = 12
Config.DefaultMinute  = 0
Config.FreezeWeather  = false
Config.FreezeTime     = false

-- Command names
Config.Commands = {
  Weather    = 'weather',        -- /weather [type]
  FreezeWx   = 'freezewx',       -- /freezewx [on|off]
  Time       = 'settime',        -- /settime [hour] [minute]
  FreezeTime = 'freezetime',     -- /freezetime [on|off]
  GetState   = 'wxstate'         -- /wxstate
}

-- Optional: require ace permission to change settings. If false -> anyone can use.
-- Example ace: add_ace group.admin weather.manage allow
Config.RequireAce = true
Config.AceObject  = 'weather.manage'

-- Localized messages
Config.Locale = {
  Prefix        = '^3[Weather]^7 ',
  InvalidUsage  = 'Invalid usage.',
  InvalidWx     = 'Invalid weather type. Allowed: %s',
  AppliedWx     = 'Weather set to ^2%s^7.',
  FreezeOn      = 'Weather freeze: ^2ON^7.',
  FreezeOff     = 'Weather freeze: ^1OFF^7.',
  TimeSet       = 'Time set to ^2%02d:%02d^7.',
  TimeFreezeOn  = 'Time freeze: ^2ON^7.',
  TimeFreezeOff = 'Time freeze: ^1OFF^7.',
  NoPerms       = '^1You do not have permission.',
  CurrentState  = 'Wx: ^2%s^7 | FreezeWx: ^2%s^7 | Time: ^2%02d:%02d^7 | FreezeTime: ^2%s^7'
}
