io.stdout:setvbuf('no')

push = require "lib/push" --require the library
themes = require "lib/themes" --require the library
--screenShake = require "lib/screenShake" --require the library
state = require "lib/state" --require the library

--pixelfont = require "assets/fonts/pixel.ttf" --require the library

themes.current = themes.getByName("WHITE ON BLACK") --set the current theme

GAMEWIDTH, GAMEHEIGHT = 400, 300

function love.resize(w, h)
  push:resize(w, h)
end

function love.load()
    currentTime = love.timer.getTime()
    love.graphics.setDefaultFilter("nearest", "nearest") --disable blurry scaling

    love.mouse.setVisible(false) --hide the mouse cursor

    love.window.setTitle("COCK-A-DOODLE-DO!")

    love.graphics.setBackgroundColor(themes.current.background)

    local windowWidth, windowHeight = 800, 600 --this is simpler to set the window size that we want.

    push:setupScreen(GAMEWIDTH, GAMEHEIGHT, windowWidth, windowHeight, {
    --fullscreen = false,
    resizable = true,
    upscale = 'normal', 
    --highdpi = true,
    canvas = false
    })
    push:setBorderColor(0, 0, 0) --default value

    -- initialize our nice-looking retro text fonts
    SmallFont = love.graphics.newFont("assets/fonts/pixel.ttf" , 8)
    MediumFont = love.graphics.newFont("assets/fonts/pixel.ttf" , 12)
    LargeFont = love.graphics.newFont("assets/fonts/pixel.ttf" , 16)
    ClockFont = love.graphics.newFont("assets/fonts/DS-DIGI.ttf" , 26)
    MenuTitleFont = love.graphics.newFont("assets/fonts/pixel.ttf" , 32)
    TitleFont = love.graphics.newFont("assets/fonts/pixel.ttf" , 26)
    love.graphics.setFont(ClockFont)

    -- cover art image
    CoverArt = love.graphics.newImage("assets/img/rooster-cover-dark.png") --require the library

    -- GUY
    imageGuy = {
        beard = love.graphics.newImage("assets/img/beard.png"),
        bed = love.graphics.newImage("assets/img/bed.png"),
        eyesClosed = love.graphics.newImage("assets/img/eyesClosed.png"),
        eyesOpen = love.graphics.newImage("assets/img/eyesOpen.png"),
        hands = love.graphics.newImage("assets/img/hands.png"),
        head = love.graphics.newImage("assets/img/head.png"),
        pillow = love.graphics.newImage("assets/img/pillow.png"),
        stash = love.graphics.newImage("assets/img/stash.png")
    }
     -- ROOSTER
    imageRooster = {
        beakBtm = love.graphics.newImage("assets/img/rooster/beakBtm.png"),
        beakTop = love.graphics.newImage("assets/img/rooster/beakTop.png"),
        body = love.graphics.newImage("assets/img/rooster/body.png"),
        foot = love.graphics.newImage("assets/img/rooster/foot.png"),
        head = love.graphics.newImage("assets/img/rooster/head.png"),
        tail = love.graphics.newImage("assets/img/rooster/tail.png"),
        wing = love.graphics.newImage("assets/img/rooster/wing.png"),
    }
    state.switch(require "states/intro") --switch to the intro state
end


function love.keypressed(key, scancode, isrepeat)
  
    if key == "f" then --activate fullscreen mode
        push:switchFullscreen() --optional width and height parameters for window mode
    elseif key == "escape" then 
        -- changed this for the web version as quit causes a crash
        push:switchFullscreen()
        -- love.event.quit() --quit the game
    end
end

function love.update(dt)
    currentTime = love.timer.getTime()
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