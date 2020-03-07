local endScreen = {playerDeathTime = 0, text = "", causeOfDeath = "", distanceTravelled = 0, started = false, restartButtonX = 0, restartButtonY = 150, restartButtonWidth = 70, restartButtonHeight = 40, quitButtonX = 0, quitButtonY = 220, quitButtonWidth = 70, quitButtonHeight = 40}

function startEndScreen(player, deathCause)
	endScreen.playerDeathTime = GlobalTime
	endScreen.started = true
	endScreen.distanceTravelled = player.travelDist / WinDistance
	endScreen.causeOfDeath = deathCause
	
	if deathCause == "shot" then
		endScreen.text = "You barely have time to glance down at the feathered shaft jutting from your chest before darkness overwhelms you.\nYour horse fights on after you slip from the saddle, but without her master she is quickly overwhelmed and hacked to pieces."
	elseif deathCause == "sworded" then
		endScreen.text = "The impact of the blade deep into your mare's flank tells you of your fate mere moments before her tortured cry.\nYou reach to draw your sword, but it is knocked from your hand as you go crashing to the ground.\nYour last vision is of a fearful eyed farmer standing over you, blade raised above his head."
	elseif deathCause == "lanced" then
		endScreen.text = "The jolt of your horse as she is skewered by your opponent's lance throws you clean out of the saddle.\nYou have time only for a whispered prayer to the spirits before you are surrounded and cut down."
	elseif deathCause == "collision" then
		endScreen.text = "Your horse is shattered, and your body in ruins.\nTo think that an Eijidin warrior could come to such an end.\nYour ancestors are ashamed."
	elseif deathCause == "suicide" then
		endScreen.text = "Despairing at the impossible task set before you, you hurl yourself from your horse.\nYour neck breaks instantly on impact."
	end
end

function drawEndScreen(camera)
	if endScreen.started then
		local timeSinceStart = GlobalTime - endScreen.playerDeathTime
		
		local boxRadius = math.floor(math.min(timeSinceStart/2, 1)*camera.tilesWide)
		local leftOver = (math.min(timeSinceStart/3, 1)*camera.tilesWide - boxRadius)
		for i = -boxRadius, boxRadius do
			for j = -boxRadius, boxRadius do
				local drawX, drawY = getDrawPos(i + camera.centerX, j + camera.centerY, camera)
				local alpha = 0.7
				if math.abs(i) + math.abs(j) == boxRadius then
					alpha = leftOver*alpha
				elseif math.abs(i) + math.abs(j) > boxRadius then
					alpha = 0
				end				
				love.graphics.setColor(0, 0, 0, alpha)
				love.graphics.rectangle("fill", drawX, drawY, camera.tileWidth, camera.tileHeight)
			end
		end
		
		local textAlpha = math.min((timeSinceStart - 2)/2, 1)
		setFont("clacon", 20)
		if textAlpha > 0 then
			love.graphics.setColor(1, 1, 1, textAlpha)
			local text = endScreen.text
			if endScreen.distanceTravelled == 1 then
				text = text .. "\n\nYou lead the guerilla force assigned to destroying the flanking army. When you return, the stalemate is over and Ulijin has won a decisive victory.\nThe feasting lasts for days and you are celebrated as the greatest hero of the war."
			else
				text = text .. "\n\nYou made it " .. math.floor(100*endScreen.distanceTravelled) .. "% of the way before meeting your doom."
			end
			
			love.graphics.printf(text, camera.width/2 - 200, camera.height/2 - 200, 400, "center")
			
			love.graphics.setColor(0.1, 0.1, 0.1, 0.5*textAlpha)
			love.graphics.rectangle("fill", camera.width/2 + endScreen.restartButtonX - endScreen.restartButtonWidth/2, camera.height/2 + endScreen.restartButtonY - endScreen.restartButtonHeight/2, endScreen.restartButtonWidth, endScreen.restartButtonHeight)
			love.graphics.setColor(1, 1, 1, textAlpha)
			love.graphics.printf("restart", camera.width/2 + endScreen.restartButtonX - endScreen.restartButtonWidth/2 + 5, camera.height/2 + endScreen.restartButtonY - endScreen.restartButtonHeight/2 + 12, endScreen.restartButtonWidth - 10, "center")
			
			love.graphics.setColor(0.1, 0.1, 0.1, 0.5*textAlpha)
			love.graphics.rectangle("fill", camera.width/2 + endScreen.quitButtonX - endScreen.quitButtonWidth/2, camera.height/2 + endScreen.quitButtonY - endScreen.quitButtonHeight/2, endScreen.quitButtonWidth, endScreen.quitButtonHeight)
			love.graphics.setColor(1, 1, 1, textAlpha)
			love.graphics.printf("quit", camera.width/2 + endScreen.quitButtonX - endScreen.quitButtonWidth/2 + 5, camera.height/2 + endScreen.quitButtonY - endScreen.quitButtonHeight/2 + 12, endScreen.quitButtonWidth - 10, "center")
		end
	end
end

function clickEndScreen(x, y, menu, camera)
	if endScreen.started then
		local restartMinX = camera.width/2 + endScreen.restartButtonX - endScreen.restartButtonWidth/2
		local restartMaxX = camera.width/2 + endScreen.restartButtonX + endScreen.restartButtonWidth/2
		local restartMinY = camera.height/2 + endScreen.restartButtonY - endScreen.restartButtonHeight/2
		local restartMaxY = camera.height/2 + endScreen.restartButtonY + endScreen.restartButtonHeight/2
		
		local quitMinX = camera.width/2 + endScreen.quitButtonX - endScreen.quitButtonWidth/2
		local quitMaxX = camera.width/2 + endScreen.quitButtonX + endScreen.quitButtonWidth/2
		local quitMinY = camera.height/2 + endScreen.quitButtonY - endScreen.quitButtonHeight/2
		local quitMaxY = camera.height/2 + endScreen.quitButtonY + endScreen.quitButtonHeight/2
		
		if x >= restartMinX and x <= restartMaxX and y >= restartMinY and y <= restartMaxY then
			startGame()
		elseif x >= quitMinX and x <= quitMaxX and y >= quitMinY and y <= quitMaxY then
			enterMenu(menu, camera)
		end
	end
end