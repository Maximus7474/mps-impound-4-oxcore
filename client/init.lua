local impounds = require 'shared.impounds'
local openImpound = require 'client.modules.open'

for impound, data in pairs(impounds) do

    if type(data.ped.model) ~= "number" then
        data.ped.model = joaat(data.ped.model)
    end

    local point = lib.points.new({
        id = impound,
        name = data.label,
        coords = data.ped.position,
        distance = 100,
        impound = impound,
        ped = data.ped,
        spawnData = data.spawnpoints
    })

    function point:onEnter()
        lib.requestModel(self.ped.model)

        local ped = CreatePed(4, self.ped.model, self.ped.position.x, self.ped.position.y, self.ped.position.z - 0.98, self.ped.position.w, false, true)
        RemoveModelFromCreatorBudget(self.ped.model)

        self.entity = ped

        SetEntityInvincible(ped, true)
        FreezeEntityPosition(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)

        if self.ped.animation.scenario then
            TaskStartScenarioInPlace(ped, self.ped.animation.scenario, 0, false)
        elseif self.ped.animation.dict and self.ped.animation.anim then
            lib.playAnim(
                ped, self.ped.animation.dict, self.ped.animation.anim
            )
        end

        exports.ox_target:addLocalEntity(ped, {
            label = "Open impound",
            icon = "fa-solid fa-car-side",
            distance = 2.0,
            canInteract = function ()
                return cache.vehicle == false
            end,
            onSelect = function ()
                openImpound(self.impound, self.name, self.spawnData)
            end
        })
    end

    if DEBUG then
        function point:nearby()
            DrawMarker(
                28, self.ped.position.x, self.ped.position.y, self.ped.position.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                self.distance, self.distance, self.distance,
                255, 0, 0, 150, false, false, 0, false, false, false, false
            )
        end
    end

    function point:onExit()
        exports.ox_target:removeLocalEntity(self.entity)
        DeletePed(self.entity)
    end
end