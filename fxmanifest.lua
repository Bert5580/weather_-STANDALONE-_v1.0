fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Refactor by ChatGPT (cleaned & optimized)'
description 'Lightweight standalone weather controller with synced state, validation, and optional time freeze.'
version '1.1.0'

shared_scripts {
    'shared/config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}
