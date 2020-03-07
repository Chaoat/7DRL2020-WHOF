local morgueFileName = "morgue"

function saveDeathToMorgue(date, distance, deathCause)
	love.filesystem.append(morgueFileName, date .. "#" .. distance .. "#" .. deathCause .. "\n")
end

function getDeathList()
	local deaths = NewHeap(function(heap, a, b)
		return heap.table[a][1] >= heap.table[b][1]
	end)
	
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
			PushToHeap(deaths, death.distance, death)
		end
	end
	
	local list = {}
	while #deaths.table > 0 do
		table.insert(list, PopFromHeap(deaths))
	end
	
	return list
end