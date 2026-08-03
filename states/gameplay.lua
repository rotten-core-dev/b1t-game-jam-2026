local screenShake = require "lib/screenShake" --require the library
local sounds = require "src/sounds" --require the library

local gameplay = {
  enterTime = 0.0,
  nextState = nil,
  screenTime = 3.0,
  shakeStartTime = 2.0, -- Time after which the screen shake starts
  shakeDuration = 1.0, -- Duration of the screen shakeTimeLeft
  shakeMagnitude = 20 -- Magnitude of the screen shake
  
}

-- charge bar dimensions and position
local chargeBarX, chargeBarY = GAMEWIDTH * 0.9, GAMEHEIGHT * 0.15
local chargeBarWidth, chargeBarHeight = GAMEWIDTH * 0.05, GAMEHEIGHT * 0.8

-- paddle dimensions and position
local paddleWidth, paddleHeight = chargeBarWidth + 10, 10
local paddleX = chargeBarX - (paddleWidth - chargeBarWidth) * 0.5
local paddleY = chargeBarY + chargeBarHeight - paddleHeight
local paddleSpeed = 3 * chargeBarHeight-- paddle moves at half the height of the charge bar per second

local arrowSprite = love.graphics.newImage("assets/arrow.png")

local arrow = {
  xpos = 0,
  ypos = 0,


}

local function resetPaddle()
  paddleY = chargeBarY + chargeBarHeight - paddleHeight
end


function gameplay:enter()
  screenShake.stop()
  --screenShake.trigger(5, 1.0) -- Trigger a screen shake with strength 5 and duration 0.5 seconds
end

function gameplay:draw()
  push:apply("start")

  -- screen shake is handled by the screenShake library, which modifies the drawing position based on the shake offset
  love.graphics.translate(screenShake.shakeOffsetX, screenShake.shakeOffsetY)

  -- this is the background color
  love.graphics.setColor(themes.current.secondary)
  love.graphics.rectangle("fill", 0, 0, GAMEWIDTH, GAMEHEIGHT)

  -- set the foreground color to the primary color
  love.graphics.setColor(themes.current.primary)
  
  --nil is returned if mouse is outside the game screen
  local mouseX, mouseY = love.mouse.getPosition()
  mouseX, mouseY = push:toGame(mouseX, mouseY)

  -- draws the mouse cursor as a circle at the mouse position
  if mouseX and mouseY then love.graphics.circle("line", mouseX, mouseY, 10) end

  -- title at top of screen  love.graphics.setFont(LargeFont)
  love.graphics.printf("COCK-A-DOODLE-DOO", 0, GAMEHEIGHT * 0.05, GAMEWIDTH, "center")

  -- draw a rectangle towards top of screen for our charging and timing bar
  love.graphics.rectangle("line", chargeBarX, chargeBarY, chargeBarWidth, chargeBarHeight)

  -- draw the paddle
  love.graphics.rectangle("fill", paddleX, paddleY, paddleWidth, paddleHeight)
  
 -- self:drawArrow()

  -- screenShake is applied to the drawing, so we need to reset the translation after drawing
  love.graphics.translate(-screenShake.shakeOffsetX, -screenShake.shakeOffsetY)

  push:apply("end")
end

function gameplay:update(dt)
  screenShake.update(dt) --update game logic here
  if love.mouse.isDown(1) or love.keyboard.isDown("space") then
    sounds.chicken:play()
    screenShake.trigger(2*chargeBarHeight/paddleY, 0.1)
    if paddleY > chargeBarY then
      paddleY = paddleY - paddleSpeed * dt
    end
  else 
    sounds.chicken:stop()
    screenShake.stop()
    resetPaddle()
  end
end


function gameplay:drawArrow()
  -- arrow starts at beginning of timing bar and moves to the end of the bar while the player holds down the mouse or spacebar
  local mouseDown = love.mouse.isDown(1) or love.keyboard.isDown("space")
  if mouseDown then
    local mouseX, mouseY = love.mouse.getPosition()
    mouseX, mouseY = push:toGame(mouseX, mouseY)
    if mouseX and mouseY then
      local barStartX = GAMEWIDTH * 0.1
      local barEndX = GAMEWIDTH * 0.9
      local barWidth = barEndX - barStartX
      local barHeight = GAMEHEIGHT * 0.05
      local barY = GAMEHEIGHT * 0.15 + (barHeight * 0.5) + (arrowSprite:getHeight())
      local arrowX = barStartX + (barWidth * 0.5) - (arrowSprite:getWidth() * 0.5)
      love.graphics.draw(arrowSprite, arrowX, barY)
    end
  end
end

return gameplay

--love.graphics.draw(arrow, GAMEWIDTH * 0.1 + (GAMEWIDTH * 0.8) * 0.5 - arrow:getWidth() * 0.5, GAMEHEIGHT * 0.15 + (GAMEHEIGHT * 0.05) * 0.5 - arrow:getHeight() * 0.5)