Config = {}

-- Seconds to blend from current weather to the new one
Config.TransitionSeconds = 10

-- If true, allow console (server) to change weather even without ACE (always true for console anyway).
Config.AllowConsoleAlways = true

-- Valid weather types (case-insensitive). DO NOT remove keys; expand aliases in server.lua instead.
Config.ValidWeathers = {
  'EXTRASUNNY','CLEAR','NEUTRAL','SMOG','FOGGY','OVERCAST','CLOUDS','CLEARING',
  'RAIN','THUNDER','SNOW','BLIZZARD','SNOWLIGHT','XMAS','HALLOWEEN'
}
