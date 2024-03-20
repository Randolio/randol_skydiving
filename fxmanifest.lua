fx_version 'cerulean'
game 'gta5'

author 'Randolio'
description 'Skydiving'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'bridge/client/**.lua',
    'cl_skydiving.lua',
}

server_scripts {
    'bridge/server/**.lua',
    'sv_config.lua',
    'sv_skydiving.lua'
}

lua54 'yes'
