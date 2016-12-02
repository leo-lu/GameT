require "app.tools"
--require "anysdkConst"
cc.exports.g_winSize = cc.Director:getInstance():getWinSize()

local MyApp = class("MyApp", cc.load("mvc").AppBase)

function MyApp:onCreate()
    math.randomseed(os.time())
end

return MyApp
