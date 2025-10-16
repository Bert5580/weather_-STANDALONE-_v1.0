# weather (Standalone) v1.0

Lightweight, optimized weather controller for FiveM. Synced server authority with robust validation, optional ACE-gated commands, and clean client application without heavy loops.

## Features
- **Synced weather** across all players via server authority.
- **Validated command** `/weather [type]` with whitelist (e.g., `EXTRASUNNY`, `CLEAR`, `RAIN`, `THUNDER`, `SNOW`, etc.).
- **Freeze weather** toggle: `/freezewx on|off` to lock the current weather and prevent transitions.
- **Time control**: `/settime [hour 0-23] [minute 0-59]` plus `/freezetime on|off`.
- **State query**: `/wxstate` prints the current weather/time/freezes.
- **ACE permissions** (optional) to restrict who can change state.
- **Safe nil-checks and bounds checks** everywhere.
- **No busy client loops**: state updates are event-driven.
- **Exports** for other resources: `exports('GetWeatherState')` from the server.
- **Clean, documented config** in `shared/config.lua`.

## Installation
1. Drop the folder into your `resources/` as `weather`.
2. Ensure it in your server.cfg **after** your chat resource:
   ```cfg
   ensure weather
   ```
3. (Optional) Grant ACE permission to a group or identifier:
   ```cfg
   add_ace group.admin weather.manage allow
   #add_principal identifier.steam:110000112345678 group.admin
   ```

## Commands
- `/weather [type]` — Set weather to an allowed type.
- `/freezewx [on|off]` — Freeze/unfreeze weather transitions.
- `/settime [hour] [minute]` — Set the in-game time.
- `/freezetime [on|off]` — Freeze/unfreeze time.
- `/wxstate` — Print current state.

> **Note**: If `Config.RequireAce = true`, only players with the `weather.manage` ACE may run the mutating commands.

## Configuration
All settings live in `shared/config.lua`:
- `AllowedWeathers` — Allowed list and input validation.
- Defaults: `DefaultWeather`, `DefaultHour`, `DefaultMinute`.
- Freeze flags: `FreezeWeather`, `FreezeTime`.
- Command names: `Config.Commands` if you want to rename routes (e.g., to `wx`).
- Permissions: `RequireAce` and `AceObject`.

## Performance
- No per-frame loops.
- No torrents of events.
- Client applies changes only when the server state changes.

## Compatibility
- Standalone; works with ESX/QBCore/others.
- Requires `chat` (or equivalent) for feedback messages.

## Troubleshooting
- **Nothing happens**: ensure resource is started and verify the chat is running. Check F8 for errors.
- **"Invalid weather type"**: use `/wxstate` to see allowed list printed in chat (also check `shared/config.lua`).
- **Permission denied**: set `Config.RequireAce = false` or add the ACE rule for your account or group.
