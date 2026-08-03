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
local paddleCentreY = paddleY + paddleHeight * 0.5
local paddleSpeed = 3 * chargeBarHeight-- paddle moves at half the height of the charge bar per second
local isCharging = false -- flag to indicate if the paddle is charging

-- target dimensions and position
local targetStartSize = 10
local targetMaxSize = chargeBarHeight / 10
local targetGrowthRate = targetMaxSize / 5 -- target grows to max size in 5 seconds
local currentTargetSize = targetStartSize -- used to keep track of target size as it grows
local targetCentreY = 0
local targetTopY = targetCentreY - currentTargetSize / 2
local targetBottomY = targetCentreY + currentTargetSize


local function resetPaddle()
  paddleY = chargeBarY + chargeBarHeight - paddleHeight
  paddleCentreY = paddleY + paddleHeight * 0.5
end

local function generateTarget()
  -- reset the target size to the starting size
  currentTargetSize = targetStartSize

  -- generate a random position for target
  local targetMinY = chargeBarY + targetMaxSize 
  local targetMaxY = chargeBarY + chargeBarHeight - targetMaxSize
  targetCentreY = love.math.random(targetMinY, targetMaxY)
end

local function growTarget(dt)
  if currentTargetSize < targetMaxSize then
    currentTargetSize = currentTargetSize + targetGrowthRate * dt
    if currentTargetSize > targetMaxSize then
      currentTargetSize = targetMaxSize
    end
  end
end

local function handlePaddle(dt)
  if love.mouse.isDown(1) or love.keyboard.isDown("space") then
    isCharging = true
    sounds.chicken:play()
    screenShake.trigger(3*chargeBarHeight/paddleY, 0.1)
    if paddleY > chargeBarY then
      paddleY = paddleY - paddleSpeed * dt
      paddleCentreY = paddleY + paddleHeight * 0.5
    end
  else 
    if isCharging then
      isCharging = false
      -- Check if the paddle is within the target area when released
      -- subtract or add paddleHeight for better feel
      if (paddleCentreY) >= (targetTopY-paddleHeight) and (paddleCentreY) <= (targetBottomY+paddleHeight) then
        sounds.rooster:stop()
        sounds.rooster:play()
        print("Hit", "Target Size:", currentTargetSize, "Paddle Y:", paddleY, "Target Top Y:", targetTopY, "Target Bottom Y:", targetBottomY)
        screenShake.trigger(5*chargeBarHeight/paddleY, 0.5) -- Trigger a screen shake with strength 5 and duration 0.5 seconds
        generateTarget() -- Generate a new target after a successful hit
      else
        print("Miss", "Target Size:", currentTargetSize, "Paddle Y:", paddleY, "Target Top Y:", targetTopY, "Target Bottom Y:", targetBottomY)
      end
    end
    sounds.chicken:stop()
    resetPaddle()
  end
end

function gameplay:enter()
  screenShake.stop()
  generateTarget()
  resetPaddle()
  --screenShake.trigger(5, 1.0) -- Trigger a screen shake with strength 5 and duration 0.5 seconds
end


function gameplay:update(dt)
  screenShake.update(dt)
  growTarget(dt)
  handlePaddle(dt)

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

  -- draw the target as a rectangle that grows in size over time
  targetTopY = targetCentreY - currentTargetSize / 2
  targetBottomY = targetCentreY + currentTargetSize / 2
  love.graphics.rectangle("fill", chargeBarX, targetTopY, chargeBarWidth, currentTargetSize) 

  -- draw the paddle
  love.graphics.rectangle("fill", paddleX, paddleY, paddleWidth, paddleHeight,5)
  
 -- self:drawArrow()

  -- screenShake is applied to the drawing, so we need to reset the translation after drawing
  love.graphics.translate(-screenShake.shakeOffsetX, -screenShake.shakeOffsetY)

  push:apply("end")
end

return gameplay

--love.graphics.draw(arrow, GAMEWIDTH * 0.1 + (GAMEWIDTH * 0.8) * 0.5 - arrow:getWidth() * 0.5, GAMEHEIGHT * 0.15 + (GAMEHEIGHT * 0.05) * 0.5 - arrow:getHeight() * 0.5)