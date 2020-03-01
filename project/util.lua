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