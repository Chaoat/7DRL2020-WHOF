local structureTemplates = {}
local constructionList = {}

function getRandomConstructionName()
	return randomFromTable(constructionList)
end

function getStructureSize(name)
	return structureTemplates[name].size
end

function spawnStructure(map, x, y, structureName, direction)
	local template = structureTemplates[structureName]
	
	if not template.rotatable then
		direction = 0
	end
	
	--CheckWillFit
	for i = 1, template.size do
		for j = 1, template.size do
			local offX, offY = orthogRotate(i - math.ceil(template.size/2), j - math.ceil(template.size/2), direction)
			if template.tiles[i][j] then
				local targetX = x + offX
				local targetY = y + offY
				if not checkTileWalkable(getMapTile(map, targetX, targetY)) then
					return false
				end
			end
		end
	end
	
	for i = 1, template.size do
		for j = 1, template.size do
			local offX, offY = orthogRotate(i - math.ceil(template.size/2), j - math.ceil(template.size/2), direction)
			
			local targetX = x + offX
			local targetY = y + offY
			local tileKind = template.tiles[i][j]
			if tileKind then
				local letter = initiateLetter(template.symbols[i][j], template.colours[i][j], {0.05, 0.05, 0.05, 1})
				letter.facing = direction
				map.tiles[targetX][targetY] = initiateTile(targetX, targetY, tileKind, letter)
			end
		end
	end
	
	if template.foliage then
		for i = -math.ceil(template.foliage.size/2), math.floor(template.foliage.size/2) do
			for j = -math.ceil(template.foliage.size/2), math.floor(template.foliage.size/2) do
				local distFromCenter = math.sqrt(i^2 + j^2)
				if distFromCenter <= template.foliage.size/2 then
					local tile = getMapTile(map, x + i, y + j)
					local distRatio = distFromCenter/(template.foliage.size/2)
					local height = (1 - distRatio)*template.foliage.maxHeight + distRatio*template.foliage.minHeight
					
					local spawn = true
					if tile.foliage then
						if tile.foliage.windWave > height then
							spawn = false
						end
					end
					if math.random() >= (1 - distRatio) + distRatio*template.foliage.density then
						spawn = false
					end
					
					if spawn then
						tile.foliage = initiateFoliage(template.foliage.character, blendColours(template.foliage.outerColour, template.foliage.innerColour, distRatio), height)
					end
				end
			end
		end
	end
	
	return true
end

local function newStructureTemplate(name, natural, rotatable, colours, tiles, symbols, tileColours, foliage)
	local size = #tiles
	local template = {name = name, size = size, natural = natural, rotatable = rotatable, colours = {}, tiles = {}, symbols = {}, foliage = foliage}
	for i = 1, size do
		template.colours[i] = {}
		template.tiles[i] = {}
		template.symbols[i] = {}
		for j = 1, size do
			template.colours[i][j] = colours[tileColours[j][i]]
			template.symbols[i][j] = symbols[j][i]
			
			local tile = ""

			if tiles[j][i] == "n" then
				--nil tile, can be moved through
				tile = nil
			elseif tiles[j][i] == "t" then
				--tree tile cant be moved through
				tile = "tree"
			elseif tiles[j][i] == "b" then
				--building tile cant be moved through
				tile = "building"
			end
			template.tiles[i][j] = tile
		end
	end
	
	structureTemplates[name] = template
	if not natural then
		table.insert(constructionList, name)
	end
end


--oakTree
newStructureTemplate("oakTree", true, false, {
	a = {166/255, 143/255, 96/255, 1}
}, {
	{"n", "t", "n"},
	{"t", "t", "t"},
	{"n", "t", "n"}
}, {
	{" ", "n", " "},
	{"n", "0", "n"},
	{" ", "n", " "}
}, {
	{" ", "a", " "},
	{"a", "a", "a"},
	{" ", "a", " "}
}, {size = 8, character = "O", density = 0.8, minHeight = 0.8, maxHeight = 1.3, innerColour = {167/255, 167/255, 86/255, 0.5}, outerColour = {72/255, 72/255, 32/255, 0.5}}
)
--aspenTree
newStructureTemplate("aspenTree", true, false, {
	a = {134/255, 158/255, 145/255, 1}
}, {
	{"t"}
}, {
	{"o"}
}, {
	{"a"}
}, {size = 4, character = "*", density = 0.5, minHeight = 0.5, maxHeight = 1, innerColour = {129/255, 207/255, 36/255, 0.5}, outerColour = {70/255, 180/255, 30/255, 0.5}}
)
--birchTree
newStructureTemplate("birchTree", true, false, {
	a = {130/255, 150/255, 124/255, 1}
}, {
	{"t"}
}, {
	{"0"}
}, {
	{"a"}
}, {size = 5, character = "#", density = 0.7, minHeight = 0.4, maxHeight = 1.5, innerColour = {148/255, 214/255, 51/255, 0.5}, outerColour = {51/255, 106/255, 3/255, 0.5}}
)
--pineTree
newStructureTemplate("pineTree", true, false, {
	a = {67/255, 55/255, 39/255, 1}
}, {
	{"t"}
}, {
	{"0"}
}, {
	{"a"}
}, {size = 6, character = "+", density = 1, minHeight = 0.4, maxHeight = 1.2, innerColour = {187/255, 218/255, 121/255, 0.5}, outerColour = {25/255, 38/255, 11/255, 0.5}}
)
newStructureTemplate("oldTree", true, false, {
	a = {80/255, 1, 0, 1},
	b = {72/255, 229/255, 0, 1},
	c = {55/255, 175/255, 0, 1},
	d = {47/255, 150/255, 0, 1}
}, {
	{"n", "t", "t", "t", "n"},
	{"t", "t", "t", "t", "t"},
	{"t", "t", "t", "t", "t"},
	{"t", "t", "t", "t", "t"},
	{"n", "t", "t", "t", "n"}
}, {
	{" ", "/", "/", "/", " "},
	{"\\", "\\", "|", "/", "\\"},
	{"\\", "-", "+", "-", "\\"},
	{"\\", "/", "|", "\\", "\\"},
	{" ", "/", "/", "/", " "}
}, {
	{" ", "d", "c", "d", " "},
	{"d", "c", "b", "c", "d"},
	{"c", "b", "a", "b", "c"},
	{"d", "c", "b", "c", "d"},
	{" ", "d", "c", "d", " "}
}
)

--Small Wall
newStructureTemplate("smallwall", false, true, {
	a = {51/255, 51/255, 51/255, 1},
	b = {77/255, 77/255, 77/255, 1}
}, {
	{"n", "n", "n", "n", "n"},
	{"n", "n", "n", "n", "n"},
	{"b", "b", "b", "b", "b"},
	{"n", "n", "n", "n", "n"},
	{"n", "n", "n", "n", "n"}
}, {
	{" ", " ", " ", " ", " "},
	{" ", " ", " ", " ", " "},
	{"=", "=", "=", "=", "="},
	{" ", " ", " ", " ", " "},
	{" ", " ", " ", " ", " "}
}, {
	{" ", " ", " ", " ", " "},
	{" ", " ", " ", " ", " "},
	{"b", "a", "b", "a", "b"},
	{" ", " ", " ", " ", " "},
	{" ", " ", " ", " ", " "}
}
)

--Small Campfire
newStructureTemplate("smallfire", false, false, {
	a = {217/255, 0, 0, 1},
	b = {51/255, 51/255, 51/255, 1}
}, {
	{"n", "b", "n"},
	{"b", "b", "b"},
	{"n", "b", "n"},
}, {
	{" ", "o", " "},
	{"o", "#", "o"},
	{" ", "o", " "},
}, {
	{" ", "b", " "},
	{"b", "a", "b"},
	{" ", "b", " "},
}
)

--Small tall wall
newStructureTemplate("smalltallwall", false, true, {
	a = {51/255, 51/255, 51/255, 1},
	b = {77/255, 77/255, 77/255, 1}
}, {
	{"n", "n", "b", "n", "n"},
	{"n", "n", "b", "n", "n"},
	{"n", "n", "b", "n", "n"},
	{"n", "n", "b", "n", "n"},
	{"n", "n", "b", "n", "n"}
}, {
	{" ", " ", "I", " ", " "},
	{" ", " ", "I", " ", " "},
	{" ", " ", "I", " ", " "},
	{" ", " ", "I", " ", " "},
	{" ", " ", "I", " ", " "}
}, {
	{" ", " ", "b", " ", " "},
	{" ", " ", "a", " ", " "},
	{" ", " ", "b", " ", " "},
	{" ", " ", "a", " ", " "},
	{" ", " ", "b", " ", " "}
}
)

--Small tent
newStructureTemplate("smalltent", false, false, {
	a = {1, 1, 1, 1},
	b = {121/255, 121/255, 121/255, 1},
	c = {51/255, 51/255, 51/255, 1}
}, {
	{"b", "b", "b", "b", "n"},
	{"b", "b", "b", "b", "n"},
	{"b", "b", "b", "b", "n"},
	{"b", "b", "b", "b", "n"},
	{"n", "n", "n", "n", "n"}
}, {
	{"/", "-", "-", "\\", " "},
	{"|", "\\", "/", "|", " "},
	{"|", "/", "\\", "|", " "},
	{"\\", "-", "-", "/", " "},
	{" ", " ", " ", " ", " "}
}, {
	{"c", "b", "b", "c", " "},
	{"b", "a", "a", "b", " "},
	{"b", "a", "a", "b", " "},
	{"c", "b", "b", "c", " "},
	{" ", " ", " ", " ", " "}
}
)

--large tent
newStructureTemplate("largetent", false, flase, {
	a = {1, 1, 1, 1},
	b = {121/255, 121/255, 121/255, 1},
	c = {51/255, 51/255, 51/255, 1}
}, {
	{"n", "b", "b", "b", "b", "b", "n"},
	{"b", "b", "b", "b", "b", "b", "b"},
	{"b", "b", "b", "b", "b", "b", "b"},
	{"b", "b", "b", "b", "b", "b", "b"},
	{"b", "b", "b", "b", "b", "b", "b"},
	{"b", "b", "b", "b", "b", "b", "b"},
	{"n", "b", "b", "b", "b", "b", "n"}
}, {
	{" ", "/", "-", "-", "-", "\\", " "},
	{"/", "\\", "-", " ", " ", "/", "\\"},
	{"|", "-", "\\", "-", "/", " ", "|"},
	{"|", "-", "|", "O", "|", " ", "|"},
	{"|", "-", "/", "-", "\\", " ", "|"},
	{"\\", "/", "-", " ", " ", "\\", "/"},
	{" ", "\\", "-", "-", "-", "/", " "}
}, {
	{" ", "c", "b", "b", "b", "c", " "},
	{"c", "a", " ", " ", " ", "a", "c"},
	{"b", " ", "a", "a", "a", " ", "b"},
	{"b", " ", "a", "a", "a", " ", "b"},
	{"b", " ", "a", "a", "a", " ", "b"},
	{"c", "a", " ", " ", " ", "a", "c"},
	{" ", "c", "b", "b", "b", "c", " "}
}
)

--huge tent
newStructureTemplate("hugetent", false, false, {
	a = {1, 1, 1, 1},
	b = {121/255, 121/255, 121/255, 1},
	c = {51/255, 51/255, 51/255, 1}
}, {
	{"n", "n", "b", "b", "b", "b", "n", "n", "n"},
	{"n", "b", "b", "b", "b", "b", "b", "b", "n"},
	{"b", "b", "b", "b", "b", "b", "b", "b", "b"},
	{"b", "b", "b", "b", "b", "b", "b", "b", "b"},
	{"b", "b", "b", "b", "b", "b", "b", "b", "b"},
	{"b", "b", "b", "b", "b", "b", "b", "b", "b"},
	{"b", "b", "b", "b", "b", "b", "n", "b", "b"},
	{"n", "b", "b", "b", "b", "b", "b", "b", "n"},
	{"n", "n", "b", "b", "b", "b", "b", "n", "n"}
}, {
	{" ", " ", "/", "-", "-", "-", "\\", " ", " "},
	{" ", "/", "-", " ", " ", " ", " ", "\\", " "},
	{"/", "-", "\\", "-", " ", " ", "/", " ", "\\"},
	{"|", "-", " ", "/", "-", "\\", " ", " ", "|"},
	{"|", "-", " ", "|", "O", "|", " ", " ", "|"},
	{"|", " ", "-", "\\", "-", "/", " ", " ", "|"},
	{"\\", "-", "/", "-", " ", " ", "\\", " ", "/"},
	{" ", "\\", "-", " ", " ", " ", " ", "/", " "},
	{" ", " ", "\\", "-", "-", "-", "/", " ", " "}
}, {
	{" ", " ", "c", "b", "b", "b", "c", " ", " "},
	{" ", "c", " ", " ", " ", " ", " ", "c", " "},
	{"c", " ", "b", " ", " ", " ", "b", " ", "c"},
	{"b", " ", " ", "a", "a", "a", " ", " ", "b"},
	{"b", " ", " ", "a", "a", "a", " ", " ", "b"},
	{"b", " ", " ", "a", "a", "a", " ", " ", "b"},
	{"c", " ", "b", " ", " ", " ", "b", " ", "c"},
	{" ", "c", " ", " ", " ", " ", " ", "c", " "},
	{" ", " ", "c", "b", "b", "b", "c", " ", " "}
}
)

--double huge tent
newStructureTemplate("doublehugetent", false, true, {
	a = {1, 1, 1, 1},
	b = {121/255, 121/255, 121/255, 1},
	c = {51/255, 51/255, 51/255, 1}
}, {
	{"n", "n", "b", "b", "b", "b", "n", "n", "n", " ", " ", " ", " ", " "},
	{"n", "b", "b", "b", "b", "b", "b", "b", "n", " ", " ", " ", " ", " "},
	{"b", "b", "b", "b", "b", "b", "b", "b", "b", " ", " ", " ", " ", " "},
	{"b", "b", "b", "b", "b", "b", "b", "b", "b", " ", " ", " ", " ", " "},
	{"b", "b", "b", "b", "b", "b", "b", "b", "b", " ", " ", " ", " ", " "},
	{"b", "b", "b", "b", "b", "b", "b", "b", "b", " ", " ", " ", " ", " "},
	{"b", "b", "b", "b", "b", "b", "n", "b", "b", "b", "b", "b", "b", " "},
	{"n", "b", "b", "b", "b", "b", "b", "b", "b", "b", "b", "b", "b", "b"},
	{"n", "n", "b", "b", "b", "b", "b", "b", "b", "b", "b", "b", "b", "b"},
	{" ", " ", " ", " ", " ", " ", " ", "b", "b", "b", "b", "b", "b", "b"},
	{" ", " ", " ", " ", " ", " ", " ", "b", "b", "b", "b", "b", "b", "b"},
	{" ", " ", " ", " ", " ", " ", " ", " ", "b", "b", "b", "b", "b", " "},
	{" ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " "},
	{" ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " "}
}, {
	{" ", " ", "/", "-", "-", "-", "\\", " ", " ", " ", " ", " ", " ", " "},
	{" ", "/", "-", " ", " ", " ", " ", "\\", " ", " ", " ", " ", " ", " "},
	{"/", "-", "\\", "-", " ", " ", "/", " ", "\\", " ", " ", " ", " ", " "},
	{"|", "-", " ", "/", "-", "\\", " ", " ", "|", " ", " ", " ", " ", " "},
	{"|", "-", " ", "|", "O", "|", " ", " ", "|", " ", " ", " ", " ", " "},
	{"|", " ", "-", "\\", "-", "/", " ", " ", "|", "-", "-", "-", "\\", " "},
	{"\\", "-", "/", "-", " ", " ", "\\", " ", "/", " ", " ", " ", "/", "\\"},
	{" ", "\\", "-", " ", " ", " ", " ", "/", " ", "\\", "-", "/", " ", "|"},
	{" ", " ", "\\", "-", "-", "-", "/", "|", " ", "|", "O", "|", " ", "|"},
	{" ", " ", " ", " ", " ", " ", " ", "|", " ", "/", "-", "\\", " ", "|"},
	{" ", " ", " ", " ", " ", " ", " ", "\\", "/", " ", " ", " ", "\\", "/"},
	{" ", " ", " ", " ", " ", " ", " ", " ", "\\", "-", "-", "-", "/", " "},
	{" ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " "},
	{" ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " "}
}, {
	{" ", " ", "c", "b", "b", "b", "c", " ", " ", " ", " ", " ", " ", " "},
	{" ", "c", " ", " ", " ", " ", " ", "c", " ", " ", " ", " ", " ", " "},
	{"c", " ", "b", " ", " ", " ", "b", " ", "c", " ", " ", " ", " ", " "},
	{"b", " ", " ", "a", "a", "a", " ", " ", "b", " ", " ", " ", " ", " "},
	{"b", " ", " ", "a", "a", "a", " ", " ", "b", " ", " ", " ", " ", " "},
	{"b", " ", " ", "a", "a", "a", " ", " ", "b", "b", "b", "b", "c", " "},
	{"c", " ", "b", " ", " ", " ", "b", " ", "c", " ", " ", " ", "b", "c"},
	{" ", "c", " ", " ", " ", " ", " ", "c", " ", "a", "a", "a", " ", "b"},
	{" ", " ", "c", "b", "b", "b", "c", "b", " ", "a", "a", "a", " ", "b"},
	{" ", " ", " ", " ", " ", " ", " ", "b", " ", "a", "a", "a", " ", "b"},
	{" ", " ", " ", " ", " ", " ", " ", "c", "b", " ", " ", " ", "b", "c"},
	{" ", " ", " ", " ", " ", " ", " ", " ", "c", "b", "b", "b", "c", " "},
	{" ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " "},
	{" ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " "}
}
)

--Large Campfire
newStructureTemplate("largefire", false, false, {
	a = {217/255, 0, 0, 1},
	b = {51/255, 51/255, 51/255, 1},
	c = {217/255, 108/255, 0, 1},
	d = {1, 204/255, 51, 1}
}, {
	{"b", "b", "b", "b", "n"},
	{"b", "b", "b", "b", "b"},
	{"b", "b", "b", "b", "b"},
	{"b", "b", "b", "b", "b"},
	{"n", "b", "b", "b", "n"}
}, {
	{" ", "o", "O", "o", " "},
	{"o", "#", "#", "#", "o"},
	{"O", "#", "#", "#", "O"},
	{"o", "#", "#", "#", "o"},
	{" ", "o", "O", "o", " "}
}, {
	{" ", "b", "b", "b", " "},
	{"b", "a", "c", "a", "b"},
	{"b", "c", "d", "c", "b"},
	{"b", "a", "c", "a", "b"},
	{" ", "b", "b", "b", " "}
}
)

--Trebuchet
newStructureTemplate("trebuchet", false, true, {
	a = {51/255, 51/255, 51/255, 1}, --Gray
	b = {128/255, 102/255, 64/255, 1}, --dark brown
	c = {51/255, 51/255, 51/255, 1} --light brown
}, {
	{"n", "b", "b", "n", "n", "n", "n", "n", "n"},
	{"n", "b", "n", "n", "n", "n", "n", "n", "n"},
	{"n", "n", "n", "b", "b", "b", "b", "n", "n"},
	{"n", "n", "b", "b", "b", "b", "b", "b", "n"},
	{"b", "b", "b", "b", "b", "b", "b", "b", "n"},
	{"n", "n", "b", "b", "b", "b", "b", "b", "n"},
	{"n", "n", "n", "b", "b", "b", "b", "n", "n"},
	{"n", "n", "n", "n", "n", "n", "n", "n", "n"},
	{"n", "n", "n", "n", "n", "n", "n", "n", "n"}
}, {
	{" ", "O", "O", " ", " ", " ", " ", " ", " "},
	{" ", "O", "-", " ", " ", " ", " ", " ", " "},
	{" ", "-", " ", "-", "-", "||", "-", " ", " "},
	{" ", "-", "|", " ", " ", "=", " ", "|", " "},
	{"C", "=", "=", "=", "=", "=", "=", "|", " "},
	{" ", " ", "|", " ", " ", "=", " ", "|", " "},
	{" ", "-", " ", "-", "-", "||", "-", " ", " "},
	{" ", " ", "-", " ", " ", " ", " ", " ", " "},
	{" ", " ", " ", " ", " ", " ", " ", " ", " "}
}, {
	{" ", "a", "a", " ", " ", " ", " ", " ", " "},
	{" ", "a", " ", " ", " ", " ", " ", " ", " "},
	{" ", " ", " ", "b", "b", "c", "b", " ", " "},
	{" ", " ", "b", " ", " ", "c", " ", "b", " "},
	{"c", "c", "c", "c", "c", "c", "c", "b", " "},
	{" ", " ", "b", " ", " ", "c", " ", "b", " "},
	{" ", " ", " ", "b", "b", "c", "b", " ", " "},
	{" ", " ", " ", " ", " ", " ", " ", " ", " "},
	{" ", " ", " ", " ", " ", " ", " ", " ", " "}
}
)