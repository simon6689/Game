potatoSprite = love.graphics.newImage("images/potato.png")

function loadObject(uid)
	local potato = {
		body = love.physics.newBody(world, potatoX, potatoY, "dynamic"),
		shape = love.physics.newPolygonShape(144/3,0, 191/3,33/3, 191/3,81/3, 152/3,134/3, 61/3,162/3, 18/3,121/3, 55/3,40/3),
		draw = function()
			--love.graphics.polygon("line", objects["potato"][uid].body:getWorldPoints(objects["potato"][uid].shape:getPoints()))
			love.graphics.draw(potatoSprite, objects["potato"][uid].body:getX(), objects["potato"][uid].body:getY(), objects["potato"][uid].body:getAngle(), 1/3, 1/3)
		end,
		click = function() end,
	}
	potato.fixture = love.physics.newFixture(potato.body, potato.shape)
	potato.fixture:setMask(1)
	return potato
end