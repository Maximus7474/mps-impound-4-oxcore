local Ox = require '@ox_core/lib/init'
local impounds = require 'shared.impounds'

lib.callback.register('garage:getImpoundedVehicles', function (source, impound)
    if not impounds[impound] then
        lib.print.warn('Invalid Impound Name')
        return false
    end

    local playerCoords, impoundCoords = GetEntityCoords(GetPlayerPed(source)), impounds[impound].ped.position
    if #(playerCoords.xyz - impoundCoords.xyz) > 10.0 then
        lib.print.warn(source, 'tried to exploit impound callback')
        return false
    end

    local player = Ox.GetPlayer(source)
    local response = MySQL.query.await(
        'SELECT `id`, `plate`, `vin`, `model` FROM `vehicles` WHERE `owner` = ? AND (`stored` = ? OR `stored` = "impound")',
        {player.charId, impound}
    )

    return response
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

    local class = MySQL.single.await(
        'SELECT `class` FROM `vehicles` WHERE `id` = ?',
        {dbid}
    )

    local spawnPoints = impounds[impound].spawnpoints
    local spawnPosition = spawnPoints[class] or spawnPoints.default

    if not spawnPosition then
        lib.print.error(('Unable to spawn the vehicle class %d at impound: %s.'):format(class, impound))
        lib.print.error('There wasn\'t a default position')
        return TriggerClientEvent('ox_lib:notify', source, {description = "Unable to bring the vehicle", type = "error"})
    end

    local player = Ox.GetPlayer(source)
    local account = Ox.GetCharacterAccount(player.charId)
    local status = account.removeBalance({ amount = 50, message = 'Impound Costs', overdraw = false })

    if not status.success then
        return TriggerClientEvent('ox_lib:notify', source, {description = "You do not have sufficient funds", type = "error"})
    end

    TriggerClientEvent('ox_lib:notify', source, {description = "You've paid the impound fine", type = "succes"})

    Ox.SpawnVehicle(dbid, spawnPosition.xyz, spawnPosition.w)
end)