local structureTemplates = {}

function spawnStructure(map, x, y, structureName, direction)
	local template = structureTemplates[structureName]
	
	for i = 1, template.size do
		for j = 1, template.size do
			local offX, offY = orthogRotate(i - math.ceil(template.size/2), j - math.ceil(template.size/2), direction)
			
			local targetX = x + offX
			local targetY = y + offY
			local tileKind = template.tiles[i][j]
			if tileKind then
				local letter = initiateLetter(template.symbols[i][j], template.colours[i][j])
				letter.facing = direction
				map.tiles[targetX][targetY] = initiateTile(targetX, targetY, tileKind, letter)
			end
		end
	end
end

local function newStructureTemplate(name, rotatable, colours, tiles, symbols, tileColours)
	local size = #tiles
	local template = {name = name, size = size, rotatable = rotatable, colours = {}, tiles = {}, symbols = {}}
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
end

--Tree
newStructureTemplate("tree", false, {
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
newStructureTemplate("smallwall", true, {
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
newStructureTemplate("smallfire", false, {
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
newStructureTemplate("smalltallwall", true, {
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
newStructureTemplate("smalltent", true, {
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