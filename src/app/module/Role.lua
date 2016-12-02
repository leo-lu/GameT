local Role = class("Role", cc.Node)

local standPos 	= {x = 32, y = 32}
		
local xSpeed 	= 1.2		--初始x速度
local ySpeed 	= 6.2		--初始y速度
local dXSpeed 	= xSpeed 	--动作过程中x变量
local dYSpeed 	= ySpeed 	--动作过程中y变量

local moveDir 	= 0		--移动方向
local acceslate = 0.25	--重力速度

local R_STATE 	= {
	NONE 		= 1,
	STAND 		= 2,
	JUMP 		= 3,
	MOVE_LEFT 	= 4,
	MOVE_RIGHT	= 5,
}

local R_DIR = {
	LEFT 		= function(self, spBox, collBox)
		local spPos = cc.p(cc.rectGetMinX(spBox) - 0.001, cc.rectGetMidY(spBox))
		return cc.rectContainsPoint(collBox, spPos)
	end,
	RIGHT 		= function(self, spBox, collBox)
		local spPos = cc.p(cc.rectGetMaxX(spBox) + 0.001, cc.rectGetMidY(spBox))
		return cc.rectContainsPoint(collBox, spPos)
	end,
	TOP			= function(self, spBox, collBox)
		local spPosMin = cc.p(cc.rectGetMinX(spBox) + 0.001, cc.rectGetMaxY(spBox))
		local spPosMid = cc.p(cc.rectGetMidX(spBox), cc.rectGetMaxY(spBox))
		local spPosMax = cc.p(cc.rectGetMaxX(spBox) - 0.001, cc.rectGetMaxY(spBox))
		return (cc.rectContainsPoint(collBox, spPosMin) or
				cc.rectContainsPoint(collBox, spPosMid) or
				cc.rectContainsPoint(collBox, spPosMax))
	end,
	BOTTOM 		= function(self, spBox, collBox)
		local spPosMin = cc.p(cc.rectGetMinX(spBox) + 0.001, cc.rectGetMinY(spBox))
		local spPosMid = cc.p(cc.rectGetMidX(spBox), cc.rectGetMinY(spBox))
		local spPosMax = cc.p(cc.rectGetMaxX(spBox) - 0.001, cc.rectGetMinY(spBox))
		return (cc.rectContainsPoint(collBox, spPosMin) or
				cc.rectContainsPoint(collBox, spPosMid) or
				cc.rectContainsPoint(collBox, spPosMax))
	end,
}

--位移坐标前提前计算碰撞
function Role:getBox(posX, posY)
	local size = self:getContentSize()
	return cc.rect(posX, posY, size.width, size.height)
end

function Role:ctor(arrCollBox)
	cclog("role ctor")
	self.arrCollBox = arrCollBox

	for i=1,#self.arrCollBox do
		local rect = self.arrCollBox[i]
		cclog("x %d  y %d  w %d  h %d", rect.x, rect.y, rect.width, rect.height)
	end

	self:init()
end

function Role:init()
	self.sp = cc.Sprite:create("icon_small.png")
	self.sp:setAnchorPoint(cc.p(0, 0))
	self:addChild(self.sp)

	local size = self.sp:getContentSize()
	self:setContentSize(size)

	self.fsm = require("app.module.FSM"):createFSM()
	dYSpeed = 0
	self.fsm:setState(self.jumpDown)
	
	self.bg = cc.LayerColor:create(cc.c4f(0, 100, 0, 100))
	self.bg:setContentSize(size)
	self:addChild(self.bg)

	self.curState = R_STATE.NONE
end

function Role:checkColl(checkLogic, spBox, arrIgnore)
	if nil == self.arrCollBox or nil == checkLogic then return false end
	arrIgnore = arrIgnore or {}
	for i = 1, #self.arrCollBox do
		if nil == arrIgnore[i] then
			local collRect = self.arrCollBox[i]
			if checkLogic(self, spBox, collRect) then
				return true, collRect, i
			end
		end
	end

	return false
end

function Role:born()
	local posX, posY = self:getPosition()
	if standPos.y < posY then
		self:setPosition(cc.p(posX, posY - 5))
	else
		self.fsm:setState(self.stand)
	end
end

function Role:stand()
	if self.curState == R_STATE.STAND then return end

	self.curState = R_STATE.STAND
	moveDir = 0

	cclog("stand")
end

function Role:jump()
	if self.curState == R_STATE.JUMP then return end

	self.curState = R_STATE.JUMP
	self.fsm:setState(self.jumpUp)
end

function Role:jumpUp()
	cclog("jump up %d", moveDir)
	local posX, posY = self:getPosition()

	if 1 == moveDir then
		posX = posX + xSpeed
	elseif -1 == moveDir then
		posX = posX - xSpeed
	end

	dYSpeed = dYSpeed - acceslate
	posY = posY + dYSpeed

	local spBox = self:getBox(posX, posY)
	local check, rect = self:checkColl(R_DIR.TOP, spBox)
	if 0 >= dYSpeed or check then
		dYSpeed = 0
		if check then
			posY = cc.rectGetMinY(rect) - self:getContentSize().height
		end

		self.fsm:setState(self.jumpDown)
	end
	
	self:setPosition(cc.p(posX, posY))
end

function Role:jumpDown()
	cclog("jump down")
	local posX, posY = self:getPosition()

	if 1 == moveDir then
		posX = posX + xSpeed
	elseif -1 == moveDir then
		posX = posX - xSpeed
	end

	dYSpeed = dYSpeed + acceslate
	local posY = posY - dYSpeed

	local spBox = self:getBox(posX, posY)
	local lCheck, lRect, idx = self:checkColl(R_DIR.LEFT, spBox)

	local bCheck, bRect = self:checkColl(R_DIR.BOTTOM, spBox)
	if lCheck then
		table.remove(self.arrCollBox, idx)
	end
	
	if bCheck then
		posY = cc.rectGetMaxY(bRect)
		dYSpeed = ySpeed
		self.fsm:setState(self.stand)
	end
	
	

	if -20 >= posY then
		self:setPosition(cc.p(5, 100))
		self.fsm:setState(self.jumpDown)
		return
	end

	self:setPosition(cc.p(posX, posY))
end

function Role:moveLeft()
	local posX, posY = self:getPosition()
	local spBox = self:getBox(posX, posY)

	if not self:checkColl(R_DIR.BOTTOM, spBox) then
		dYSpeed = 2.5
		self.curState = R_STATE.JUMP
		self.fsm:setState(self.jumpDown)
		return
	end

	local check, rect = self:checkColl(R_DIR.LEFT, spBox)
	if not check then
		posX = posX - xSpeed
	else
		posX = cc.rectGetMaxX(rect)
		self.fsm:setState(self.stand)
	end
	self:setPositionX(posX)
end

function Role:moveRight()
	local posX, posY = self:getPosition()
	local spBox = self:getBox(posX, posY)

	if not self:checkColl(R_DIR.BOTTOM, spBox) then
		dYSpeed = 2.5
		self.curState = R_STATE.JUMP
		self.fsm:setState(self.jumpDown)
		return
	end
	
	local check, rect = self:checkColl(R_DIR.RIGHT, spBox)
	if not check then
		posX = posX + xSpeed
	else
		posX = cc.rectGetMinX(rect) - self:getContentSize().width
		self.fsm:setState(self.stand)
	end
	self:setPositionX(posX)
end

function Role:move(dir)
	if 0 ~= dir.x then
		if 0 < dir.x then
			if R_STATE.JUMP == self.curState then
				moveDir = 1
			else
				if self.curState == R_STATE.MOVE_RIGHT then return end
				self.curState = R_STATE.MOVE_RIGHT
				self.fsm:setState(self.moveRight)
			end
		else
			if R_STATE.JUMP == self.curState then
				moveDir = -1
			else
				if self.curState == R_STATE.MOVE_LEFT then return end
				self.curState = R_STATE.MOVE_LEFT
				self.fsm:setState(self.moveLeft)
			end
		end
	else
		if R_STATE.JUMP == self.curState then
			moveDir = 0
		else
			self.fsm:setState(self.stand)
		end
	end
end

function Role:fly()
	cclog("fly...")
end

function Role:update()
	if nil ~= self.fsm then
		self.fsm:update(self)
	end
end

return Role