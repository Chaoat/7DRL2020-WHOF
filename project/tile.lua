local tileProperties = {}
tileProperties['ground'] = {walkable = true, blockVision = false}
tileProperties['empty'] = {walkable = false, blockVision = true}

function innitiateTile(x, y, kind)
	local tile = {x = x, y = y, kind = tileKind, properties = tileProperties[kind]}
	return tile
end