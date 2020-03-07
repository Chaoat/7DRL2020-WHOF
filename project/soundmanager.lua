do
    -- will hold the currently playing sources
	local sourceBank = {}
    local sources = {}
 
    -- check for sources that finished playing and remove them
    -- add to love.update
    function love.audio.update()
        local remove = {}
        for _,s in pairs(sources) do
            if not s:isPlaying() then
                remove[#remove + 1] = s
            end
        end
 
        for i,s in ipairs(remove) do
            sources[s] = nil
        end
    end
 
    -- overwrite love.audio.play to create and register source if needed
    local play = love.audio.play
    function love.audio.play(what, how, loop, volume)
        local src = what
        local path = "sounds/" .. what
        if type(what) ~= "userdata" or not what:typeOf("Source") then
			if not sourceBank[path] then
				sourceBank[path] = love.audio.newSource(path, how)
			end
			
            src = sourceBank[path]:clone()
            src:setLooping(loop or false)
			
			if volume then
				src:setVolume(volume)
			end
        end
 
        play(src)
        sources[src] = src
        return src
    end
 
    -- stops a source
    local stop = love.audio.stop
    function love.audio.stop(src)
        if not src then return end
        stop(src)
        sources[src] = nil
    end
end

function enemygruntsound()
	local chance = math.random()
	if chance < 0.33 then
		love.audio.play("grunt2.ogg", "static", false, 0.7)
	elseif chance < 0.66 then
		love.audio.play("grunt3.ogg", "static", false, 0.7)
	else
	    love.audio.play("grunt4.ogg", "static", false, 0.7)
	end
end

function enemyarrowsound()
	local chance = math.random()
	if chance < 0.33 then
		love.audio.play("arrow2.ogg", "static", false)
	elseif chance < 0.66 then
		love.audio.play("arrow3.ogg", "static", false)
	else
	    love.audio.play("arrow4.ogg", "static", false)
	end
end

function enemyswordsound()
	local chance = math.random()
	if chance < 0.33 then
		love.audio.play("sword1.ogg", "static", false)
	elseif chance < 0.66 then
		love.audio.play("sword2.ogg", "static", false)
	else
	    love.audio.play("sword3.ogg", "static", false)
	end
end

function enemysurprisesound()
	local chance = math.random()
	if chance < 0.33 then
		love.audio.play("gasp1.ogg", "static", false)
	elseif chance < 0.66 then
		love.audio.play("gasp2.ogg", "static", false)
	else
	    love.audio.play("gasp3.ogg", "static", false)
	end
end

local pGallopSound = love.audio.newSource("sounds/gallop_loop.ogg", "static")
function playerGallopSound(speed)
	pGallopSound:play()
	pGallopSound:setVolume(speed/5)
end

local eGallopSound = love.audio.newSource("sounds/gallop_loop.ogg", "static")
function enemyGallopSound(distance)
	local newVolume = math.max(1 - distance/20, 0)
	if eGallopSound:isPlaying() then
		if eGallopSound:getVolume() < newVolume then
			eGallopSound:setVolume(newVolume)
		end
	else
		eGallopSound:setVolume(newVolume)
		eGallopSound:play()
	end
end

local enemyWalkSound = love.audio.newSource("sounds/footsteps.ogg", "static")
enemyWalkSound:setVolume(0)
function playEnemyWalkSound(volume)
	if enemyWalkSound:isPlaying() then
		if enemyWalkSound:getVolume() < volume then
			enemyWalkSound:setVolume(volume)
		end
	else
		enemyWalkSound:setVolume(volume)
		enemyWalkSound:play()
	end
end

local windSound = love.audio.newSource("sounds/wind.ogg", "static")
function playWind()
	windSound:setLooping(true)
	windSound:play()
end

function pauseWind()
	windSound:stop()
end

function updateWindSound(volume)
	windSound:setVolume(volume)
end