fx_version 'cerulean'
game 'gta5'

description 'THD Multicharacter'
version '1.0.0'

ui_page 'html/index.html'

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
}

lua54 'yes'