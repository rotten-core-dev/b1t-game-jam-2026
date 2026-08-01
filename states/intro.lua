screenShake = require "lib/screenShake" --require the library

local intro = {
  enterTime = 0.0,
  nextState = require("states/title"),
  screenTime = 2.0,
  shakeStartTime = 1.0, -- Time after which the screen shake starts
  shakeDuration = 1.0, -- Duration of the screen shakeTimeLeft
  shakeMagnitude = 5 -- Magnitude of the screen shake
  
}

function intro:enter()
  self.enterTime = love.timer.getTime()
end

function intro:draw()
  push:apply("start")
  love.graphics.translate(screenShake.shakeOffsetX, screenShake.shakeOffsetY)
  love.graphics.setColor(themes.current.secondary)
  love.graphics.rectangle("fill", 0, 0, GAMEWIDTH, GAMEHEIGHT)

  
  local mouseX, mouseY = love.mouse.getPosition()
  mouseX, mouseY = push:toGame(mouseX, mouseY)
  --nil is returned if mouse is outside the game screen
  love.graphics.setFont(LargeFont)
  love.graphics.setColor(themes.current.primary)
  if mouseX and mouseY then love.graphics.circle("line", mouseX, mouseY, 10) end

  love.graphics.printf("Rotten Core Games", 0, GAMEHEIGHT/3, GAMEWIDTH, "center")
  love.graphics.printf("Presents", 0, GAMEHEIGHT/2, GAMEWIDTH, "center")
  love.graphics.translate(-screenShake.shakeOffsetX, -screenShake.shakeOffsetY)
  push:apply("end")
end

function intro:update(dt)
  screenShake.update(dt) --update game logic here
  if love.timer.getTime() - self.enterTime >= self.shakeStartTime and not screenShake.isShaking() then
    screenShake.trigger(self.shakeMagnitude, self.shakeDuration) -- Trigger a screen shake with strength 5 and duration 1.0 seconds
  end
  if love.timer.getTime() - self.enterTime >= self.screenTime or love.mouse.isDown(1) then
    state.switch(self.nextState) --switch to the next state
  end
end


  
return intro