local _M = {
	_VERSION = 1.0
}

--有限状态机
function _M:createFSM()
	local fsm = {
		activeState = nil
	}

	function fsm:setState(sFun)
		self.activeState = sFun
	end

	function fsm:getState()
		return self.activeState
	end

	function fsm:update(obj, ...)
		if nil ~= self.activeState then
			return self.activeState(obj, ...)
		end
	end

	return fsm
end

--基于堆栈的有限状态机
function _M:createStackFMS()
	
end

return _M