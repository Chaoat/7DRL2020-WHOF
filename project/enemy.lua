local enemyKinds = {}

enemyKinds["swordsman"]= {
	letter = innitiateLetter("S", {1, 0, 0, 1}),
	decideAction = function(enemy)
		return "hold"
	end
}

function innitiateEnemy(map, x, y, kind)
	local enemyKind = enemyKinds[kind]
	
	local enemy = {character = nil, kind = kind, stance = "hold", active = false, formation = nil, formationX = 0, formationY = 0}
	enemy.character = innitiateCharacter(map, x, y, copyLetter(enemyKind.letter))
	return enemy
end