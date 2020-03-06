local enemyDifficulties = {}
enemyDifficulties["swordsman"] = 1
enemyDifficulties["lancer"] = 2
enemyDifficulties["bowman"] = 3
enemyDifficulties["horseman"] = 8
enemyDifficulties["barrier"] = 0.5

local formations = {}

function preProcessFormations()
	for i = 1, #formations do
		local formation = formations[i]
		for j = 1, #formation.positions do
			formation.positions[j].x = -formation.positions[j].x
		end
	end
end

function getFormationTemplateInDifficultyRange(minDiff, maxDiff)
	local possibleFormations = {}
	for i = 1, #formations do
		local formation = formations[i]
		if formation.difficulty >= minDiff and formation.difficulty <= maxDiff then
			table.insert(possibleFormations, formation)
		end
	end
	
	local formation = randomFromTable(possibleFormations)
	return formation
end

--Behaviour Types are
--Chase: chase after the player in formation
--Intercept: chase after the player, predicting where they go
--Hold: Do not move from formation
--Loose: Spawn in formation then split up into individual
local function createFormationTemplate(difficulty, behaviour, positions, leniency)
	local countDifficulty = false
	if difficulty == nil then
		countDifficulty = true
		difficulty = 0
	end
	
	local radius = 0
	for i = 1, #positions do
		radius = math.max(radius, math.max(math.abs(positions[i].x), math.abs(positions[i].y)))
		
		if countDifficulty then
			difficulty = difficulty + enemyDifficulties[positions[i].kind]
		end
	end
	
	if not leniency then
		if behaviour == "chase" then
			leniency = 0.5
		else
			leniency = 0
		end
	end
	
	local formation = {size = 2*radius + 1, difficulty = difficulty, positions = positions, behaviour = behaviour, leniency = leniency}
	table.insert(formations, formation)
end

--..B
--.S.
--...
createFormationTemplate(nil, "chase", {
	{kind = "swordsman", x = 0, y = 0},
	{kind = "bowman", x = -1, y = -1},
})

--.S.
--..S
--.S.
createFormationTemplate(nil, "chase", {
	{kind = "swordsman", x = 1, y = 0},
	{kind = "swordsman", x = 0, y = -1},
	{kind = "swordsman", x = 0, y = 1}
})

--S.S
--.B.
--S.S
createFormationTemplate(nil, "chase", {
	{kind = "swordsman", x = 1, y = 1},
	{kind = "swordsman", x = 1, y = -1},
	{kind = "bowman", x = 0, y = 0},
	{kind = "swordsman", x = -1, y = -1},
	{kind = "swordsman", x = -1, y = 1}
})

--...
--LBL
--.L.
createFormationTemplate(nil, "chase", {
	{kind = "lancer", x = -1, y = 0},
	{kind = "lancer", x = 1, y = 0},
	{kind = "lancer", x = 0, y = -1},
	{kind = "bowman", x = 0, y = 0}
})

--.L.
--.L.
--.L.
createFormationTemplate(nil, "chase", {
	{kind = "lancer", x = 0, y = 0},
	{kind = "lancer", x = 0, y = -1},
	{kind = "lancer", x = 0, y = 1}
})

--.B.
--.B.
--.B.
createFormationTemplate(nil, "chase", {
	{kind = "bowman", x = 0, y = 0},
	{kind = "bowman", x = 0, y = -1},
	{kind = "bowman", x = 0, y = 1}
})

--.S.
--L..
--.S.
createFormationTemplate(nil, "chase", {
	{kind = "swordsman", x = 0, y = -1},
	{kind = "lancer", x = -1, y = 0},
	{kind = "swordsman", x = 0, y = 1}
})

--.S.
--S.B
--.S.
createFormationTemplate(nil, "chase", {
	{kind = "swordsman", x = 0, y = -1},
	{kind = "swordsman", x = -1, y = 0},
	{kind = "bowman", x = 1, y = 0},
	{kind = "swordsman", x = 0, y = 1}
})

--...
--LSB
--...
createFormationTemplate(nil, "chase", {
	{kind = "lancer", x = -1, y = 0},
	{kind = "swordsman", x = 0, y = 0},
	{kind = "bowman", x = 1, y = 0}
})

--S..
--L.B
--S..
createFormationTemplate(nil, "chase", {
	{kind = "lancer", x = -1, y = 0},
	{kind = "swordsman", x = -1, y = -1},
	{kind = "swordsman", x = -1, y = 1},
	{kind = "bowman", x = 1, y = 0}
})

--.....
--..S..
--L.S.L
--..S..
--.....
createFormationTemplate(nil, "chase", {
	{kind = "lancer", x = 2, y = 0},
	{kind = "swordsman", x = 0, y = -1},
	{kind = "swordsman", x = 0, y = 0},
	{kind = "swordsman", x = 0, y = -1},
	{kind = "lancer", x = -2, y = 0}
})

--..L..
--.....
--L.B.L
--.....
--..L..
createFormationTemplate(nil, "chase", {
	{kind = "lancer", x = -2, y = 0},
	{kind = "lancer", x = 0, y = -2},
	{kind = "bowman", x = 0, y = 0},
	{kind = "lancer", x = 0, y = 2},
	{kind = "lancer", x = 2, y = 0}
})

--.S...
--S..B.
--S..B.
--S..B.
--.S...
createFormationTemplate(nil, "chase", {
	{kind = "swordsman", x = -2, y = 0},
	{kind = "swordsman", x = -2, y = -1},
	{kind = "swordsman", x = -2, y = 1},
	{kind = "bowman", x = 1, y = -1},
	{kind = "bowman", x = 1, y = 0},
	{kind = "bowman", x = 1, y = 1},
	{kind = "swordsman", x = -1, y = 2},
	{kind = "swordsman", x = -1, y = -2}
})

--.L.S.
--.S.L.
--.L.S.
--.S.L.
--.L.S.
createFormationTemplate(nil, "chase", {
	{kind = "swordsman", x = -1, y = 2},
	{kind = "lancer", x = -1, y = 1},
	{kind = "swordsman", x = -1, y = 0},
	{kind = "lancer", x = -1, y = -1},
	{kind = "swordsman", x = -1, y = -2},
	{kind = "lancer", x = 1, y = 2},
	{kind = "swordsman", x = 1, y = 1},
	{kind = "lancer", x = 1, y = 0},
	{kind = "swordsman", x = 1, y = -1},
	{kind = "lancer", x = -1, y = -2}
})

--..L..
--.LB..
--.LB..
--.LB..
--..L..
createFormationTemplate(nil, "chase", {
	{kind = "lancer", x = 0, y = 2},
	{kind = "lancer", x = -1, y = 1},
	{kind = "lancer", x = -1, y = 0},
	{kind = "lancer", x = -1, y = -1},
	{kind = "lancer", x = 0, y = -2},
	{kind = "bowman", x = 0, y = -1},
	{kind = "bowman", x = 0, y = 0},
	{kind = "bowman", x = 0, y = 1}
})

--.S.S.
--LB...
--.....
--LB...
--.S.S.
createFormationTemplate(nil, "chase", {
	{kind = "swordsman", x = -2, y = 2},
	{kind = "swordsman", x = 0, y = 2},
	{kind = "bowman", x = -1, y = 1},
	{kind = "lancer", x = -2, y = 1},
	{kind = "lancer", x = -2, y = -1},
	{kind = "bowman", x = -1, y = -1},
	{kind = "swordsman", x = 0, y = -2},
	{kind = "swordsman", x = -2, y = -2}
})

--.L...
--.#B..
--.#...
--.#B..
--.L...
createFormationTemplate(nil, "guard", {
	{kind = "lancer", x = -1, y = 2},
	{kind = "lancer", x = -1, y = -2},
	{kind = "bowman", x = 0, y = 1},
	{kind = "bowman", x = 0, y = -1},
	{kind = "barrier", x = -1, y = -1},
	{kind = "barrier", x = -1, y = 0},
	{kind = "barrier", x = -1, y = 1}
})

--TestFormation
createFormationTemplate(0, "intercept", {
	{kind = "lancer", x = 0, y = -1},
	{kind = "lancer", x = 0, y = 0},
	{kind = "lancer", x = 0, y = 1},
})