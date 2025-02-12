local baguetteSpr = love.graphics.newImage("baguette.png")
local plush = love.graphics.newImage("plush.png")
local plushX, plushY = 325, 400
local tetoterritory = love.audio.newSource("territory.ogg", "stream")
tetoterritory:setLooping(true)
tetoterritory:setVolume(0.25)
tetoterritory:seek(1.6)
tetoterritory:play()

local explosion = love.audio.newSource("explosion.mp3", "static")
local timer_321 = love.audio.newSource("3_2_1.ogg", "static")
timer_321:seek(1)
local didTimer = false
--explosion:play()

local baguetteBatch = love.graphics.newSpriteBatch(baguetteSpr, 1000)

local totalBaguettesInPocket = 13
local allBaguettes = {
    -- {startX, startY, x, y, rotation, tweenMethod, time, currentTime}
}
local particleBaguettes = {}

local function linear(t)
    return t
end

local function outQuad(t)
    return t * (2 - t)
end

local function inQuad(t)
    return t * t
end

function love.run()
	if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end

	local dt = 0

	-- Main loop time.
	return function()
		-- Process events.
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a or 0
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end

		-- Update dt, as we'll be passing it to update
		if love.timer then dt = love.timer.step() end

		-- Call update and draw
		if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled

		if love.graphics and love.graphics.isActive() then
			love.graphics.origin()
			love.graphics.clear(love.graphics.getBackgroundColor())

			if love.draw then love.draw() end

			love.graphics.present()
		end
	end
end
local function checkForPlushOverlap(x, y)
    return x >= plushX and x <= plushX + plush:getWidth() * 0.25 and y >= plushY and y <= plushY + plush:getHeight() * 0.25
end

local function placeLargeBaguette()
    if totalBaguettesInPocket <= 0 then
        return
    end
    local startX = plushX + plush:getWidth() * 0.125
    local startY = plushY + plush:getHeight() * 0.125
    local rotation = love.math.random() * 2 * math.pi
    local tweenMethod = love.math.random(1, 2) == 1 and outQuad or inQuad
    local totalTime = love.math.random(0.5, 1.5)
    local endX = love.math.random(0, 800)
    local endY = love.math.random(0, 600)
    while checkForPlushOverlap(endX, endY) do
        endX = love.math.random(0, 800)
        endY = love.math.random(0, 600)
    end
    table.insert(allBaguettes, {startX, startY, endX, endY, rotation, tweenMethod, totalTime, 0})

    totalBaguettesInPocket = totalBaguettesInPocket - 1
end

function love.keypressed(key)
    if key == "space" then
        placeLargeBaguette()
    end
end

function love.update(dt)
    baguetteBatch:clear()

    for i = #allBaguettes, 1, -1 do
        local baguette = allBaguettes[i]
        baguette[8] = baguette[8] + dt
        local t = baguette[8] / baguette[7]
        if t >= 1 then
            baguetteBatch:add(baguette[3], baguette[4], baguette[5], 0.05, 0.05, baguetteSpr:getWidth() / 2, baguetteSpr:getHeight() / 2)
        else
            local x = baguette[1] + (baguette[3] - baguette[1]) * baguette[6](t)
            local y = baguette[2] + (baguette[4] - baguette[2]) * baguette[6](t)
            baguetteBatch:add(x, y, baguette[5], 0.05, 0.05, baguetteSpr:getWidth() / 2, baguetteSpr:getHeight() / 2)
        end
    end

    if totalBaguettesInPocket <= 0 and not didTimer then
        timer_321:play()
        didTimer = true
    end

    if didTimer and not timer_321:isPlaying() and #particleBaguettes <= 0 then
        explosion:play()
    end

    if not timer_321:isPlaying() and totalBaguettesInPocket <= 0 and didTimer then
        for _ = 1, 1000000 do
            local startX = plushX + plush:getWidth() * 0.125
            local startY = plushY + plush:getHeight() * 0.125
            local rotation = love.math.random() * 2 * math.pi
            local tweenMethod = love.math.random(1, 2) == 1 and outQuad or inQuad
            local totalTime = love.math.random(1, 1.1)
            local endX = love.math.random(0, 800)
            local endY = love.math.random(0, 600)
            while checkForPlushOverlap(endX, endY) do
                endX = love.math.random(0, 800)
                endY = love.math.random(0, 600)
            end
            table.insert(particleBaguettes, {startX, startY, endX, endY, rotation, tweenMethod, totalTime, 0, {
                -- physics data
                bounce = 0.5,
                gravity = 9.8 * love.math.random(10, 20)
            }})
        end
        totalBaguettesInPocket = 13
    end
        
    for i = #particleBaguettes, 1, -1 do
        local baguette = particleBaguettes[i]
        baguette[8] = baguette[8] + dt
        local t = baguette[8] / baguette[7]
        if t >= 1 then
            -- make the y bounce

            baguette[4] = baguette[4] + baguette[9].gravity * dt
            baguette[9].gravity = baguette[9].gravity + 9.8*5 * dt
            -- bounce!
            if baguette[4] >= 600 then
                baguette[4] = 600
                baguette[9].gravity = -baguette[9].gravity * baguette[9].bounce
            end
            if baguette[3] >= 800 then
                baguette[3] = 800
                baguette[5] = math.pi - baguette[5]
            end
            if baguette[3] <= 0 then
                baguette[3] = 0
                baguette[5] = math.pi - baguette[5]
            end
            baguetteBatch:add(baguette[3], baguette[4], baguette[5], 0.025, 0.025, baguetteSpr:getWidth() / 2, baguetteSpr:getHeight() / 2)
        else
            local x = baguette[1] + (baguette[3] - baguette[1]) * baguette[6](t)
            local y = baguette[2] + (baguette[4] - baguette[2]) * baguette[6](t)
            baguetteBatch:add(x, y, baguette[5], 0.025, 0.025, baguetteSpr:getWidth() / 2, baguetteSpr:getHeight() / 2)
        end
    end
end

function love.draw()
    if #particleBaguettes <= 0 then
        love.graphics.draw(plush, plushX, plushY, 0, 0.25, 0.25)
    end
    
    love.graphics.draw(baguetteBatch)

    love.graphics.print("Draw Calls: " .. love.graphics.getStats().drawcalls, 10, 10)
    love.graphics.print("Texture Memory: " .. love.graphics.getStats().texturememory, 10, 30)
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 50)
    love.graphics.print("Baguettes in Pocket: " .. totalBaguettesInPocket, 10, 70)
    love.graphics.print("Baguettes on Plush: " .. #allBaguettes, 10, 90)
    love.graphics.print("Particle Baguettes: " .. #particleBaguettes, 10, 110)
end