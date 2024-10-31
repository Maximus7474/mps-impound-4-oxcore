local currentImpound = nil

---@class VehiclePreview
---@field vin string
---@field id number database id
---@field model string
---@field plate string
---@field reason string|nil
---@field sum number

---@param data VehiclePreview
local function selectVehicle(data)
    local dbid = data.id

    local response = lib.alertDialog({
        header = "Confirm Impound Retrieval",
        content = ("Do you want to retrieve your vehicle for %d$ ?"):format(data.sum),
        cancel = true,
        centered = true,
    })

    if response == 'cancel' then return lib.showContext('impound_menu') end
    TriggerServerEvent('garage:retrieveVehicle', currentImpound, dbid)
    currentImpound = nil
end

---@param vehicles VehiclePreview[]
---@return ContextMenuArrayItem[]
local function formatVehicles(vehicles)
    local options = {}

    for _, data in pairs(vehicles) do
        local metadata = {{ label = 'VIN', value = data.vin }}
        if data.reason then
            metadata[#metadata+1] = { label = 'Impound Reason', value = data.reason }
        end

        options[#options+1] = {
            title = GetDisplayNameFromVehicleModel(joaat(data.model)),
            description = ('Plate: %s \nCost: %d$'):format(data.plate, data?.sum or 50),
            metadata = metadata,
            onSelect = selectVehicle,
            args = data
        }
    end

    return options
end

---@param impound string impound identifier
---@param name string impound label
---@param spawnData SpawnPoints
return function (impound, name, spawnData)
    currentImpound = impound
    local vehicles = lib.callback.await('garage:getImpoundedVehicles', false, impound)

    lib.registerContext({
        id = 'impound_menu',
        title = name,
        options = formatVehicles(vehicles),
        onExit = function ()
            currentImpound = nil
        end
    })

    lib.showContext('impound_menu')
end