local screenShake = require "lib/screenShake" --require the library

local title = {
  enterTime = 0.0,
  nextState = require("states/gameplay"),
  screenTime = 3.0,
  shakeStartTime = 2.0, -- Time after which the screen shake starts
  shakeDuration = 1.0, -- Duration of the screen shakeTimeLeft
  shakeMagnitude = 10 -- Magnitude of the screen shake
  

}

function title:enter()
  screenShake.stop() -- Stop any ongoing screen shake when entering the title state
  self.enterTime = love.timer.getTime()
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
  
  love.graphics.printf("COCK-A-DOODLE-DOO", 0, GAMEHEIGHT/3, GAMEWIDTH, "center")
  love.graphics.translate(-screenShake.shakeOffsetX, -screenShake.shakeOffsetY)
  push:apply("end")
end



function title:update(dt)
  screenShake.update(dt) --update game logic here
  if love.timer.getTime() - self.enterTime >= self.shakeStartTime and not screenShake.isShaking() then
    screenShake.trigger(self.shakeMagnitude, self.shakeDuration) -- Trigger a screen shake with strength 5 and duration 1.0 seconds
  end
  if love.timer.getTime() - self.enterTime >= self.screenTime or love.mouse.isDown(1) then
    screenShake.stop() -- Stop the screen shake
    state.switch(self.nextState) --switch to the next state
  end
end

return title