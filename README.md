<p align="center"><img src=".github/dps-logo.svg" alt="DelPerroSands" width="360"></p>

# dps-weatherbridge

Lets scripts written for qb-weathersync or Renewed-Weathersync work with night_natural_disasters.

## Status

Not running on DelPerroSands since 12 November 2026. This fix is now part of `dps-fixes`, which
carries the same code along with the server's other small fixes. Run this script or `dps-fixes`,
not both: running both does the same job twice.

## What it is for

Many scripts expect qb-weathersync or Renewed-Weathersync. They fire qb-weathersync events to
pause the weather indoors, and they read `GlobalState.weather` to learn if it is raining.
night_natural_disasters answers neither. Without a bridge, rain falls inside houses, the sun
shines inside rooms with no windows, and scripts that react to weather see nothing. This script
sits between the two and translates.

## What it does

- **Indoor light.** When a script fires `qb-weathersync:client:DisableSync`, that player gets
  no rain and a held hour (23:00 unless the script asks for another). `EnableSync` gives the
  world clock and the rain back. Only that player is changed.
- **Stacking.** If two scripts pause at once (a room inside a house), the light stays until
  both have resumed. A script can ask for its own hour, and the newest request wins.
- **Weather state.** Every 30 seconds it reads the current weather from
  night_natural_disasters and writes it to `GlobalState.weather` as `{ weather = 'RAIN' }`.
- **Admin controls.** It answers `qb-weathersync:server:setWeather`, `setTime` and
  `toggleBlackout` and passes them to night_natural_disasters.

## On its own, and with other scripts

**On its own.** The indoor light part works with no weather script at all. The weather state
and the admin controls need night_natural_disasters. If it is not running, those parts do
nothing and print no errors.

**With a paid weather script (night_natural_disasters).** This is the script it was made for.
It only calls that script's exports (`GetCurrentWeather`, `SetWeather`, `SetTime`,
`ToggleBlackout`, `PauseSynchronization`). It does not touch its files, so an update does not
undo the bridge unless those export names change.

**With a paid housing script (qs-housing, qs-motorhome, qs-yacht, qs-motels-creator).** These
fire the qb-weathersync pause events when a player goes inside. The player gets a dry, evenly
lit interior with no sun through the walls.

**With qbx_core.** Character creation fires the same pause events, so the creation room is lit
the same way.

**With [dps-studio](https://github.com/DaemonAlex/dps-studio).** Studio rooms use the pause
events too. The photo booth and the flyover ask for hour 12, so pictures are taken in daylight.

**With a paid police script (wasabi_police).** Its Renewed weather bridge reads
`GlobalState.weather`. With this running, rain washes evidence away as it did under Renewed.

**With [dps-ainpcs](https://github.com/DaemonAlex/dps-ainpcs).** NPCs read the same state, so
they know what the weather is when they talk.

**With a paid admin menu (wasabi_adminmenu).** Set its weather system to `qb`. The weather,
time and blackout buttons then drive night_natural_disasters.

**With dps-fixes.** dps-fixes carries the same two files. Run dps-weatherbridge or dps-fixes.
Do not run both.

## Requirements

- night_natural_disasters (paid), for the weather state and admin controls.
- No framework needed.

## Install

1. Remove or stop qb-weathersync and Renewed-Weathersync.
2. Put the folder in your resources and add `ensure dps-weatherbridge` after
   `night_natural_disasters`.
3. In scripts that let you choose a weather system, choose `qb` or `renewed`.

## Configuration

There is no config file. The values are at the top of the two files.

| Setting | File | Meaning |
|---|---|---|
| `ND` | both | The name of the weather resource. `night_natural_disasters`. |
| `REFRESH_MS` | `server.lua` | How often the weather state is refreshed. 30000 ms. |
| Default hour | `client.lua` | The hour held indoors when a script does not ask for one. 23. |

Events it answers:

| Event | Side | Meaning |
|---|---|---|
| `qb-weathersync:client:DisableSync` | client | Start the indoor light. Optional hour. |
| `qb-weathersync:client:EnableSync` | client | End it. Pass the same hour you started with. |
| `qb-weathersync:server:setWeather` | server | Set the weather type. |
| `qb-weathersync:server:setTime` | server | Set hour and minute. |
| `qb-weathersync:server:toggleBlackout` | server | Toggle the blackout. |

## Recent changes

- **12 November 2026.** Taken off the DelPerroSands server. `dps-fixes` does this job now.
- **12 November 2026.** README added.
- **25 October 2026.** First commit, as it runs on DelPerroSands.
- **18 October 2026.** The weather script is no longer paused indoors, because it held the
  clock at 18:00 while paused. The night is now held for the player each frame. A script can
  also ask for its own hour.
- **30 September 2026.** Indoor players see night and no rain, so the sun does not shine inside
  windowless rooms.
- **27 September 2026.** Script added when Renewed-Weathersync was retired.

## Author

Made by [DaemonAlex](https://github.com/DaemonAlex) for DelPerroSands.

## Other DPS scripts

All of these are made for DelPerroSands and run together on one Qbox server. Each one works on
its own. The ones marked "pairs with" do more when both are running.

| Script | What it does |
|---|---|
| [dps-inventory](https://github.com/DaemonAlex/dps-inventory) | The inventory: ox_inventory with equipment slots, backpacks, armour plates and a self status panel, in the DelPerroSands colours. |
| [dps-medical](https://github.com/DaemonAlex/dps-medical) | Patient records, illness and diagnostic tests. A companion to wasabi_ambulance. Pairs with dps-inventory: symptoms and diagnoses show on the status panel. |
| [dps-insurance](https://github.com/DaemonAlex/dps-insurance) | Ties m-Insurance into the MDT, impound, hospital and medical chart, and raises premiums for incidents other scripts report. Pairs with dps-medical and dps-fuel. |
| [dps-studio](https://github.com/DaemonAlex/dps-studio) | Build rooms, doors and portals in game from one panel (`/studio`), with owners and managers so staff do not have to support them. |
| [dps-shops](https://github.com/DaemonAlex/dps-shops) | Shop clerks who greet, react to robberies, talk back through dps-ainpcs and remember trouble, plus player-owned stores with delivery runs. Pairs with dps-ainpcs. |
| [dps-fleet](https://github.com/DaemonAlex/dps-fleet) | Vehicle browser and workshop on one panel: extras, liveries and mods for emergency vehicles. |
| [dps-parking](https://github.com/DaemonAlex/dps-parking) | Parking with valet, impound, violations and reserved spots. |
| [dps-vehiclepersistence](https://github.com/DaemonAlex/dps-vehiclepersistence) | Vehicles stay where they were parked. Pairs with dps-parking. |
| [dps-towjob](https://github.com/DaemonAlex/dps-towjob) | Queue-based tow job with jg-mechanic integration. |
| [dps-services](https://github.com/DaemonAlex/dps-services) | Request a tow and follow it live on the lb-phone and lb-tablet. Pairs with dps-towjob. |
| [dps-autoshops](https://github.com/DaemonAlex/dps-autoshops) | Self-service repair shops when no mechanic is on duty. |
| [dps-cityworker](https://github.com/DaemonAlex/dps-cityworker) | City infrastructure job and career. |
| [dps-ainpcs](https://github.com/DaemonAlex/dps-ainpcs) | NPCs you can talk to, with trust, quests and intel. Other scripts can make their own NPCs talk (dps-shops clerks). |
| [dps-badpeds](https://github.com/DaemonAlex/dps-badpeds) | Police interaction with NPCs: stops, arrests, intel and jail records. |
| [dps-gangwars](https://github.com/DaemonAlex/dps-gangwars) | Ambient gang NPCs, territory population and war reinforcements. |
| [dps-rotations](https://github.com/DaemonAlex/dps-rotations) | Moves dealers, harvests and other spots on a fixed schedule. |
| [dps-trains](https://github.com/DaemonAlex/dps-trains) | The train system. Pairs with dps-trains-stock, dps-traintools and dps-transitapp. |
| [dps-transitapp](https://github.com/DaemonAlex/dps-transitapp) | Live train arrival boards on the lb-phone. |
| [dps-faceplant](https://github.com/DaemonAlex/dps-faceplant) | City help, reports and staff tools on the lb-phone and lb-tablet. |
| [dps-chat](https://github.com/DaemonAlex/dps-chat) | A command box for voice-only servers. No chat feed. |
| [dps-filmmode](https://github.com/DaemonAlex/dps-filmmode) | One key hides every HUD layer and gives a smooth free camera for recording. |
| [dps-fuel](https://github.com/DaemonAlex/dps-fuel) | Gas station drive-offs for the ox_fuel nozzle: ripped hose, pump fire, station camera and a police call, by odds. Pairs with dps-insurance. |
| [dps-voice](https://github.com/DaemonAlex/dps-voice) | Spoken lines for NPCs, station announcements, dispatch and shops, from local voice models first. Pairs with dps-ainpcs. |
| [dps-bags](https://github.com/DaemonAlex/dps-bags) | Real bags for ox_inventory: the bag you carry shows on your character. |
| [dps-items](https://github.com/DaemonAlex/dps-items) | Item rules for ox_inventory: locked items, glovebox seats and an exploit watch. |
| [dps-furniture](https://github.com/DaemonAlex/dps-furniture) | Puts streamed furniture packs into the qs-housing furniture shop. |
| [dps-shellbrowser](https://github.com/DaemonAlex/dps-shellbrowser) | Staff tool to look at every qs-housing shell and set its door. |
| [dps-signs](https://github.com/DaemonAlex/dps-signs) | Rotates city messages across the SmartSigns road boards. |
| [dps-stationclear](https://github.com/DaemonAlex/dps-stationclear) | Hides map props that are in the way and keeps stray game peds off chosen spots. |
| [dps-citymap](https://github.com/DaemonAlex/dps-citymap) | A ready-made map of the whole city, cut into tiles for in-game screens. |
| [dps-cayo](https://github.com/DaemonAlex/dps-cayo) | Switches on the game's own Cayo Perico island, and nothing else. |
| [dps-aviation](https://github.com/DaemonAlex/dps-aviation) | Flight behaviour: aircraft idle instead of cutting out, sane taxi speed, a real start sequence. |
| [dps-airlines](https://github.com/DaemonAlex/dps-airlines) | Airlines job: passenger flights, cargo, charters, flight school and maintenance. |
| [dps-traintools](https://github.com/DaemonAlex/dps-traintools) | Rider tools for trains: board, sit, get off at a stop, ambient passengers. Pairs with dps-trains. |
| [dps-trains-stock](https://github.com/DaemonAlex/dps-trains-stock) | Train models and carriage sets for the train system. No scripts. Pairs with dps-trains. |
| [dps-traintracks](https://github.com/DaemonAlex/dps-traintracks) | Extra train track data. No scripts. Pairs with dps-trains. |
| [dps-crossings](https://github.com/DaemonAlex/dps-crossings) | Level crossings that close when a train comes. Pairs with dps-trains. |
| [dps-transit](https://github.com/DaemonAlex/dps-transit) | Passenger rail planning and scheduling (older system; dps-trains runs today). |
| [dps-maritime](https://github.com/DaemonAlex/dps-maritime) | Dock work and boat deliveries with progression. |
| [dps-maritime-maps](https://github.com/DaemonAlex/dps-maritime-maps) | Map files for the Jetsam docks, the map half of dps-maritime. |
| [dps-proracing](https://github.com/DaemonAlex/dps-proracing) | Circuit racing with lobbies, an AI practice grid and lap times. |
| [dps-carmenu](https://github.com/DaemonAlex/dps-carmenu) | Staff vehicle browser and spawner over the live Qbox vehicle list. |
| [dps-clothingbrowser](https://github.com/DaemonAlex/dps-clothingbrowser) | Staff tool to browse, identify and export clothing and uniforms. |
| [dps-lootpeds](https://github.com/DaemonAlex/dps-lootpeds) | Loot dead NPCs, with loot tables per model. |
| [dps-hookers](https://github.com/DaemonAlex/dps-hookers) | Adults-only RP (18+), adapted from MH Hookers by MaDHouSe. |
| [dps-fixes](https://github.com/DaemonAlex/dps-fixes) | Small server fixes kept in one resource. |
| [dps-bucketfix](https://github.com/DaemonAlex/dps-bucketfix) | Puts players back in the main world after spawning. |
| [dps-unfocus](https://github.com/DaemonAlex/dps-unfocus) | One key that frees a player stuck in a menu. |
| [dps-welcomecam](https://github.com/DaemonAlex/dps-welcomecam) | Aims the first camera a new player sees. |
| [dps-handlingdump](https://github.com/DaemonAlex/dps-handlingdump) | Developer tool: saves the stock handling of every vanilla vehicle. |
| [dps-weaponsounds](https://github.com/DaemonAlex/dps-weaponsounds) | Custom weapon sounds (planning; no code yet). |
| [dps-events](https://github.com/DaemonAlex/dps-events) | Playtime reward events (planning; no code yet). |
