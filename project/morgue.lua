local morgueFileName = "morgue"

function saveDeathToMorgue(date, distance, deathCause)
	love.filesystem.append(morgueFileName, date .. "#" .. distance .. "#" .. deathCause .. "\n")
end

function getDeathList()
	if not love.filesystem.getInfo(morgueFileName) then
		return {}
	end
	
	local list = {}
	
	for line in love.filesystem.lines(morgueFileName) do
		if #line > 0 then
			local i = 1
			local death = {distance = 0, cause = "", date = ""}
			for field in string.gmatch(line, "[^#]+") do
				if i == 1 then
					death.date = field
				elseif i == 2 then
					death.distance = tonumber(field)
				elseif i == 3 then
					death.cause = field
				end
				i = i + 1
			end
			table.insert(list, death)
		end
	end
	
	local sortedList = {}
	while #list > 0 do
		local maxDist = -1
		local maxI = 0
		for i = 1, #list do
			if list[i].distance > maxDist then
				maxI = i
				maxDist = list[i].distance
			end
		end
		
		table.insert(sortedList, list[maxI])
		table.remove(list, maxI)
	end
	
	return sortedList
end