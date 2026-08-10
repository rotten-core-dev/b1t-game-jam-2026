local screenShake = require "lib/screenShake" --require the library
local sounds = require "src/sounds" --require the library
local camera = require "lib/camera" --require the library
--local gameover = require("states/gameover")
--local titleState = require("states/title")
local rot = 0
local gameplay = {
  enterTime = 0.0,
  nextState = nil,
  screenTime = 3.0,
  shakeStartTime = 2.0, -- Time after which the screen shake starts
  shakeDuration = 1.0, -- Duration of the screen shakeTimeLeft
  shakeMagnitude = 20, -- Magnitude of the screen shake
  hit = false,
  hitTime = currentTime,
  hitPause = 1,
  hitPauseWait = 2,
  snorePause = 1.25,
  setNewTarget = false,
  playOnce = true,
  trigTime = currentTime,
  trigTimePause = 0.1,
  trigTimeOnce = false,
  successfulHits = 0,
  countdownTimer = 0.0,
  isCountdownPaused = false,
  stoppageTime = 0.0,
}

local debug = true
local isGameOver = false
local awakePercentage = 0.00

local button = {
  
    width = GAMEWIDTH * 0.2,
    height = GAMEHEIGHT * 0.1,
    x = GAMEWIDTH * 0.5 - (GAMEWIDTH * 0.2) * 0.5, -- have  to center here if we want it centered
    y = GAMEHEIGHT * 0.85,
    text = "RETRY"
}

local function isButtonHovered()
  local mouseX, mouseY = love.mouse.getPosition()
  mouseX, mouseY = push:toGame(mouseX, mouseY)
  if not mouseX or not mouseY then
    return false
  end
  return mouseX >= button.x and mouseX <= button.x + button.width and
         mouseY >= button.y and mouseY <= button.y + button.height   
end
--- IMG ---




----------

-- charge bar dimensions and position
local chargeBarX, chargeBarY = GAMEWIDTH * 0.9, GAMEHEIGHT * 0.15
local chargeBarWidth, chargeBarHeight = GAMEWIDTH * 0.05, GAMEHEIGHT * 0.8

-- paddle dimensions and position
local paddleWidth, paddleHeight = chargeBarWidth + 10, 10
local paddleX = chargeBarX - (paddleWidth - chargeBarWidth) * 0.5
local paddleY = chargeBarY + chargeBarHeight - paddleHeight
local paddleCentreY = paddleY + paddleHeight * 0.5
local paddleSpeed = 1 * chargeBarHeight-- paddle moves at half the height of the charge bar per second
local isCharging = false -- flag to indicate if the paddle is charging

-- target dimensions and position
local targetStartSize = 10
local targetMaxSize = chargeBarHeight / 10
local targetGrowthRate = targetMaxSize / 3 -- target grows to max size in 3 seconds
local currentTargetSize = targetStartSize -- used to keep track of target size as it grows
local targetCentreY = 0
local targetTopY = targetCentreY - currentTargetSize / 2
local targetBottomY = targetCentreY + currentTargetSize



local function handleTimers(dt)
  if isGameOver then return end
  if gameplay.isCountdownPaused then
    gameplay.stoppageTime = gameplay.stoppageTime + 500 * dt
  else
    gameplay.countdownTimer = gameplay.countdownTimer + (500 * dt)
  end
end

local function calculateAwakePercentage()
  if gameplay.countdownTimer > 0 then
    awakePercentage = gameplay.stoppageTime / (gameplay.countdownTimer + gameplay.stoppageTime)
  end
end

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

local function drawArt(art,x,y,wob,wobSpeed)
  local wob = wob or 0
  local time = love.timer.getTime()
  local wobbleAmount = wob * 0.005  -- Max rotation
  local wobbleOffset = wob * 0.05    -- Max position offset
  local wobSpeed = wobSpeed or 0
  local popScale = 1
  local x = x or 0
  local y = y or 0 
  local artScale = 0.5--GAMEWIDTH * 0.2 --/ art:getWidth()
  local artWidth = art:getWidth() * artScale
  local artHeight = art:getHeight()* artScale
  local artX = 0 --GAMEWIDTH * 0.5 - artWidth * 0.5
  local artY = 0--GAMEHEIGHT * 0.2
  -- x = x + artX
  -- y = y + artY
  
  local rotWobble = math.sin(time * wobSpeed +x + y) * wobbleAmount
  local xWobble = math.sin(time * 1.5 + x * 0.5) * wobbleOffset
  local yWobble = math.cos(time * 1.7 + y * 0.7) * wobbleOffset
  
  local centerX = x - (artWidth/2) - xWobble
  local centerY = y - (artHeight/2) - yWobble
  love.graphics.push()
  love.graphics.setColor(1,1,1,1)
  love.graphics.translate(artWidth/2, y)
  love.graphics.rotate(rotWobble)
  love.graphics.translate(-artWidth/2, -y)
  love.graphics.draw(art, centerX, centerY, 0, artScale, artScale)
  love.graphics.pop()
end

local function drawClock()

  local  x = GAMEWIDTH * 0.1
  local  y = GAMEHEIGHT * 0.7
  local  width = GAMEWIDTH * 0.2
  local  height = GAMEHEIGHT * 0.1
  local  minutes = math.floor(gameplay.countdownTimer / 60)
  local  seconds = math.floor(gameplay.countdownTimer % 60)
  local  text = string.format("5:%02d:%02d", minutes, seconds)
  if minutes >= 60 then
    text = "6:00:00"
  end

  -- invert colors if countdown is paused
  love.graphics.setFont(ClockFont)
  if gameplay.isCountdownPaused then
    love.graphics.setColor(themes.current.primary)
    love.graphics.rectangle("line", x, y, width, height)
    love.graphics.printf(text, x, y , width, "center")
  else 
    love.graphics.setColor(themes.current.primary)
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(themes.current.secondary)
    love.graphics.printf(text, x, y , width, "center")
    
  end
  -- if debug then
  --   love.graphics.setColor(themes.current.primary)
  --   love.graphics.setFont(SmallFont)
  --   love.graphics.printf(string.format("Stoppage Time: %.2f", gameplay.stoppageTime), x, y - height, width, "center")
  -- end

end



local function drawGameOver()

  love.graphics.setColor(themes.current.primary)
  love.graphics.setFont(TitleFont)
  love.graphics.printf("GAME OVER", 0, GAMEHEIGHT * 0.2, GAMEWIDTH, "center")
  love.graphics.setFont(LargeFont)
  love.graphics.printf(string.format("The boss was %.0f%% awake", awakePercentage * 100), 0, GAMEHEIGHT * 0.35, GAMEWIDTH, "center")
  love.graphics.printf(string.format("but it was not enough", awakePercentage * 100), 0, GAMEHEIGHT * 0.45, GAMEWIDTH, "center")
  love.graphics.printf(string.format("you have been replaced by tech", awakePercentage * 100), 0, GAMEHEIGHT * 0.5, GAMEWIDTH, "center")



    -- changes scale and height of cover art
  local artScaleFactor = 1
  local artYModifier = 0.125
  local art = toolate

  local artScale = GAMEWIDTH * artScaleFactor / art:getWidth()
  local artWidth = art:getWidth() * artScale
  local artX = GAMEWIDTH * 0.5 - artWidth * 0.5
  local artY = GAMEHEIGHT * artYModifier - 30

  love.graphics.draw(art, artX, artY, artRotation, artScale, artScale)


end

local function drawMouseCursor()
  local mouseX, mouseY = love.mouse.getPosition()
  mouseX, mouseY = push:toGame(mouseX, mouseY)
  --nil is returned if mouse is outside the game screen
  love.graphics.setColor(themes.current.primary)
  if mouseX and mouseY then love.graphics.circle("line", mouseX, mouseY, 10) end
end

local function drawButton()

  love.graphics.setFont(TitleFont)
  local cornerRadius = button.height / 4
  -- Button colors invert on hover and click
  if isButtonHovered() and not love.mouse.isDown(1) then
    love.graphics.setColor(themes.current.secondary)
    love.graphics.rectangle("fill", button.x, button.y, button.width, button.height, cornerRadius)
    --text
    love.graphics.setColor(themes.current.primary)
    love.graphics.printf(button.text, button.x, button.y, button.width, "center")

  else
    love.graphics.setColor(themes.current.secondary)
    love.graphics.rectangle("line", button.x, button.y, button.width, button.height, cornerRadius)
    --text
    love.graphics.printf(button.text, button.x, button.y, button.width, "center")
  end
end
  
local function drawTarget()
  if gameplay.setNewTarget then return end
  -- draw the target as a rectangle that grows in size over time
  targetTopY = targetCentreY - currentTargetSize / 2
  targetBottomY = targetCentreY + currentTargetSize / 2
  love.graphics.rectangle("fill", chargeBarX, targetTopY, chargeBarWidth, currentTargetSize) 
end

local function growTarget(dt)
  if gameplay.setNewTarget then return end
  if currentTargetSize < targetMaxSize then
    currentTargetSize = currentTargetSize + targetGrowthRate * dt
    if currentTargetSize > targetMaxSize then
      currentTargetSize = targetMaxSize
    end
  end
end

local function handlePaddle(dt)
  -- found a bug where if the player is moving the paddle when time goes over 60 seconds, 
  -- the paddle will continue to move and the player can still hit the target. This is a fix for that bug.
  if gameplay.countdownTimer >= 3600 or isGameOver then return end
  
  if love.mouse.isDown(1) or love.keyboard.isDown("space") then
    isCharging = true
    if gameplay.playOnce then
      -- sounds.chicken:play()
      sounds.gasp:play()
      gameplay.playOnce = false
    end
    local paddleBarRatio = chargeBarHeight/paddleY
    local randomMagnitude = love.math.random(1, 2) 
    screenShake.trigger(randomMagnitude*paddleBarRatio, 0.1)
    love.audio.setVolume(paddleBarRatio)
    if paddleY > chargeBarY then
      paddleY = paddleY - paddleSpeed * dt
      paddleCentreY = paddleY + paddleHeight * 0.5
    end
  else 
    -- sounds.chicken:stop()
    sounds.gasp:stop()
    gameplay.playOnce = true
    if isCharging then
      isCharging = false
      
      -- Check if the paddle is within the target area when released
      -- subtract or add paddleHeight for better feel
      if (paddleCentreY) >= (targetTopY-paddleHeight) and (paddleCentreY) <= (targetBottomY+paddleHeight)
      and currentTime - gameplay.hitPause > gameplay.hitTime
      then
        gameplay.successfulHits = gameplay.successfulHits + 1
        sounds.rooster:stop()
        sounds.rooster:play()
        sounds.snore:stop()
        sounds.lalaby:stop()
        gameplay.hitTime = currentTime

        gameplay.trigTime = currentTime
        gameplay.trigTimeOnce = true
        gameplay.setNewTarget = true
        screenShake.trigger(2, 0.5) -- Trigger a screen shake with strength 5 and duration 0.5 seconds


        if debug then
          -- print("Hit", "Target Size:", currentTargetSize, "Paddle Y:", paddleY, "Target Top Y:", targetTopY, "Target Bottom Y:", targetBottomY)
        end
        -- print("Hit", "Target Size:", currentTargetSize, "Paddle Y:", paddleY, "Target Top Y:", targetTopY, "Target Bottom Y:", targetBottomY)
        -- gameplay.hit = true
        -- gameplay.hitTime = currentTime
        -- generateTarget() -- Generate a new target after a successful hit
      else
        sounds.chicken:play()
        screenShake.trigger(7, 0.1)


        if debug then
          print("Miss", "Target Size:", currentTargetSize, "Paddle Y:", paddleY, "Target Top Y:", targetTopY, "Target Bottom Y:", targetBottomY)
        end
      end
    end


        -- sounds.chicken:stop()
    resetPaddle()
  end
end

local function restartGame()
  isGameOver = false
  awakePercentage = 0.00
  gameplay.successfulHits = 0
  gameplay.countdownTimer = 0.0
  gameplay.stoppageTime = 0.0
  resetPaddle()
  generateTarget()
end

function gameplay:enter()
  screenShake.stop()
  generateTarget()
  resetPaddle()
  gameplay.countdownTimer = love.timer.getTime()
  sounds.snore:play()
  sounds.lalaby:play()

  -- screenShake.trigger(5, 1.0) -- Trigger a screen shake with strength 5 and duration 0.5 seconds
end


function gameplay:update(dt)
  screenShake.update(dt)
  if gameplay.countdownTimer >= 3600 or (debug and love.keyboard.isDown("g"))  then
    calculateAwakePercentage()
    isGameOver = true
    sounds.snore:stop()
    sounds.lalaby:stop()
  end

  if isGameOver then
    if (isButtonHovered() and love.mouse.isDown(1)) or love.keyboard.isDown("return") then
      restartGame()
    end
  else
    growTarget(dt)
    handlePaddle(dt)
    handleTimers(dt)
    
    if currentTime - gameplay.trigTimePause > gameplay.trigTime 
    and gameplay.trigTimeOnce then
      gameplay.hit = true
      gameplay.isCountdownPaused = true
      sounds.dudeGasp:play()
      sounds.dudeGasp2:play()
      gameplay.trigTimeOnce = false
    end
    if currentTime - gameplay.hitPause > gameplay.hitTime then
      
      if not gameplay.setNewTarget then
        rot = math.min(chargeBarHeight/paddleY - 1.2, 1.3)
      end

      sounds.lalaby:play()
      if gameplay.setNewTarget 
      and  currentTime - (gameplay.hitPause*gameplay.hitPauseWait) > gameplay.hitTime 
      then
        generateTarget() -- Generate a new target after a successful hit
        gameplay.isCountdownPaused = false
        sounds.click:play()
        gameplay.setNewTarget = false
        sounds.dudeGasp:stop()
      elseif gameplay.setNewTarget 
      and  currentTime - (gameplay.hitPause*(gameplay.snorePause)) > gameplay.hitTime
      then
        sounds.snore:play()

      end
      gameplay.hit = false
    end
  end
end

function gameplay:draw()
  push:apply("start")

  love.graphics.translate(screenShake.shakeOffsetX, screenShake.shakeOffsetY)

  if isGameOver then
    drawGameOver()
    drawMouseCursor()
    drawButton()
  else
  
    local padH = (chargeBarHeight/paddleY)
    if padH < 1 then padH = 0 end
    padH = padH * 0.2
    local dx  = love.math.random(-padH, padH)
    local dy = love.math.random(-padH, padH)


    -- screen shake is handled by the screenShake library, which modifies the drawing position based on the shake offset
    love.graphics.translate(dx, dy)


    -- this is the background color
    love.graphics.setColor(themes.current.primary)
    love.graphics.rectangle("fill", 0, 0, GAMEWIDTH, GAMEHEIGHT)

    -- set the foreground color to the primary color
    love.graphics.setColor(themes.current.primary)




  -- background
    local xm = GAMEWIDTH/2
    local ym = GAMEHEIGHT/2
    local hx = xm
    local hy = ym
    local cx = xm + (gameplay.countdownTimer/2) - 1000
    local bgy = ym - (gameplay.countdownTimer/4) + 500


    drawArt(bg.sky,xm,bgy,0,0)
    drawArt(bg.clouds,cx,ym,0,0)
    drawArt(bg.bg,xm,ym+ 20,0,0)





        -- Rooster
        
    local xm = GAMEWIDTH/2 + 20
    local ym = GAMEHEIGHT/2 - 40 - 50 + (paddleY/3)
    local hx = xm
    local hy = ym
    local art = imageRooster.still
    local wobSpeed = 20

    if gameplay.hit then
      art = imageRooster.crow
      ym = GAMEHEIGHT/2 - 80 
      wobSpeed = 100
    end
    drawArt(art,xm+35,ym + 60,2,wobSpeed)

            
    -- local xm = GAMEWIDTH/2 + 50
    -- local ym = GAMEHEIGHT/2 - 30
    -- local hx = xm
    -- local hy = ym
    -- local headRot = 0 
    -- local eyeMod = 0
    -- local eyeShake = 2
    -- local eyeSpeed = 4
    -- local eyeArt = imageGuy.eyesClosed
    -- local longeyes = 0
    -- -- local rot = 0

    -- -- rot = math.min(chargeBarHeight/paddleY - 1.2, 1.3)

    -- if gameplay.hit then
    --   eyeMod = -20
    --   eyeShake = 2
    --   eyeSpeed = 20
    --   eyeArt = imageGuy.eyesOpen
    --   longeyes = math.min((gameplay.successfulHits), 10)
    -- end
    -- drawArt(imageRooster.body,xm+35,ym + 60,0,0)
    -- drawArt(imageRooster.tail,xm+105,ym + 60,0,0)
    -- drawArt(imageRooster.wing,xm+45,ym + 90,0,0)

    
  

    -- love.graphics.push()
    -- love.graphics.setColor(1,1,1,1)
    -- love.graphics.translate(hx+10, hy)
    -- love.graphics.rotate(rot)
    -- drawArt(imageRooster.head,0, 0,0,0)
    -- drawArt(imageRooster.beakBtm,-37,   5,0,0)
    -- drawArt(imageRooster.beakTop,-37,  - 5,0,0)
    -- love.graphics.translate(-hx+10, -hy)
    -- love.graphics.pop()


      -- frame
    local xm = GAMEWIDTH/2
    local ym = GAMEHEIGHT/2
    local hx = xm
    local hy = ym

    drawArt(bg.frame,xm,ym,0,0)
    drawArt(bg.wall,xm,ym,0,0)


    --nil is returned if mouse is outside the game screen
    -- local mouseX, mouseY = love.mouse.getPosition()
    -- mouseX, mouseY = push:toGame(mouseX, mouseY)

    -- draws the mouse cursor as a circle at the mouse position
    --if mouseX and mouseY then love.graphics.circle("line", mouseX, mouseY, 10) end

    -- title at top of screen  
    love.graphics.setFont(LargeFont)
    love.graphics.printf("COCK-A-DOODLE-DO!", 0, GAMEHEIGHT * 0.04, GAMEWIDTH, "center")

    -- instructions  
  love.graphics.setFont(SmallFont)
  love.graphics.printf("Hold [SPACE] or Mouse", 0, GAMEHEIGHT * 0.15, GAMEWIDTH* 0.99, "center")
  -- if isGameOver then
  --   love.graphics.setFont(LargeFont)
  --   love.graphics.printf("GAME OVER", 0, GAMEHEIGHT * 0.2, GAMEWIDTH, "center")
  --   love.graphics.setFont(LargeFont)
  --   love.graphics.printf(string.format("The boss was %.0f%% awake ", awakePercentage * 100), 0, GAMEHEIGHT * 0.3, GAMEWIDTH, "center")
  --   love.graphics.printf("dead", 0, GAMEHEIGHT * 0.4, GAMEWIDTH, "center")
  --   love.graphics.printf("you have been replaced by tech", 0, GAMEHEIGHT * 0.5, GAMEWIDTH, "center")

  --     -- frame
  --   local xm = GAMEWIDTH/2
  --   local ym = GAMEHEIGHT/2
  --   local hx = xm
  --   local hy = ym

  --   drawArt(imageRooster.crow,xm,ym,0,0)

  -- end
  -- draw a rectangle towards right of screen for our charging and timing bar
  love.graphics.rectangle("line", chargeBarX, chargeBarY, chargeBarWidth, chargeBarHeight)

  -- draw a rectangle towards left of screen for our time remaining bar
  love.graphics.rectangle("line", GAMEWIDTH * 0.1, chargeBarY, chargeBarWidth, chargeBarHeight)

  -- fill the timer bar
  love.graphics.rectangle("fill", GAMEWIDTH * 0.1, chargeBarY, chargeBarWidth, chargeBarHeight * (gameplay.countdownTimer / 3600))

    drawTarget()
    -- draw the paddle
    love.graphics.rectangle("fill", paddleX, paddleY, paddleWidth, paddleHeight,5)

  -- self:drawArrow()
  --drawClock()
  -- guy
  local xm = GAMEWIDTH/2
  local ym = GAMEHEIGHT/2 + 70
  local eyeMod = 0
  local eyeShake = 2
  local eyeSpeed = 4
  local eyeArt = imageGuy.eyesClosed
  local longeyes = 0

    if gameplay.hit then
      eyeMod = -20
      eyeShake = 2
      eyeSpeed = 20
      eyeArt = imageGuy.eyesOpen
      longeyes = math.min((gameplay.successfulHits), 10)
    end



    drawArt(imageGuy.pillow,xm,ym + 13,0,0)
    if gameplay.hit then
      drawArt(imageGuy.hands,xm,ym + 20 - (eyeMod*0.7),eyeShake,eyeSpeed)
    end
    drawArt(imageGuy.head,xm+6,ym-5 +10 - (eyeMod*0.5),eyeShake,eyeSpeed)
    drawArt(eyeArt,xm,ym+20 + (eyeMod*0.2) - longeyes,eyeShake,eyeSpeed)
    drawArt(imageGuy.bed,xm,ym+45,0,0)

    drawArt(imageGuy.beard,xm,ym + 30 - (eyeMod*0.2),eyeShake,eyeSpeed)
    drawArt(imageGuy.stash,xm,ym + 13 + (eyeMod*0.4),eyeShake,eyeSpeed)





    -- if gameplay.hit then
    --   drawArt(imageGuy.pillow,0,yMaster + 10)
    --   drawArt(imageGuy.hands,0,yMaster + 10)
    --   drawArt(imageGuy.head,0,yMaster + 10)
    --   drawArt(imageGuy.eyesOpen,0,yMaster -20)---60)
    --   drawArt(imageGuy.bed,0,yMaster)
    --   drawArt(imageGuy.beard,0,yMaster)
    --   drawArt(imageGuy.stash,0,yMaster -20)
    -- else
    --   drawArt(imageGuy.pillow,0,yMaster + 10)
    --   drawArt(imageGuy.head,0,yMaster -15)
    --   drawArt(imageGuy.eyesClosed,0,yMaster -10)
    --   drawArt(imageGuy.bed,0,yMaster)
    --   drawArt(imageGuy.beard,0,yMaster)
    --   drawArt(imageGuy.stash,0,yMaster)
    -- end

  

  end
  -- screenShake is applied to the drawing, so we need to reset the translation after drawing
  love.graphics.translate(-screenShake.shakeOffsetX, -screenShake.shakeOffsetY)


  push:apply("end")
end

return gameplay

--love.graphics.draw(arrow, GAMEWIDTH * 0.1 + (GAMEWIDTH * 0.8) * 0.5 - arrow:getWidth() * 0.5, GAMEHEIGHT * 0.15 + (GAMEHEIGHT * 0.05) * 0.5 - arrow:getHeight() * 0.5)