local enemyKinds = {}

enemyKinds["swordsman"]= {
	letter = innitiateLetter("S", {1, 0, 0, 1}),
	decideAction = function(enemy)
		return "hold"
	end
}

function innitiateEnemy(map, x, y, kind)
	local enemyKind = enemyKinds[kind]
	
	local enemy = {character = nil, kind = kind, stance = "hold", active = false}
	enemy.character = innitiateCharacter(map, x, y, copyLetter(enemyKind.letter))
end