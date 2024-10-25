---@class ImpoundAnimationData
---@field scenario string
---@field dict string
---@field anim string

---@class ImpoundPedData
---@field position vector4
---@field model string
---@field animation ImpoundAnimationData

---@class SpawnPoints
---@type table<number | "default", vector4>

---@class Impound
---@field label string Impound name
---@field ped ImpoundPedData Ped information
---@field classes number[] Available classes
---@field spawnpoints SpawnPoints Available spawn points

---@type table<string, Impound>
return {
    ['impound_south_los_santos'] = {
        label = 'Davis Police Impound',
        ped = {
            position = vector4(409.1702, -1622.8986, 29.2919, 226.8630),
            model = `csb_trafficwarden`,
            animation = {
                scenario = 'WORLD_HUMAN_AA_COFFEE',
                dict = 'rcmjosh1',
                anim = 'idle'
            }
        },
        classes = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, --[[ 10, ]] 11, 12, 13, --[[ 14, 15, 16, ]] 17, 18, 19, 20, 21, 22},
        spawnpoints = {
            default = vector4(402.9437, -1632.8813, 29.2877, 139.6194),
            [17] = vector4(402.5103, -1632.9012, 29.2885, 176.7454),
            [20] = vector4(402.5103, -1632.9012, 29.2885, 176.7454),
        }
    }
}