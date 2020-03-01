local structureTemplates = {}

function spawnStructure(map, x, y, structureName, direction)
	local template = structureTemplates[structureName]
	
	for i = 1, template.size do
		for j = 1, template.size do
			local targetX = x + i - math.ceil(template.size/2)
			local targetY = y + j - math.ceil(template.size/2)
			local tileKind = template.tiles[i][j]
			if tileKind then
				map.tiles[targetX][targetY] = innitiateTile(targetX, targetY, tileKind, innitiateLetter(template.symbols[i][j], template.colours[i][j]))
			end
		end
	end
end

local function newStructureTemplate(name, radius, colours, tiles, symbols, tileColours)
	local size = 2*radius + 1
	local template = {name = name, size = size, colours = {}, tiles = {}, symbols = {}}
	for i = 1, size do
		template.colours[i] = {}
		template.tiles[i] = {}
		template.symbols[i] = {}
		for j = 1, size do
			template.colours[i][j] = colours[tileColours[j][i]]
			template.symbols[i][j] = symbols[j][i]
			
			local tile = ""
			if tiles[j][i] == "n" then
				tile = nil
			elseif tiles[j][i] == "t" then
				tile = "tree"
			end
			template.tiles[i][j] = tile
		end
	end
	
	structureTemplates[name] = template
end

newStructureTemplate("tree", 2, {
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