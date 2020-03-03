local kindProperties = {}
kindProperties["blood"] = function(particle)
	particle.infColour = {1, 0, 0, 1}
	particle.influence = 0.5
	particle.infFade = particle.influence/particle.timeLeft
	
	particle.trailColour = {1, 0, 0, 1}
	particle.trailStrength = 0.4
	particle.trailFade = particle.trailStrength/particle.timeLeft
	
	friction = 4
end

function initiateParticle(map, x, y, speed, angle, duration, kind)
	local particle = {map = map, x = x, y = y, angle = angle, speed = speed, timeLeft = duration, kind = kind}
	kindProperties[kind](particle)
	table.insert(map.particles, particle)
	return particle
end

function updateParticles(map, particles, dt)
	local i = 1
	while i <= #particles do
		local particle = particles[i]
		
		local tile = getMapTile(map, math.floor(particle.x), math.floor(particle.y))
		
		local oldX = particle.x
		local oldY = particle.y
		
		particle.x = particle.x + dt*particle.speed*math.cos(particle.angle)
		particle.y = particle.y + dt*particle.speed*math.sin(particle.angle)
		
		if math.floor(particle.x) ~= math.floor(oldX) or math.floor(particle.y) ~= math.floor(oldY) then
			if particle.trailStrength then
				tile.letter.colour = blendColours(particle.trailColour, tile.letter.colour, particle.trailStrength)
				tile.letter.backColour = blendColours(particle.trailColour, tile.letter.backColour, particle.trailStrength)
			end
		end
		
		if particle.friction then
			local frictionForce = particle.friction*dt*particle.speed
			particle.speed = particle.speed - frictionForce
		end
		
		if particle.infFade then
			particle.influence = particle.influence - dt*particle.infFade
		end
		
		if particle.trailFade then
			particle.trailStrength = math.max(0, particle.trailStrength - dt*particle.trailFade)
		end
		
		particle.timeLeft = particle.timeLeft - dt
		if particle.timeLeft <= 0 then
			table.remove(particles, i)
		else
			i = i + 1
		end
	end
end

function applyParticleInfluence(map, particles)
	for i = 1, #particles do
		local particle = particles[i]
		local tile = getMapTile(map, math.floor(particle.x), math.floor(particle.y))
		if particle.infColour then
			tile.letter.momentaryInfluenceColour = particle.infColour
			tile.letter.momentaryInfluence = particle.influence
		end
	end
end

function spawnBloodBurst(map, x, y, speed, angle)
	initiateParticle(map, x, y, speed, angle, speed/60, "blood")
	
	speed = 0.8*speed
	initiateParticle(map, x, y, speed, angle + randBetween(0, math.pi/4), speed/60, "blood")
	initiateParticle(map, x, y, speed, angle + randBetween(0, -math.pi/4), speed/60, "blood")
end