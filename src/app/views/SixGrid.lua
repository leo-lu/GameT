local SixGrid = class("SixGrid", cc.load("mvc").ViewBase)

function SixGrid:onCreate()
	cclog("xxxxxxxxxxxxx")

	cc.Director:getInstance():setProjection(cc.DIRECTOR_PROJECTION3_D )

	self:DrawGrid()

	local VC = require("app.views.VitrualControl"):new()
	self:addChild(VC)
end

function SixGrid:DrawGrid()
	cclog("drow grid")

	local function hex_corner(center, size, i)
		local angle_deg = 60.0 * i + 30.0
		local angle_rad = 3.1415926 / 180.0 * angle_deg

		return cc.p(center.x + size * math.cos(angle_rad), 
					center.y + size * math.sin(angle_rad))
	end

	local drawNode = cc.DrawNode:create()
	self:addChild(drawNode)

	--高度 = r * 2
	--宽度 = sqrt(3)/2 * 高度
	local r = 35
	local y = 0
	local x = 0
	for n = 0, 34 do
		local offset = -0.5
		if 0 == math.mod(n, 2) then
			offset = 0
		else
			
		end
		if 0 == math.mod(n, 5) then


			y = y + 3/4
			x = offset
		end

		x = x + 1
		local arrDot = {}
		for i = 0, 5 do
			table.insert(arrDot, hex_corner(cc.p(r + x * math.sqrt(3)/2 * r * 2, r + y * r * 2), r, i))
		end

		drawNode:drawPolygon(arrDot, #arrDot, cc.c4b(0.2, 0.7, 0.2, 0.5), 1, cc.c4b(1, 0, 0, 0.5))
	end
end

return SixGrid