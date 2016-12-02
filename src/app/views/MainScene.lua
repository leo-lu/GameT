
local MainScene = class("MainScene", cc.load("mvc").ViewBase)

function MainScene:onCreate()
	print("MainScene")	

	local btn = ccui.Button:create("game_title.png", "game_title.png", "")
	btn:setPosition(cc.p(g_winSize.width/2, g_winSize.height/2))
	btn:addClickEventListener(function() 
		--self:getApp():enterScene("GameScene", "fade", 0.3)
		--self:getApp():enterScene("SixGrid", "fade", 0.3)
		self:getApp():enterScene("Tilemap", "fade", 0.3)
		--self:getApp():enterScene("testFSM", "fade", 0.2)
	end)
	self:addChild(btn)

	--local sp = cc.Sprite:create()
	local sp = ccui.ImageView:create("HelloWorld.png")
	sp:setPosition(cc.p(200, 200))
	--sp:setTexture("HelloWorld.png")
	self:addChild(sp)
	--sp:ignoreContentAdaptWithSize(false)
	sp:setContentSize(cc.size(50, 50))


	-- local luaj = require "cocos.cocos2d.luaj"
	-- local className = "org/cocos2dx/lua/AppActivity"
	-- local sigs = "()V"
 --    local ok,ret  = luaj.callStaticMethod(className,"showAdPopup",{nil},sigs)
 --    if not ok then
 --        print("luaj error:", ret)
 --    else
 --        print("The ret is:", ret)
 --    end


 	local clip = cc.ClippingNode:create()  
	clip:setInverted(false)
	clip:setAlphaThreshold(0.1)
	btn:removeFromParentAndCleanup(false)
	clip:addChild(btn)

	local spark = ccui.ImageView:create("spark.png")
	spark:setPosition(0, g_winSize.height/2)
	clip:addChild(spark)
	self:addChild(clip)

	local moveAction = cc.MoveTo:create(3, cc.p(g_winSize.width, g_winSize.height/2));
   	local moveBackAction = cc.MoveTo:create(3, cc.p(-g_winSize.width, g_winSize.height/2));
    local seq = cc.Sequence:create(moveAction, moveBackAction);
    local repeatAction = cc.RepeatForever:create(seq);
    spark:runAction(repeatAction)

	--以下模型是带图像遮罩  
	local nodef = cc.Node:create()
	local close = cc.Sprite:create("game_title.png");
	-- local close = cc.DrawNode:create()
	-- close:drawDot(cc.p(50, 50), 100, cc.c4f(1, 0, 0, 1));
	nodef:addChild(close)
	nodef:setPosition(cc.p(g_winSize.width / 2, g_winSize.height / 2))  
	clip:setStencil(nodef)

 	sp:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.JumpBy:create(0.2, cc.p(0, 100), 1, 5), cc.MoveBy:create(0.2, cc.p(0, -100)))))

 	--self:addShaderNode()

 	self:addTableView()


 -- 	for k, v in pairs(_G) do
 -- 		cclog(k, "  ", v)
 -- 	end

	-- local b, err = xpcall(function(p)
 -- 		cclog("test fun: ", p)
 -- 		error("xxx error")
	-- end,
	-- function()
	-- 	cclog(debug.traceback())
	-- end,
	-- 33)

	-- cclog(b, err)

	local test = require("app.test_base"):new("test")
	test.fun1 = function()
		error("xxxxx")
	end

	test.fun2 = function()
		cclog("test fun2")
	end

	test:run()

	-- self.wsSendText   = cc.WebSocket:create("ws://192.168.198.128:8080/websocket")

	-- local function wsSendTextOpen(strData)
	-- 	if cc.WEBSOCKET_STATE_OPEN == self.wsSendText:getReadyState() then
	-- 		self.wsSendText:sendString("Hello WebSocket中文--,\0 I'm\0 a\0 binary\0 message\0.")
	-- 	end
 --        cclog("Send Text WS was opened.")
 --    end
	-- local receiveTextTimes = 0
 --    local function wsSendTextMessage(strData)
 --        receiveTextTimes= receiveTextTimes + 1

 --        if "table" == type(strData) then        	
	-- 		local length = table.getn(strData)
	--         local i = 1
	--         local strInfo = "msg: "
	--         for i = 1,length do
	--             if 0 == strData[i] then
	--                 strInfo = strInfo.."\'\\0\'"
	--             else
	--                 strInfo = strInfo..string.char(strData[i])
	--             end 
	--         end
	--         print(strInfo)
	--     else
	--     	print("mas: ", strData)
 --    	end

 --        --local strInfo= "response text msg: "..strData..", "..receiveTextTimes    
 --        --cclog(strInfo)
 --    end

 --    local function wsSendTextClose(strData)
 --        cclog("_wsiSendText websocket instance closed.")
 --        self.wsSendText = nil
 --    end

 --    local function wsSendTextError(strData)
 --        cclog("sendText Error was fired")
 --    end
 --    if nil ~= self.wsSendText then
 --        self.wsSendText:registerScriptHandler(wsSendTextOpen,cc.WEBSOCKET_OPEN)
 --        self.wsSendText:registerScriptHandler(wsSendTextMessage,cc.WEBSOCKET_MESSAGE)
 --        self.wsSendText:registerScriptHandler(wsSendTextClose,cc.WEBSOCKET_CLOSE)
 --        self.wsSendText:registerScriptHandler(wsSendTextError,cc.WEBSOCKET_ERROR)
 --    end
end

function MainScene:addShaderNode()
	local sprite = cc.Sprite:create("HelloWorld.png")
	--local sprite = cc.Label:createWithSystemFont("22", "", 100)
	local s = sprite:getContentSize()
	cclog("w: %d   h: %d", s.width, s.height)
    local pProgram = cc.GLProgram:createWithFilenames("gray.vsh", "gray.fsh")
    pProgram:link()
    self.state = cc.GLProgramState:create(pProgram)
    sprite:setGLProgramState(self.state)
    sprite:setPosition(cc.p(500, 200))
    self:addChild(sprite)
end

function MainScene:addTableView()
	self._skillView = cc.TableView:create(cc.size(g_winSize.width / 3 - 50, 300))
	self._skillView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)	
	self._skillView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	self._skillView:setPosition(cc.p(50, 600))
	self:addChild(self._skillView)

	local function cellSizeForTable(view, idx)
	  	return 200, 50
	end

	local function tableCellAtIndex(view, idx)
	  	local cell = view:dequeueCell()
	  	if not cell then
			cell = cc.TableViewCell:new()

			local text = ccui.Text:create(idx, "", 30)
			text:setPosition(cc.p(100, 25))
			text:setTag(99)
			cell:addChild(text)
		else
			local text = cell:getChildByTag(99)
			text:setString(idx)
	  	end

	  	cclog("cell %d", idx)

	  	return cell
	end

	local function numberOfCellsInTableView(view)
		return 100
	end

    self._skillView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    self._skillView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
	self._skillView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)

	self._skillView:reloadData()
	self._skillView:updateCellAtIndex(20)
end


return MainScene
