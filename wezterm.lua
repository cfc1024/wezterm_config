local Config = require('config')

return Config:init()
	:append(require('config.fonts')) -- font setting
	:append(require('config.window')) -- window setting
	:append(require('config.bindings')) -- key, mouse bindings
	.options