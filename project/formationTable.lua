local formations = {}

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
local function createFormationTemplate(radius, difficulty, behaviour, positions)
	local formation = {size = 2*radius + 1, difficulty = difficulty, positions = positions, behaviour = behaviour}
	table.insert(formations, formation)
end

--.S.
--..S
--.S.
createFormationTemplate(1, 0, "chase", {
	{kind = "swordsman", x = 1, y = 0},
	{kind = "swordsman", x = 0, y = -1},
	{kind = "swordsman", x = 0, y = 1}
})

--.L.
--.L.
--.L.
createFormationTemplate(1, 1, "chase", {
	{kind = "lancer", x = 0, y = 0},
	{kind = "lancer", x = 0, y = -1},
	{kind = "lancer", x = 0, y = 1}
})