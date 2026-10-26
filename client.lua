-- Scripts written for qb-weathersync / Renewed pause and resume the weather sync around
-- their own scenes (qbx_core character creation, qs-housing, qs-motorhome, dps-studio rooms).
-- Nights ND exposes the same idea as PauseSynchronization(true|false).
--
-- 2026-09-30: a shell is one big prop, so the game lights it like outdoors and the sun shone
-- inside windowless rooms. While the sync is paused this client now also sees night-time
-- (23:00) and no rain, for this player only. Resuming gives the world clock back.
-- No weather type is set here: the world weather stays with night_natural_disasters.
local ND = 'night_natural_disasters'
local held = 0   -- how many scripts have paused the sync (a room inside a house, and so on)

local function pauseSync(paused)
    if GetResourceState(ND) ~= 'started' then return end
    local ok, err = pcall(function()
        exports[ND]:PauseSynchronization(paused)
    end)
    if not ok then
        print(('[dps-weatherbridge] PauseSynchronization(%s) failed: %s'):format(tostring(paused), tostring(err)))
    end
end

-- 2026-10-18 TEST: night_natural_disasters, while paused, holds the clock at 18:00 every frame
-- (low sun inside shells, and it fights any night override). So indoors we no longer pause it;
-- we only hold night for this player, every frame while indoors. Undo: client.lua.bak-20261018-nopause.
local holding = false
-- 2026-10-18: a script may ask for its own hour (the Studio photo booth and flyover pass 12 for
-- daylight pictures). The newest request wins; when it ends, the one before it (a room's night) is back.
local hours = {}
local function wantHour() return hours[#hours] or 23 end

local function indoors(on)
    if on then
        SetRainLevel(0.0)
        if not holding then
            holding = true
            CreateThread(function()
                while held > 0 do
                    NetworkOverrideClockTime(wantHour(), 0, 0)
                    Wait(0)
                end
                holding = false
            end)
        end
        print(('[dps-weatherbridge] indoor light on (hold %02d:00, weather not paused)'):format(wantHour()))
    else
        NetworkClearClockTimeOverride()
        SetRainLevel(-1.0)   -- hand rain back to the weather system
        print('[dps-weatherbridge] indoor light off')
    end
end

RegisterNetEvent('qb-weathersync:client:DisableSync', function(hour)
    held = held + 1
    hours[#hours + 1] = tonumber(hour) or 23
    indoors(true)
end)

RegisterNetEvent('qb-weathersync:client:EnableSync', function(hour)
    held = math.max(0, held - 1)
    local h = tonumber(hour) or 23
    for i = #hours, 1, -1 do if hours[i] == h then table.remove(hours, i); break end end
    if held > 0 then return end   -- another script still has it paused
    hours = {}
    indoors(false)
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() or held == 0 then return end
    indoors(false)
    pauseSync(false)
end)
