local Ox = require '@ox_core/lib/init'
local impounds = require 'shared.impounds'

local defaultImpoundCost = GetConvarInt('impound:defaultImpoundCost', 50)

lib.callback.register('garage:getImpoundedVehicles', function (source, impound)
    if not impounds[impound] then
        lib.print.warn('Invalid Impound Name')
        return false
    end

    local impoundData = impounds[impound]
    local playerCoords, impoundCoords = GetEntityCoords(GetPlayerPed(source)), impoundData.ped.position
    if #(playerCoords.xyz - impoundCoords.xyz) > 10.0 then
        lib.print.warn(source, 'tried to exploit impound callback')
        return false
    end

    local player = Ox.GetPlayer(source)
    local response = MySQL.query.await([[
        SELECT v.id, v.plate, v.vin, v.model, v.class, impound_info.sum, impound_info.reason
        FROM vehicles AS v
        LEFT JOIN vehicles_impound_data AS impound_info ON v.vin = impound_info.vin
        WHERE v.owner = ? AND (v.stored = ? OR v.stored = "impound")]],
        {player.charId, impound}
    )

    local vehicles = {}
    for _, data in pairs(response) do
        if lib.table.contains(impoundData.classes, data.class) then
            vehicles[#vehicles+1] = data
        end
    end

    return vehicles
end)

RegisterNetEvent('garage:retrieveVehicle', function (impound, dbid)
    local source = source
    if not impounds[impound] then
        lib.print.warn('Invalid Impound Name')
        return false
    end

    local playerCoords, impoundCoords = GetEntityCoords(GetPlayerPed(source)), impounds[impound].ped.position
    if #(playerCoords.xyz - impoundCoords.xyz) > 10.0 then
        lib.print.warn(source, 'tried to exploit impound callback')
        return false
    end

    local data = MySQL.single.await([[
        SELECT v.class, v.vin, vid.sum
        FROM vehicles AS v
        LEFT JOIN vehicles_impound_data AS vid ON v.vin = vid.vin
        WHERE v.id = ? ]],
        {dbid}
    )

    local class, impoundSum, vin = data.class, data?.sum or 50, data.vin

    local spawnPoints = impounds[impound].spawnpoints
    local spawnPosition = spawnPoints[class] or spawnPoints.default

    if not spawnPosition then
        lib.print.error(('Unable to spawn the vehicle class %d at impound: %s.'):format(class, impound))
        lib.print.error('There wasn\'t a default position')
        return TriggerClientEvent('ox_lib:notify', source, {description = "Unable to bring the vehicle", type = "error"})
    end

    local player = Ox.GetPlayer(source)
    local account = Ox.GetCharacterAccount(player.charId)
    local status = account.removeBalance({ amount = impoundSum, message = ('Impound Costs for: %s'):format(vin), overdraw = false })

    if not status.success then
        return TriggerClientEvent('ox_lib:notify', source, {description = "You do not have sufficient funds", type = "error"})
    end

    MySQL.update('DELETE FROM vehicles_impound_data WHERE vin = ?', {vin})

    TriggerClientEvent('ox_lib:notify', source, {description = "You've paid the impound fine", type = "succes"})

    Ox.SpawnVehicle(dbid, spawnPosition.xyz, spawnPosition.w)
end)

---@class ImpoundData
---@field entity number or netid/vin
---@field netid number or entity/vin
---@field vin string or entity/netid
---@field impound string|nil
---@field price number|nil
---@field reason string|nil

---Impound a vehicle and set custom data
---@param data ImpoundData 
---@return nil
local function impoundVehicle(data)
    if not data.entity and not data.netid and data.vin then
        return lib.print.error('Unable to impound vehicle ! No identifying data was passed to do so.')
    end

    local vehicle
    if data.entity then
        vehicle = Ox.GetVehicle(data.entity)
    elseif data.netid then
        vehicle = Ox.GetVehicleFromNetId(data.netid)
    elseif data.vin then
        vehicle = Ox.GetVehicleFromVin(data.vin)
    end

    if not vehicle then
        return lib.print.error(('Unable to find vehicle ! %s: %s didn\'t provide any results.'):format(data.entity and "entity" or data.netid and "netid" or "vin"), tostring(data.entity or data.netid or data.vin))
    end

    vehicle.setStored(data.impound or "impound", true)

    if (data.reason or data.sum) and vehicle.id then
        MySQL.update('UPDATE vehicles_impound_data SET sum = ?, reason = ? WHERE id = ?', {
            data.sum or defaultImpoundCost, data.reason or nil, vehicle.id
        })
    end
end

exports('ImpoundVehicle', impoundVehicle)