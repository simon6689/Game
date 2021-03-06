function AI(dt)
	if objectList["scientist"] == nil then return false end
	for uid = 1, objectList["scientist"] do
		if removedObjects["scientist"] ~= nil and removedObjects["scientist"][uid] ~= nil then else
			ScientistAI(uid, dt)
		end
	end
end

function approachBunny(uid)
	scientist = objects["scientist"][uid]
	scientist.torso.body:setLinearVelocity(160, -210)
	scientist.rightleg.body:applyAngularImpulse(-2500)
end

function getAngle(uid)
	if objects["scientist"] ~= nil and objects["scientist"][uid] ~= nil then
		scientist = objects["scientist"][uid]
		angle = scientist.torso.body:getAngle()
		local pos = 1
		if angle < 0 then
			while angle < -(2*math.pi) do angle = angle + (2*math.pi) end
			pos = 1
		elseif angle > 0 then
			while angle > (2*math.pi) do angle = angle - (2*math.pi) end
			pos = -1
		end
		return angle
	end
end

function spinUpright(uid)
	if objects["scientist"] ~= nil and objects["scientist"][uid] ~= nil then
		scientist = objects["scientist"][uid]
		angle = getAngle(uid)
		if math.abs(angle) > 1 then
			scientist.torso.body:applyAngularImpulse(angle*-35000)
		else
			scientist.torso.body:applyAngularImpulse(angle*-30000)
		end
		
		if math.abs(angle) < 0.5 then 
			scientist.torso.body:applyAngularImpulse((angle-0.1)*-200000) 
		end

		if angle < 0.2 then
			scientist.rightleg.body:applyAngularImpulse(-750)
		end
	end
end

function isRotating(uid)
	if objects["scientist"] ~= nil and objects["scientist"][uid] ~= nil then
		if math.abs(getAngle(uid)) < 0.4 then
			return false
		else 
			return true
		end
	end
end

function kick(uid)
	if objects["scientist"] ~= nil and objects["scientist"][uid] ~= nil and dazed[uid] == -1 then
		scientist = objects["scientist"][uid]
		kickReset[uid] = 1
		scientist.rightleg.body:applyAngularImpulse(-1000000)
		scientist.torso.body:applyLinearImpulse(10000, 0)
		dazedImmune[uid] = 2
	end
end

function ScientistAI(uid, dt)
	if objects["scientist"] ~= nil and objects["scientist"][uid] ~= nil then
		dt = dt * 1.5
		scientist = objects["scientist"][uid]

		if kickReset[uid] == nil then kickReset[uid] = 0 end
		if dazedImmune[uid] == nil then dazedImmune[uid] = 0 end
		if dazedImmune[uid] > 0 then dazedImmune[uid] = dazedImmune[uid] - dt end
		if dazedImmune[uid] < 0 then dazedImmune[uid] = 0 end
		
		if scientist.torso ~= nil and scientist.leftleg ~= nil then
			x,head_y = scientist.head.body:getPosition()
			xvel, yvel = scientist.head.body:getLinearVelocity()
			
			maxvel = math.max(math.abs(xvel), math.abs(yvel))

			if kickReset[uid] > 0 then 
				kickReset[uid] = kickReset[uid] - dt 
				if kickReset[uid] < 0 then
					scientist.rightleg.body:applyAngularImpulse(200000)
					kickReset[uid] = 0
				end
			end
			if secondCounter[uid] == nil then secondCounter[uid] = 0 end
			if dazed[uid] == -1 then secondCounter[uid] = secondCounter[uid] + dt*0.75 end
			if secondCounter[uid] >= 5 then
				secondCounter[uid] = 0
				local X = scientist.torso.body:getX()
				if lastx[uid] == nil then lastx[uid] = 0 end
				if X > lastx[uid] then
					moved = X - lastx[uid]
				elseif X <= lastx[uid] then
					moved = lastx[uid] - X
				end
				if moved < 75 then kick(uid) end
				lastx[uid] = X
				traveledLastSecond[uid] = 0
			end
			
			if dazed[uid] == nil then dazed[uid] = 0 end
			if touching_ground[uid] == nil then touching_ground[uid] = 0 end

			if dazed[uid] > -0.95 then
				dazed[uid] = dazed[uid] - dt*0.6
				objects["scientist"][uid].headSprite = headSprites.dazed
			end

			if dazed[uid] <= 0 then
				if isScientistPart(grabbed.fixture) then
					objects["scientist"][uid].headSprite = headSprites.worried
					return
				elseif touching_ground[uid] ~= 0 then
					objects["scientist"][uid].headSprite = headSprites.normal
				end
			end

			if dazed[uid] <= -0.95 then dazed[uid] = -1 end
			if foot_touching_ground[uid] == nil then foot_touching_ground[uid] = 0 end

			if dazed[uid] == -1 or dazedImmune[uid] > 0 then
				objects["scientist"][uid].headSprite = headSprites.normal
				spinUpright(uid)
				if isRotating(uid) == false and foot_touching_ground[uid] == 2 then approachBunny(uid) end
			end
				-- addInfo("Feet On Ground ("..uid.."): "..foot_touching_ground[uid])
				-- addInfo("Touching Ground ("..uid.."): "..touching_ground[uid])
				-- addInfo("Dazed ("..uid.."): "..dazed[uid])
		end
	end
end

function scientistBeginContact(a, b, coll)
	if isScientistPart(a) or isScientistPart(b) then
		if isScientistPart(a) then
			if touching_ground[isScientistPart(a)] == nil then touching_ground[isScientistPart(a)] = 0 end
			if foot_touching_ground[isScientistPart(a)] == nil then foot_touching_ground[isScientistPart(a)] = 0 end
		elseif isScientistPart(b) then
			if touching_ground[isScientistPart(b)] == nil then touching_ground[isScientistPart(b)] = 0 end
			if foot_touching_ground[isScientistPart(b)] == nil then foot_touching_ground[isScientistPart(b)] = 0 end
		end
	end

	if isScientistPart(a) then
		if isScientistFoot(a) then
			if b == ground.fixture then
				foot_touching_ground[isScientistPart(a)] = foot_touching_ground[isScientistPart(a)] + 1
			end
		else
			if b == ground.fixture then
				touching_ground[isScientistPart(a)] = touching_ground[isScientistPart(a)] + 1
			end
		end
	elseif isScientistPart(b) then
		if isScientistFoot(b) then
			if a == ground.fixture then
				foot_touching_ground[isScientistPart(b)] = foot_touching_ground[isScientistPart(b)] + 1
			end
		else
			if a == ground.fixture then
				touching_ground[isScientistPart(b)] = touching_ground[isScientistPart(b)] + 1
			end
		end
	end


	if isScientistPart(a) then
		if maxvel > 800 then
			uid = isScientistPart(a)
			if dazed[uid] == nil then dazed[uid] = 0 end
			dazed[uid] = math.abs(math.min(dazed[uid] + ((maxvel-1000)/1000), 3))
		end
	end
	if isScientistPart(b) then
		if maxvel > 800 then
			uid = isScientistPart(b)
			if dazed[uid] == nil then dazed[uid] = 0 end
			dazed[uid] = math.abs(math.min(dazed[uid] + ((maxvel-1000)/1000), 3))
		end
	end

end

function scientistEndContact(a, b, coll)
if isScientistPart(a) then
		if isScientistFoot(a) then
			if b == ground.fixture then
				foot_touching_ground[isScientistPart(a)] = foot_touching_ground[isScientistPart(a)] - 1
			end
		else
			if b == ground.fixture then
				touching_ground[isScientistPart(a)] = touching_ground[isScientistPart(a)] - 1
			end
		end
	elseif isScientistPart(b) then
		if isScientistFoot(b) then
			if a == ground.fixture then
				foot_touching_ground[isScientistPart(b)] = foot_touching_ground[isScientistPart(b)] - 1
			end
		else
			if a == ground.fixture then
				touching_ground[isScientistPart(b)] = touching_ground[isScientistPart(b)] - 1
			end
		end
	end
end

return AI