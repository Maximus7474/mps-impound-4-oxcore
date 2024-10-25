# Basic Impound System for Ox Core

Only designed for [ox_core](https://github.com/overextended/ox_core).

This is just a simple script to handle impounded vehicles in lua.
Might rewrite it in TS.

## Setup
To add more impounds you can define more inside of `shared/impounds.lua`
Follow the template:
```lua
['impound_identifier'] = { --[[ Is what will be referenced inside of the vehicles.stored ]]
    label = 'Impound Name',
    ped = {
        position = vector4(409.1702, -1622.8986, 29.2919, 226.8630),
        model = `csb_trafficwarden`, --[[ Make sure it's a valid one ]]
        animation = {
            --[[ Either use scenario or dict and anim, scenario will be taken if both are defined ]]
            scenario = 'WORLD_HUMAN_AA_COFFEE', 
            dict = 'rcmjosh1',
            anim = 'idle'
        }
    },
    --[[ Define the classes available inside of the impound ]]
    classes = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22},
    --[[ Define the spawnpositions, default is required ]]
    --[[ Use the class as a key, allows for bigger vehicles to spawn elsewhere ]]
    spawnpoints = {
        default = vector4(402.9437, -1632.8813, 29.2877, 139.6194),
        [17] = vector4(402.5103, -1632.9012, 29.2885, 176.7454),
        [20] = vector4(402.5103, -1632.9012, 29.2885, 176.7454),
    }
}
```