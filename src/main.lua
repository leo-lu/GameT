cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")

require "config"
require "cocos.init"
require "global"

local function main()
    require("app.MyApp"):create():run()
end

local status, msg = xpcall(main, function(err)
	return debug.traceback(err, 2)
end)
if not status then
    print(msg)
end
