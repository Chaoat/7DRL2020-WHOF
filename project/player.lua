local controls = {}

--Support for WASD, Keypad, and Vi-keys
controls["moveBotLeft"] = {"kp1", "z", "b"}
controls["moveBot"] = {"kp2", "down", "x", "j"}
controls["moveBotRight"] = {"kp3", "c", "n"}
controls["moveRight"] = {"kp6", "right", "d", "l"}
controls["moveTopRight"] = {"kp9", "e", "u"}
controls["moveTop"] = {"kp8", "up", "w", "k"}
controls["moveTopLeft"] = {"kp7", "q", "y"}
controls["moveLeft"] = {"kp4", "left", "a", "h"}
controls["moveStay"] = {"kp5", "s", ","}

local reverseControls = {}

function initiatePlayer(map, x, y)
	--Do some preprocessing on controls
	for control, keys in pairs(controls) do
		for i = 1, #keys do
			reverseControls[keys[i]] = control
		end
	end
	
	player = {character = nil, currentlyActing = true, targeting = false, speed = 0, maxSpeed = 3}
	player.character = activateCharacter(initiateCharacter(map, x, y, initiateLetter("@", {1, 1, 0, 1})))
	return player
end

function updatePlayer(player, camera, dt)
	camera.centerX = player.character.x
	camera.centerY = player.character.y
end

--Shifts the player 1 space
function movePlayer(player, xdir, ydir)
	shiftCharacter(player.character, xdir, ydir)
end

--Detects player input to start a new round
function playerKeypressed(player, camera, key)
	local action = reverseControls[key]
	
	local dirX = 0
	local dirY = 0
	local kind = "none"
	if action == "moveBotLeft" then
		kind = "movement"
		dirX = -1
		dirY = 1
	elseif action == "moveBot" then
		kind = "movement"
		dirX = 0
		dirY = 1
	elseif action == "moveBotRight" then
		kind = "movement"
		dirX = 1
		dirY = 1
	elseif action == "moveRight" then
		kind = "movement"
		dirX = 1
		dirY = 0
	elseif action == "moveTopRight" then
		kind = "movement"
		dirX = 1
		dirY = -1
	elseif action == "moveTop" then
		kind = "movement"
		dirX = 0
		dirY = -1
	elseif action == "moveTopLeft" then
		kind = "movement"
		dirX = -1
		dirY = -1
	elseif action == "moveLeft" then
		kind = "movement"
		dirX = -1
		dirY = 0
	elseif action == "moveStay" then
		kind = "rest"
	end
	
	--Player made an input change
	if kind == "movement" then
		if player.currentlyActing then
			determinePlayerAction(player, dirX, dirY)
		end
	end

	if kind == "rest" then
		--Player made a blank move with no input then just start the round
		startRound(player, player.character.map)
	end
end

--changes the player's facing and speed depending on input then starts a round
function determinePlayerAction(player, dirX, dirY)
	local angle = angleBetweenVectors(0, 0, dirX, dirY)
	-- Angle relative to the direction
	local relAngle = distanceBetweenAngles(angle, player.character.facing)
	--Convert rel angle to degrees
	relAngle = math.deg(relAngle)

	--relative angle of zero means will accelerate forward
	if relAngle == 0 then
		modifySpeed(player, 1)
		print("player moving forward")
	end

	--relative angle of 45 or 315 will not change speed, only angle
	if relAngle == 45 then
		shiftClockwise(player.character)
		print("player turning clockwise")
	end
	if relAngle == 315 then
		shiftAnticlockwise(player.character)
		print("player turning anticlockwise")
	end

	--Doing a turn that slows you
	if relAngle == 90 or relAngle == 135 then
		shiftClockwise(player.character)
		modifySpeed(player, -1)
		print("player slowing down and turning clockwise")
	end
	if relAngle == 225 or relAngle == 270 then
		shiftAnticlockwise(player.character)
		modifySpeed(player, -1)
		print("player slowing down and turning anticlockwise")
	end

	--Just slowing down
	if relAngle == 180 then
		modifySpeed(player, -1)
		print("player slowing down")
	end

	print("player speed and facing: ")
	print(player.speed)
	print(math.deg(player.character.facing))

	--Start the round
	startRound(player, player.character.map)
end

--Clamps the speed
function modifySpeed(player, speedChange)
	player.speed = player.speed + speedChange

	if player.speed >= player.maxSpeed then
		player.speed = player.maxSpeed
	elseif player.speed <= 0 then
	    player.speed = 0
	end
end
