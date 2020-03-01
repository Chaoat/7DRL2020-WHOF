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