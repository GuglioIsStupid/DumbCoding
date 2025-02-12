local stupidIdiot = love.graphics.newImage("StupidIdiot.jpg")
local stupidIdiotBatch = love.graphics.newSpriteBatch(stupidIdiot, 1000)

local StupidIdiotLaugh = love.audio.newSource("StupidIdiotLaugh.ogg", "static")

local stupidIdiotButton = {}
stupidIdiotButton.x = love.graphics.getWidth() / 2 - 100
stupidIdiotButton.y = love.graphics.getHeight() / 2 - 50
stupidIdiotButton.width = 200
stupidIdiotButton.height = 100
stupidIdiotButton.text = "Spawn Stupid Idiot"
stupidIdiotButton.font = love.graphics.newFont(20)
stupidIdiotButton.textWidth = stupidIdiotButton.font:getWidth(stupidIdiotButton.text)
stupidIdiotButton.textHeight = stupidIdiotButton.font:getHeight(stupidIdiotButton.text)

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

local allStupidIdiots = {}

newStupidIdiot = {}
newStupidIdiot.__index = newStupidIdiot

function newStupidIdiot:init()
    -- create a new instance
    local instance = {}
    setmetatable(instance, newStupidIdiot)
    instance.y = -stupidIdiot:getHeight()
    instance.yVelocity = 100
    return instance
end

local function newStupidIdiot_update(self, dt)
    self.y = self.y + self.yVelocity * dt
    
    self.yVelocity = self.yVelocity + 1250 * dt

    if self.y > love.graphics.getHeight() then
        for i = #allStupidIdiots, 1, -1 do
            if allStupidIdiots[i] == self then
                table.remove(allStupidIdiots, i)
                break
            end
        end
    end
end

local function newStupidIdiot_draw(self)
    stupidIdiotBatch:add(love.graphics.getWidth() / 2 - stupidIdiot:getWidth() / 2, self.y)
end

function stupidIdiotButton:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 10, 10)
    love.graphics.setFont(self.font)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(self.text, self.x + self.width / 2 - self.textWidth / 2, self.y + self.height / 2 - self.textHeight / 2)
end

function stupidIdiotButton:isPressed(x, y)
    return x > self.x and x < self.x + self.width and y > self.y and y < self.y + self.height
end

function stupidIdiotButton:onPress()
    table.insert(allStupidIdiots, newStupidIdiot:init())
    StupidIdiotLaugh:clone():play()
end

function love.load()
end

function love.update(dt)
    for i = #allStupidIdiots, 1, -1 do
        newStupidIdiot_update(allStupidIdiots[i], dt)
    end
end

function love.draw()
    stupidIdiotBatch:clear()
    stupidIdiotButton:draw()
    love.graphics.setColor(1, 1, 1)
    for i = 1, #allStupidIdiots do
        newStupidIdiot_draw(allStupidIdiots[i])
    end

    love.graphics.draw(stupidIdiotBatch)

    love.graphics.print("How many stupid fucks are on screen: " .. #allStupidIdiots, 10, 10)
end

function love.mousepressed(x, y, button)
    if stupidIdiotButton:isPressed(x, y) then
        stupidIdiotButton:onPress()
    end
end
