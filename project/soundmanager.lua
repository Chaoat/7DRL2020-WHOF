do
    -- will hold the currently playing sources
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
    function love.audio.play(what, how, loop)
        local src = what
        local path = "sounds/" .. what
        if type(what) ~= "userdata" or not what:typeOf("Source") then
            src = love.audio.newSource(path, how)
            src:setLooping(loop or false)
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
		love.audio.play("grunt2.ogg", "static", false)
	elseif chance < 0.66 then
		love.audio.play("grunt3.ogg", "static", false)
	else
	    love.audio.play("grunt4.ogg", "static", false)
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