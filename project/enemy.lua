local enemyKinds = {}

enemyKinds["swordsman"]= {
	letter = initiateLetter("S", {1, 0, 0, 1}),
	decideAction = function(enemy)
		return "hold"
	end
}

function initiateEnemy(map, x, y, kind)
	local enemyKind = enemyKinds[kind]
	
	local enemy = {character = nil, kind = kind, stance = "hold", active = false, formation = nil, formationX = 0, formationY = 0, formationFacing = 0}
	enemy.character = initiateCharacter(map, x, y, copyLetter(enemyKind.letter))
	return enemy
end