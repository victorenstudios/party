-- NC PROTECT+
shared_scripts { '@nc_PROTECT+/exports/sh.lua' }

fx_version 'adamant'
game 'gta5'

description 'XNS : Develop'

version '1.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/script.js',
    'html/sounds/*.mp3'
}

shared_scripts {
	'config/config.lua',
    'config/config_shop.lua',
	'config/config_fam.lua',
    'config/config_airdrop.lua',
    'config/config_flag.lua',
    'config/config_warzone.lua',
    'config/config_squad.lua',
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'config.lua',
	"core/sv/sv_main.lua",
    "core/sv/sv_fam.lua",
    "core/sv/sv_shop.lua",
    "core/sv/sv_airdrop.lua",
    "core/sv/sv_flag.lua",
    "core/sv/sv_warzone.lua",
    "core/sv/sv_squad.lua",
}

client_scripts {
    'config.lua',
	"core/cl/cl_main.lua",
    "core/cl/cl_fam.lua",
    "core/cl/cl_shop.lua",
    "core/cl/cl_airdrop.lua",
    "core/cl/cl_flag.lua",
    "core/cl/cl_warzone.lua",
    "core/cl/cl_squad.lua",
}