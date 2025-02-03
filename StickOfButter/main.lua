local walter = {
    img = love.graphics.newImage("walter.png"),
    transformed = false,
    transformImg = love.graphics.newImage("AAA.png"),
    x = 0,
    y = 500,
    speed = 100,
    scale = 0.25
}

local butter = {
    img = love.graphics.newImage("butter.png"),
    x = 400,
    y = 500,
    visible = true,
    scale = 0.15
}

local transformSound = love.audio.newSource("transform.mp3", "static")
local music = love.audio.newSource("Fluffing-a-Duck.mp3", "stream")
music:setLooping(true)
music:play()

local function AABB(source, target)
    local source_left = source.x
    local source_right = source.x + source.img:getWidth() * source.scale
    local source_top = source.y
    local source_bottom = source.y + source.img:getHeight() * source.scale

    local target_left = target.x
    local target_right = target.x + target.img:getWidth() * target.scale
    local target_top = target.y
    local target_bottom = target.y + target.img:getHeight() * target.scale

    return source_right > target_left and
           source_left < target_right and
           source_bottom > target_top and
           source_top < target_bottom
end

function love.update(dt)
    if love.keyboard.isDown("right") then
        walter.x = walter.x + walter.speed * dt
    end
    if love.keyboard.isDown("left") then
        walter.x = walter.x - walter.speed * dt
    end

    if not walter.transformed then
        walter.y = 500 + math.sin(love.timer.getTime() * 5) * 50
    end

    if AABB(walter, butter) and not walter.transformed then
        walter.transformed = true
        butter.visible = false
        transformSound:play()
    end
end

function love.draw()
    if walter.transformed then
        love.graphics.draw(walter.transformImg, walter.x, walter.y, 0, 0.2, 0.2, 0, walter.transformImg:getHeight())
    else
        love.graphics.draw(walter.img, walter.x, walter.y, 0, 0.25, 0.25, 0, walter.img:getHeight())
    end

    if butter.visible then
        love.graphics.draw(butter.img, butter.x, butter.y, 0, 0.15, 0.15, 0, butter.img:getHeight())
    end
end