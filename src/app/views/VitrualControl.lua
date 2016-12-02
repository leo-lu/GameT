local VituualControl = class("VituualControl", cc.Layer)  
  
function VituualControl:ctor(app, name)
    if self.onCreate then self:onCreate() end
end  
  
function VituualControl:onTouchesEnded(touches, event )  
    self:_deactive()  
end  
  
function VituualControl:onTouchesBegan(touches, event )
    local touch = touches[1]
    self.start_pos = cc.p(touch:getLocation())
    self:_active(self.start_pos)  
end  
  
function VituualControl:onTouchesMove(touches, event )
    local touch = touches[1]
    local pos = cc.p(touch:getLocation())
    local distance = cc.pGetDistance(self.start_pos, pos)  
    local direction = cc.pNormalize(cc.pSub(pos, self.start_pos))  
    self:_update(direction, distance)
end  
  
  
function VituualControl:onCreate()  
    self.joystick = cc.Sprite:create( "res/vc_ctrl_small.png")
    self.joystick:setScale(0.2,0.2)
    self.joystick_bg = cc.Sprite:create( "res/vc_bg_small.png")
    self.joystick_bg:setScale(0.3,0.3)
    self:addChild(self.joystick_bg)  
    self:addChild(self.joystick)
  
    local listener = cc.EventListenerTouchAllAtOnce:create()  
      
    listener:registerScriptHandler(function(...) self:onTouchesBegan(...) end,cc.Handler.EVENT_TOUCHES_BEGAN)
    listener:registerScriptHandler(function(...) self:onTouchesEnded(...) end,cc.Handler.EVENT_TOUCHES_ENDED)
    listener:registerScriptHandler(function(...) self:onTouchesMove(...) end,cc.Handler.EVENT_TOUCHES_MOVED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

    local btnA = ccui.Button:create("btn_a_small.png")
    btnA:setPosition(cc.p(g_winSize.width - 60, 25))
    self:addChild(btnA)
    btnA:addClickEventListener(function(sender)
        self.curDir = nil
        self.disCallback(nil, 1)
    end)

    local btnB = ccui.Button:create("btn_b_small.png")
    btnB:setPosition(cc.p(g_winSize.width - 25, 60))
    self:addChild(btnB)
    btnB:addClickEventListener(function(sender)
        self.curDir = nil
        self.disCallback(nil, 2)
    end)
end  
  
function VituualControl:_active(pos)  
    self.joystick:setPosition(pos)  
    self.joystick_bg:setPosition(pos)  
    self.joystick:setVisible(true)  
    self.joystick_bg:setVisible(true)  
end  
  
function VituualControl:_deactive(pos)
    self.joystick:setVisible(false)  
    self.joystick_bg:setVisible(false)

    self.curDir = nil
    self.disCallback({x = 0, y = 0})
end  
  
function VituualControl:_update(direction, distance)
    local start = cc.p(self.joystick_bg:getPosition())  
    if distance < 32 then
        self.joystick:setPosition(cc.pAdd(start, (cc.pMul(direction, distance))))  
    elseif distance > 96 then
        self.joystick:setPosition(cc.pAdd(start, (cc.pMul(direction, 64))))  
    else
        self.joystick:setPosition(cc.pAdd(start, (cc.pMul(direction, 32))))
    end

    --0表示无位移
    local dir = {x = 0, y = 0}
    --判断是否横向
    local H = math.abs(direction.x) >= math.abs(direction.y)
    if H then
        if nil ~= self.disCallback then
            if direction.x > 0 then
                dir.x = 1
            elseif direction.x < 0 then
                dir.x = -1
            else
                dir.x = 0
            end
            
            self.disCallback(dir)
        end
    end
    --print("seayoung udpate", direction.x, direction.y, distance)
end

function VituualControl:setDisCallback(callback)
    self.disCallback = callback
end

return VituualControl