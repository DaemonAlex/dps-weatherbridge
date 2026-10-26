-- Keeps GlobalState.weather = { weather = 'RAIN' } filled from Nights ND so the readers that
-- looked at Renewed's state keep working: wasabi_police evidence wash-away, dps-ainpcs mood and
-- "right now" block, and anything else that reads GlobalState.weather.weather.
-- Also answers the qb-weathersync server events that wasabi_adminmenu ('qb' mode) fires.
local ND = 'night_natural_disasters'
local REFRESH_MS = 30000

local function ndStarted()
    return GetResourceState(ND) == 'started'
end

local function currentWeatherName()
    if not ndStarted() then return nil end
    local ok, result = pcall(function() return exports[ND]:GetCurrentWeather() end)
    if not ok then return nil end
    if type(result) == 'string' then return result:upper() end
    if type(result) == 'table' then
        local v = result.weather or result.Weather or result.type or result.name or result.current
        if type(v) == 'string' then return v:upper() end
    end
    return nil
end

local lastName
local function refresh()
    local name = currentWeatherName()
    if name and name ~= lastName then
        lastName = name
        GlobalState.weather = { weather = name }
    end
end

CreateThread(function()
    Wait(5000)
    while true do
        refresh()
        Wait(REFRESH_MS)
    end
end)

-- wasabi_adminmenu with Config.WeatherSystem = 'qb' fires these.
RegisterNetEvent('qb-weathersync:server:setWeather', function(weatherType)
    if type(weatherType) ~= 'string' or not ndStarted() then return end
    local ok, err = pcall(function() exports[ND]:SetWeather(weatherType:upper()) end)
    if not ok then print(('[dps-weatherbridge] SetWeather failed: %s'):format(tostring(err))) end
    Wait(1000)
    refresh()
end)

RegisterNetEvent('qb-weathersync:server:setTime', function(hour, minute)
    hour, minute = tonumber(hour), tonumber(minute) or 0
    if not hour or not ndStarted() then return end
    local ok, err = pcall(function() exports[ND]:SetTime(hour, minute) end)
    if not ok then print(('[dps-weatherbridge] SetTime failed: %s'):format(tostring(err))) end
end)

RegisterNetEvent('qb-weathersync:server:toggleBlackout', function()
    if not ndStarted() then return end
    pcall(function() exports[ND]:ToggleBlackout() end)
end)
