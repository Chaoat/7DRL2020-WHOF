function roundFloat(number)
	local remainder = number%1
	if remainder >= 0.5 then
		return math.ceil(number)
	else
		return math.floor(number)
	end
end

function angleBetweenVectors(a, b, x, y)
	return math.atan2(y-b, x-a)
end
	
function randomFromTable(list)
	local i = math.ceil(math.random()*#list)
	return list[i], i
end

function distanceBetweenAngles(rawangle1, rawangle2)
	local angle1 = rawangle1
	local angle2 = rawangle2
	
	if angle1 ~= angle2 then
		while math.abs(angle1) > math.pi do
			if angle1 < 0 then
				angle1 = angle1 + 2*math.pi
			else
				angle1 = angle1 - 2*math.pi
			end
		end
		
		while math.abs(angle2) > math.pi do
			if angle2 < 0 then
				angle2 = angle2 + 2*math.pi
			else
				angle2 = angle2 - 2*math.pi
			end
		end
		
		local simpleDistance = angle2 - angle1
		local loopDistance = 0
		if angle1 > 0 then
			loopDistance = (math.pi - angle1) + (math.pi + angle2)
		else
			loopDistance = (math.pi - angle2) + (math.pi + angle1)
		end
		
		if math.abs(simpleDistance) < loopDistance then
			return math.abs(simpleDistance)
		else
			return loopDistance
		end
	else
		return 0
	end
end

function simplifyAngle(angle)
	while math.abs(angle) > math.pi do
		if angle < 0 then
			angle = angle + 2*math.pi
		else
			angle = angle - 2*math.pi
		end
	end
	return angle
end

function findAngleDirection(rawangle1, rawangle2)
	rawangle1 = simplifyAngle(rawangle1)
	rawangle2 = simplifyAngle(rawangle2)
	
	if rawangle1 ~= rawangle2 then	
		local simpleDistance = rawangle2 - rawangle1
		local loopDistance = 0
		if rawangle1 > 0 then
			loopDistance = (math.pi - rawangle1) + (math.pi + rawangle2)
		else
			loopDistance = (math.pi - rawangle2) + (math.pi + rawangle1)
		end
		
		if math.abs(simpleDistance) < loopDistance then
			return simpleDistance/math.abs(simpleDistance)
		else
			if rawangle1 > 0 then
				return 1
			else
				return -1
			end
		end
	else
		return 0
	end
end

function findAngleBetween(a1, a2, ratio)
	return a1 + ratio*findAngleDirection(a1, a2)*distanceBetweenAngles(a1, a2)
end

function randBetween(n1, n2)
	local diff = n2 - n1
	return n1 + diff*math.random()
end

function blendColours(c1, c2, ratio)
	local otherR = 1 - ratio
	return {c1[1]*ratio + c2[1]*otherR, c1[2]*ratio + c2[2]*otherR, c1[3]*ratio + c2[3]*otherR, c1[4]*ratio + c2[4]*otherR}
end

--Round the angle into a cardinal direction angle
function cardinalRound(angle)
	while angle < -math.pi do
		angle = angle + 2*math.pi
	end
	while angle >= math.pi do
		angle = angle - 2*math.pi
	end
	
	angle = (math.pi/4)*roundFloat(angle/(math.pi/4))
	return angle
end

function orthogDistance(x1, y1, x2, y2)
	return math.max(math.abs(x2 - x1), math.abs(y2 - y1))
end

--Rotates a point by an angle, maintaining square space
function orthogRotate(x, y, angle)
	local curAngle = math.atan2(y, x)
	local dist = orthogDistance(0, 0, x, y)
	
	angle = curAngle + angle
	local boundAngle = math.min(angle%(math.pi/2), math.pi/2 - angle%(math.pi/2))
	
	local distMultiple = math.sqrt(1 + math.tan(boundAngle))
	
	local returnX = roundFloat(distMultiple*dist*math.cos(angle))
	local returnY = roundFloat(distMultiple*dist*math.sin(angle))
	return returnX, returnY
end

function getRelativeGridPositionFromAngle(angle)
	angle = cardinalRound(angle)
	local xDir = roundFloat(math.cos(angle))
	local yDir = roundFloat(math.sin(angle))
	return xDir, yDir
end

function getCardinalPointInDirection(x, y, angle, dist)
	return x + dist*roundFloat(math.cos(angle)), y + dist*roundFloat(math.sin(angle))
end