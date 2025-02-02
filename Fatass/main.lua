ffi = require "ffi"

ffi.cdef [[
typedef struct SDL_Window SDL_Window;
SDL_Window* SDL_GL_GetCurrentWindow(void);
void* SDL_GL_GetCurrentContext(void);

int SDL_SetWindowOpacity(SDL_Window* window, float opacity);
int SDL_SetWindowSize(SDL_Window* window, int w, int h);
]]
local SDL = ffi.load("SDL2")

local baguette = love.graphics.newImage("baguette.png")
local fatty = love.graphics.newImage("fatty.png")

---@diagnostic disable-next-line: undefined-field
sdlwindow = SDL.SDL_GL_GetCurrentWindow()

SDL.SDL_SetWindowSize(sdlwindow, fatty:getWidth() + 300, fatty:getHeight())
local desktopX, desktopY = love.window.getDesktopDimensions()
local windowWidth, windowHeight = love.window.getMode()
love.window.setPosition(desktopX / 2 - windowWidth / 2, desktopY / 2 - windowHeight / 2)

love.graphics.setBackgroundColor(0.25, 0.25, 0.25)

local grabbed = {
    x = 0,
    y = 0,
    grabbed = false
}

local baguetteX = fatty:getWidth() + 150

function love.mousepressed(x, y)
    if x >= baguetteX - (baguette:getWidth() * 0.25)/2 and x <= baguetteX + baguette:getWidth() * 0.25 and y >= 200 - (baguette:getHeight() * 0.25)/2 and y <= 200 + baguette:getHeight() * 0.25 then
        grabbed.grabbed = true
        grabbed.x = x
        grabbed.y = y
    end
end

function love.update(dt)
    if grabbed.grabbed then
        grabbed.x = love.mouse.getX()
        grabbed.y = love.mouse.getY()
    end
end

local safeZone = {
    x = 200,
    y = 200,
    width = 400,
    height = 300
}

local fattyWidth = fatty:getWidth()
function love.mousereleased(x, y)
    if grabbed.grabbed then
        grabbed.grabbed = false
        if x >= safeZone.x and x <= safeZone.x + safeZone.width and y >= safeZone.y and y <= safeZone.y + safeZone.height then
            fattyWidth = fattyWidth + 2
            safeZone.width = safeZone.width + 2
            baguetteX = baguetteX + 2

            local winWidth = love.graphics.getWidth()
            local winX, winY = love.window.getPosition()
            SDL.SDL_SetWindowSize(sdlwindow, winWidth + 2, windowHeight)
            love.window.setPosition(winX - 1, winY)
        end
    end
end

local function renderSafeZone()
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", safeZone.x, safeZone.y, safeZone.width, safeZone.height)
end

function love.draw()
    love.graphics.draw(fatty, 0, 0, 0, (fattyWidth / fatty:getWidth() * -1), 1, fatty:getWidth(), 0)

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(baguette, baguetteX, 200, 0, 0.25/4, 0.25/4, baguette:getWidth() / 2, baguette:getHeight() / 2)
    if grabbed.grabbed then
        love.graphics.draw(baguette, grabbed.x, grabbed.y, 0, 0.25/4, 0.25/4, baguette:getWidth() / 2, baguette:getHeight() / 2)
    end

    renderSafeZone()
end