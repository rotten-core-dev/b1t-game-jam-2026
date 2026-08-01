io.stdout:setvbuf('no')

push = require "lib/push" --require the library

local states = {
  "intro",
  "title",
  "gameplay"
}
local state = 1

for i = 1, #states do
  states[i] = require("states." .. states[i])
end

GAMEWIDTH, GAMEHEIGHT = 270, 480

function love.resize(w, h)
  push:resize(w, h)
end

function love.load()

    love.window.setTitle("COCK-A-DOODLE-DOO")

    love.graphics.setDefaultFilter("linear", "linear") --default filter



    local windowWidth, windowHeight = love.window.getDesktopDimensions()
    windowWidth, windowHeight = windowWidth*.5, windowHeight*.5

    push:setupScreen(GAMEWIDTH, GAMEHEIGHT, windowWidth, windowHeight, {
    fullscreen = false,
    resizable = true,
    highdpi = true,
    canvas = false
    })
    push:setBorderColor(0, 0, 0) --default value

    love.graphics.setNewFont(12)
end


function love.keypressed(key, scancode, isrepeat)
  
    
    --be sure to reset push settings
    --push:resetSettings()
    
    
    if key == "f" then --activate fullscreen mode
        push:switchFullscreen() --optional width and height parameters for window mode
    elseif key == "escape" then 
        love.event.quit() 
    else 
        if state < 2 then
            state = 2
        
        elseif state < 3 then
            state = state + 1
        end
    end
    states[state]()
end

states[state]()