local testFSM = class("testFSM", cc.load("mvc").ViewBase)

function testFSM:onCreate()
	cclog("testFSM")

	local _map = ccexp.TMXTiledMap:create("map/test.tmx")
    self:addChild(_map)

    local role = require("app.module.Role").new()
    self:addChild(role)
    role:setPosition(cc.p(100, 300))

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

	self:initVC(role)
end

function testFSM:initVC(role)
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

return testFSM