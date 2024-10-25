fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
lua54 'yes'
game 'gta5'
repository 'https://github.com/Maximus7474/mps-impound-4-oxcore'

version '0.1.0'

shared_scripts {
    '@ox_lib/init.lua'
}
files {
    'client/modules/*.lua',
    'shared/impounds.lua'
}


client_scripts {
    'client/init.lua'
}
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/init.lua'
}

dependancies {
    'ox_core',
    'ox_target',
    'ox_lib'
}