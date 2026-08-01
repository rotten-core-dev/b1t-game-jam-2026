io.stdout:setvbuf('no')

push = require "lib/push" --require the library
themes = require "lib/themes" --require the library
--screenShake = require "lib/screenShake" --require the library
state = require "lib/state" --require the library

--pixelfont = require "assets/fonts/pixel.ttf" --require the library

themes.current = themes.getByName("B1T JAM") --set the current theme to "B1T JAM"

GAMEWIDTH, GAMEHEIGHT = 270, 480

function love.resize(w, h)
  push:resize(w, h)
end

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest") --disable blurry scaling

    love.mouse.setVisible(false) --hide the mouse cursor

    love.window.setTitle("COCK-A-DOODLE-DOO")

    --love.graphics.setBackgroundColor(themes.current.secondary)

    local windowWidth, windowHeight = love.window.getDesktopDimensions()
    windowWidth, windowHeight = windowWidth*.5, windowHeight*.5

    push:setupScreen(GAMEWIDTH, GAMEHEIGHT, windowWidth, windowHeight, {
    fullscreen = false,
    resizable = true,
    upscale = 'normal', 
    --highdpi = true,
    canvas = false
    })
    push:setBorderColor(0, 0, 0) --default value

    -- initialize our nice-looking retro text fonts
    SmallFont = love.graphics.newFont("assets/fonts/pixel.ttf" , 8)
    LargeFont = love.graphics.newFont("assets/fonts/pixel.ttf" , 16)
    ScoreFont = love.graphics.newFont("assets/fonts/pixel.ttf" , 32)
    MenuTitleFont = love.graphics.newFont("assets/fonts/pixel.ttf" , 32)
    TitleFont = love.graphics.newFont("assets/fonts/pixel.ttf" , 26)
    love.graphics.setFont(SmallFont)

    state.switch(require "states/intro") --switch to the intro state
end


function love.keypressed(key, scancode, isrepeat)
  
    
    --be sure to reset push settings
    --push:resetSettings()
    


    if key == "f" then --activate fullscreen mode
        push:switchFullscreen() --optional width and height parameters for window mode
    elseif key == "escape" then 
        love.event.quit() 
    -- else 
    --     local currentState = state.currentState
    --     if currentState.nextState then
    --         state.switch(currentState.nextState) --switch to the next state
    --     end
    end
end

function love.update(dt)
    local current = state.current()
    if current and current.update then
        current:update(dt)
    end
end

function love.draw()
    local current = state.current()
    if current and current.draw then
        current:draw()
    end
end