local GameScene = class("GameScene", cc.load("mvc").ViewBase)

local colNum 	= 4
local colSpace 	= 10
local colW		= (g_winSize.width - (colNum + 1) * colSpace) / colNum
local rowSpace	= 10

local bStyle	= {
	DIE 		= cc.c4b(50, 50, 50, 250),
	NORMAL		= cc.c4b(100, 200, 150, 150),
	BOOM		= cc.c4b(200, 50, 50, 150),
	COOL 		= cc.c4b(250, 250, 250, 200),
	SM			= cc.c4b(100, 100, 100, 200),
}

local rowRange	= {2, 3}
local arrBlock	= {} --

local block = {}
function block:create(style)
	local obj = cc.LayerColor:create(style)
	obj:setContentSize(cc.size(colW, colW))
	obj._style = style

	return obj
end

local rowObj = {}
function rowObj:create()
	local obj = cc.Node:create() 
	obj.arr = {}
	obj.count = 0
	function obj:addBlock(b, col)
		local pos = cc.p((col - 1) * colW + col * colSpace, 0)		
		b:setPosition(pos)
		self:addChild(b)

		self.arr[col..""] = b
		self.count = self.count + 1
	end

	function obj:addBlockByAction(b, col, callback)
		local pos = cc.p((col - 1) * colW + col * colSpace, 0)		
		b:setPosition(cc.p(pos.x, -self:getPositionY() - colW))
		self:addChild(b)

		self.arr[col..""] = b
		self.count = self.count + 1

		b:runAction(cc.Sequence:create(cc.MoveTo:create(0.15, pos), cc.CallFunc:create(callback)))
	end

	function obj:getBlocks()
		return self.arr
	end

	function obj:getBlock(col)
		return self.arr[col]
	end

	function obj:clear()
		if self.count == colNum then
			self:runAction(cc.Sequence:create(cc.FadeOut:create(0.03), cc.CallFunc:create(function()
				self:removeFromParent()
			end)))
			return true
		end

		return false
	end

	return obj
end

local isGameOver = false
function GameScene:onCreate()
	math.randomseed(os.time())

	local bg = cc.LayerColor:create(cc.c4b(50, 50, 50, 150))
	self:addChild(bg)

	local scheduler = cc.Director:getInstance():getScheduler()
	local schedulerEntry = scheduler:scheduleScriptFunc(function(dt)
		self:update(dt)
	end, 0.01, false)

	----touch处理
	local beganPos = {} --id, pos
	local function onTouchesBegan(touchs, event)
		for _, touch in ipairs(touchs) do
			local pos = touch:getLocation()
			
			--cclog("began  pos id:"..touch:getId().."  x:"..pos.x.."   y:"..pos.y)
			beganPos[touch:getId()] = pos
		end
	end

	local function onTouchesMoved(touchs, event)
		for _, touch in ipairs(touchs) do
			local pos = touch:getLocation()
			
			local moveId = touch:getId();
			--cclog("moved  pos id:"..touch:getId().."  x:"..pos.x.."   y:"..pos.y)
			local bPos = beganPos[moveId]
			if nil ~= bPos then
				if 10 <= pos.y - bPos.y then
					--cclog("moved  pos id:"..touch:getId().."  x:"..pos.x.."   y:"..pos.y)

					local mod = math.mod(bPos.x, (colW + colSpace))
					local col = (bPos.x - mod) / (colW + colSpace)
					if 0 < mod then
						col = col + 1
					end
					beganPos[moveId] = nil

					--cclog("col = "..col)
					self:addBlock(col.."")
				end
			end
		end
	end

	local function onTouchesEnded(touchs, event)
		for _, touch in ipairs(touchs) do
			local pos = touch:getLocation()
			local mod = math.mod(pos.x, (colW + colSpace))
			local col = (pos.x - mod) / (colW + colSpace)
			if 0 < mod then
				col = col + 1
			end
			--self:addBlock(col.."")
		end
	end

    local listener = cc.EventListenerTouchAllAtOnce:create()
    listener:registerScriptHandler(onTouchesBegan, cc.Handler.EVENT_TOUCHES_BEGAN)
    listener:registerScriptHandler(onTouchesMoved, cc.Handler.EVENT_TOUCHES_MOVED)
    listener:registerScriptHandler(onTouchesEnded, cc.Handler.EVENT_TOUCHES_ENDED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

    self:showStartView()
end

function GameScene:showStartView()
	if nil == self.startView then
		local viewSize = cc.size(g_winSize.width - 300, 300)
		self.startView = cc.LayerColor:create(cc.c4b(50, 50, 50, 200))
		self.startView:setContentSize(viewSize)
		self:addChild(self.startView)
		self.startView:setPosition(cc.p((g_winSize.width - viewSize.width)/2,
										(g_winSize.height - viewSize.height)/2))

		local btn = ccui.Button:create()
		btn:setTitleText("Start")
		btn:setTitleFontSize(30)
		btn:setPosition(cc.p(viewSize.width/2, viewSize.height/2))
		self.startView:addChild(btn)

		btn:addClickEventListener(function()
			self.startView:setVisible(false)
			self:startGame()
		end)
	end
	self.startView:setVisible(true)
end

function GameScene:startGame()
	for rIdx, rObj in pairs(arrBlock) do
		rObj:removeFromParent()
	end
	arrBlock = {}
	isGameOver = false
	table.insert(arrBlock, self:createRow(0))
end

function GameScene:createRow(row)
	local maxRow = arrBlock[#arrBlock]
	local yPos
	if nil == maxRow then
		yPos = g_winSize.height
	else
		yPos = maxRow:getPositionY() + colW + rowSpace
	end

	local _rowObj = arrBlock[row]
	if nil == _rowObj or {} == _rowObj then
		 _rowObj = rowObj:create()
		 _rowObj:setPosition(cc.p(0, yPos))
		 self:addChild(_rowObj)
	end

	local rNum = rowRange[1]
	if 1 < #rowRange and 2 == #rowRange then
		rNum = math.random(rowRange[1], rowRange[2])
		--cclog("num:", rNum)
	end

	--支持列数
	local arrCol = {}
	for i = 1, colNum do
		table.insert(arrCol, i)
	end
	--随机并删除已经使用位置列
	local randomCol = function()
		local idx = math.random(1, #arrCol)
		local col = arrCol[idx]
		table.remove(arrCol, idx)
		return col
	end
	--生成块
	for i= 1, rNum do
		local col = i
		if rNum < colNum then
			col = randomCol()
		end
		--cclog("col:", col)
		local bObj = block:create(bStyle.NORMAL)
		_rowObj:addBlock(bObj, col)
	end

	return _rowObj
end

function GameScene:addBlock(col)
	local row = arrBlock[1]
	if nil == row then
		return
	end

	local bObj = block:create(bStyle.NORMAL)

	local xPos = (col - 1) * colW + col * colSpace
	local yPos = row:getPositionY()

	local objs = row:getBlocks()

	if nil == objs[col] then
		row:addBlockByAction(bObj, col, function()
			if row:clear() then
				table.remove(arrBlock, 1)
			end	
		end)
	else
		cclog("not nil")
		local newRow = rowObj:create()
	 	newRow:setPosition(cc.p(0, yPos - colW - rowSpace))
	 	self:addChild(newRow)

		newRow:addBlockByAction(bObj, col, function()

		end)

		table.insert(arrBlock, 1, newRow)
	end
end

function GameScene:update(dt)
	if isGameOver then return end

	local bIsNewRow = false
	for r, row in pairs(arrBlock) do
		local posY = row:getPositionY() - 5
		if not bIsNewRow and r == #arrBlock then
			bIsNewRow = posY <= g_winSize.height
		end

		row:setPositionY(posY)
	end
	if bIsNewRow then
		--cclog("current row:", #arrBlock)
		table.insert(arrBlock, self:createRow(#arrBlock + 1))
	end

	local rowObj = arrBlock[1]
	if nil == rowObj then
		return
	end

	if 0 > rowObj:getPositionY() + colW then
		--cclog("Is game over!~")
		isGameOver = true
		self.startView:setVisible(true)
	end
end

return GameScene