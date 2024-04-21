fx_version 'cerulean'
game 'gta5'

Author 'Samuel#0008'
Description 'A library of functions used to ease the bridge between SD Scripts'
Version '1.3.1'

client_scripts {
    'menus/cl_menu.lua',
    'resource/**/client.lua',
}

server_scripts {
    'resource/**/server.lua',
    'modules/callback/server.lua',
}

files {
    'init.lua',
    'modules/**/shared.lua',
    'modules/**/client.lua',
    'modules/**/server.lua',
    'locales/*.json',
}

shared_scripts {
    -- '@ox_lib/init.lua',
    'resource/init.lua',
} 

lua54 'yes'

escrow_ignore { 'client/*.lua', 'server/*.lua', 'shared/*.lua', 'export/export.lua', 'sh_config.lua', 'sv_config.lua', 'client/menu/cl_menu.lua' }