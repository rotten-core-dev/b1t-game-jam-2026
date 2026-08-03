local screenShake = require "lib/screenShake" --require the library
local sounds = require "src/sounds" --require the library



local title = {
  enterTime = 0.0,
  nextState = require("states/gameplay"),
  screenTime = 3.0,
  shakeStartTime = 0.0, -- Time after which the screen shake starts
  shakeDuration = 1.0, -- Duration of the screen shakeTimeLeft
  shakeMagnitude = 10 -- Magnitude of the screen shake
  

}

local button = {
    x = GAMEWIDTH * 0.6,
    y = GAMEHEIGHT * 0.7,
    width = GAMEWIDTH * 0.2,
    height = GAMEHEIGHT * 0.1,
    text = "PLAY"
}

local waitingToStart = false -- Flag to indicate if we are waiting to start the game

local function isButtonHovered()
  local mouseX, mouseY = love.mouse.getPosition()
  mouseX, mouseY = push:toGame(mouseX, mouseY)
  if not mouseX or not mouseY then
    return false
  end
  return mouseX >= button.x and mouseX <= button.x + button.width and
         mouseY >= button.y and mouseY <= button.y + button.height   
end

function title:enter()
  screenShake.stop() -- Stop any ongoing screen shake when entering the title state
  self.enterTime = love.timer.getTime()
  sounds.rooster:stop()
  sounds.rooster:play()
  screenShake.trigger(self.shakeMagnitude, self.shakeDuration)
end
  
function title:draw()
  push:apply("start")

  love.graphics.translate(screenShake.shakeOffsetX, screenShake.shakeOffsetY)
  love.graphics.setColor(themes.current.secondary)
  love.graphics.rectangle("fill", 0, 0, GAMEWIDTH, GAMEHEIGHT)
    
  local mouseX, mouseY = love.mouse.getPosition()
  mouseX, mouseY = push:toGame(mouseX, mouseY)
  --nil is returned if mouse is outside the game screen
  love.graphics.setFont(TitleFont)
  love.graphics.setColor(themes.current.primary)
  if mouseX and mouseY then love.graphics.circle("line", mouseX, mouseY, 10) end

  -- preserve art color
  love.graphics.setColor(1,1,1,1)
  local artRotation = 0
  -- image is larger than gamewidth so we need to scale it down to fit within the game width
  -- we will use the one scale for x and y to maintain the aspect ratio
  local artScale = GAMEWIDTH * 0.8 / CoverArt:getWidth()
  local artWidth = CoverArt:getWidth() * artScale
  local artHeight = CoverArt:getHeight() * artScale
  local artX = GAMEWIDTH * 0.5 - artWidth * 0.5
  local artY = GAMEHEIGHT * 0.2
  love.graphics.draw(CoverArt, artX, artY, artRotation, artScale, artScale)

  --love.graphics.printf("COCK-A-DOODLE-DOO", 0, GAMEHEIGHT/3, GAMEWIDTH, "center")
  love.graphics.translate(-screenShake.shakeOffsetX, -screenShake.shakeOffsetY)

  if waitingToStart then

    -- draw button
    local textWidth = TitleFont:getWidth(button.text)
    local textHeight = TitleFont:getHeight(button.text)
  
    if isButtonHovered() and not love.mouse.isDown(1) then
      love.graphics.setColor(themes.current.primary)
      love.graphics.rectangle("fill", button.x, button.y, button.width, button.height, button.height/4)
      --text
      love.graphics.setColor(themes.current.secondary)
      love.graphics.printf(button.text, button.x, button.y , button.width, "center")

    else
      love.graphics.setColor(themes.current.primary)
      love.graphics.rectangle("line", button.x, button.y, button.width, button.height, button.height/4)
      --text
      love.graphics.printf(button.text, button.x, button.y , button.width, "center")
    end
    
  end

  push:apply("end")
end



function title:update(dt)
  screenShake.update(dt) 
  if love.timer.getTime() - self.enterTime >= self.screenTime or love.mouse.isDown(1) or love.keyboard.isDown("space") then
    screenShake.stop() -- Stop the screen shake
    waitingToStart = true -- Set the flag to indicate we are waiting to start the game
  end
  if waitingToStart then
    if isButtonHovered() and love.mouse.isDown(1) then
      state.switch(self.nextState)
      waitingToStart = false -- Reset the flag after switching states
    end
  end
end

return title