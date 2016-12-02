local Tilemap = class("Tilemap", cc.load("mvc").ViewBase)

function Tilemap:onCreate()
	cclog("Tilemap init")

	--修改设计分辨率
	local director = cc.Director:getInstance()
	local view = director:getOpenGLView()
	local conf = CC_DESIGN_RESOLUTION
	conf.width = 480
    conf.height = 240
	display.setAutoScale(conf)

	g_winSize = cc.Director:getInstance():getWinSize()

	--创建地图
	local mapNode = cc.Node:create()
	self:addChild(mapNode)

	local map = ccexp.TMXTiledMap:create("map/test.tmx")
    mapNode:addChild(map)

    -- local drawNode = cc.DrawNode:create()
    -- map:addChild(drawNode, 10)

    local arrRect = {}
    local  group   = map:getObjectGroup("coll")
    local  objects = group:getObjects()
    for i = 1, #objects do
    	local dict = objects[i]

        local x = dict["x"]
        local y = dict["y"]
        local width = dict["width"]
        local height = dict["height"]

		-- local color = cc.c4f(0,0,1,0.8)
  --       drawNode:drawLine( cc.p(x, y), cc.p((x+width), y), color)
  --       drawNode:drawLine( cc.p((x+width), y), cc.p((x+width), (y+height)), color)
  --       drawNode:drawLine( cc.p((x+width), (y+height)), cc.p(x, (y+height)), color)
  --       drawNode:drawLine( cc.p(x, (y+height)), cc.p(x, y), color)

        table.insert(arrRect, cc.rect(x, y, width, height))
    end

    --创建角色
    local role = require("app.module.Role").new(arrRect)
    mapNode:addChild(role)
    role:setPosition(cc.p(135, 100))

    --镜头跟随
    local mapSize = map:getContentSize()
    mapNode:runAction(cc.Follow:create(role, cc.rect(0, 0, mapSize.width, mapSize.height)))

    --创建虚拟摇杆
    self:initVC(role)

	local scheduler = cc.Director:getInstance():getScheduler()
    local schedulerEntry
    self:registerScriptHandler(function(event)
    	if "enter" == event then
		    schedulerEntry = scheduler:scheduleScriptFunc(function(dt)
		    	role:update()
			end, 0.016, false)
        elseif "exit" == event then
			scheduler:unscheduleScriptEntry(schedulerEntry)
        end
	end)

end

function Tilemap:initVC(role)
	local vc = require("app.views.VitrualControl").new()
	self:addChild(vc)
	vc:setDisCallback(function(dir, action)
		if nil ~= dir then
			role:move(dir)
		end

		local arrAction = {
			function()
				role:jump()
			end,
			function()				
				role:fly()
			end
		}
		local actionLogic = arrAction[action]
		if nil ~= actionLogic then
			actionLogic()
		end
	end)
end

return Tilemap