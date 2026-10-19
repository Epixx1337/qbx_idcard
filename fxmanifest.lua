fx_version 'cerulean'
game 'gta5'
lua54 'yes'
node_version '22'

name 'qbx_idcard'
author 'uyuyorum {um}'
version '1.0.0'
license 'GPL-3.0 license'
repository 'https://github.com/Qbox-project/qbx_idcard'
description 'Identity cards, licenses and badges with an in-game card designer for Qbox'

ox_lib 'locale'

dependencies {
    'ox_lib',
    'oxmysql',
    'qbx_core',
    'ox_inventory',
    'MugShotBase64'
}

shared_script '@ox_lib/init.lua'

client_scripts {
    'client/main.lua',
    'client/designer.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/upload.js',
}

ui_page 'web/build/index.html'

files {
    'config/shared.lua',
    'locales/*.json',
    'web/build/index.html',
    'web/build/**/*',
}
