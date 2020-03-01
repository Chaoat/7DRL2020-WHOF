--Create a formation from a list of enemies
function innitiateFormation(enemyList, x, y, size, facing)
	local formation = {members = {}, x = x, y = y, size = size, facing = facing}
	for i = 1, #enemyList do
		local enemy = enemyList[i]
		
		local posX = enemy.character.x - x
		local posY = enemy.character.y - y
		local facing = enemy.character.facing - facing
		table.insert(formation.members, {enemy = enemy, posX = posX, posY = posY, facing = facing})
	end
end