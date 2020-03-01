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

local function createFormationTemplate(radius, difficulty, positions)
	local formation = {size = 2*radius + 1, difficulty = difficulty, positions = positions, behaviour = "chase"}
	table.insert(formations, formation)
end

--.S.
--..S
--.S.
createFormationTemplate(1, 0, {
	{kind = "swordsman", x = 1, y = 0},
	{kind = "swordsman", x = 0, y = -1},
	{kind = "swordsman", x = 0, y = 1}
})