fx_version 'cerulean'
game 'gta5'

Author 'Samuel#0008'
Description 'A library of functions, that also bridges frameworks and common 3rd party resources.'
Version '1.0.33'

client_scripts {
    'resource/client/client.lua',
    -- 'resource/client/devtools/**/client.lua' -- uncomment to enable dev tools
}

server_scripts {
    'resource/server/server.lua',
    -- 'resource/server/devtools/**/server.lua' -- uncomment to enable dev tools
}

-- ui_page 'resource/client/devtools/clipboard.html' -- uncomment to enable dev tools

files {
    'init.lua',
    'modules/**/shared.lua',
    'modules/**/client.lua',
    'modules/**/server.lua',
    -- 'resource/client/devtools/clipboard.html' -- uncomment to enable dev tools
}

shared_scripts {
    -- '@ox_lib/init.lua',
    'resource/init.lua',
} 

lua54 'yes'
