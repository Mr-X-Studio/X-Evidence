fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'X Studio / Mr X'
description 'X Evidence - Smart Evidence & Crime Investigation System'
version '0.1.0'

shared_scripts {
    'shared/config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

ui_page 'web/index.html'

files {
    'web/index.html',
    'web/style.css',
    'web/app.js'
}
