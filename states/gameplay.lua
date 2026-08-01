local screenShake = require "lib/screenShake" --require the library

local gameplay = {
  enterTime = 0.0,
  nextState = nil,
  screenTime = 3.0,
  shakeStartTime = 2.0, -- Time after which the screen shake starts
  shakeDuration = 1.0, -- Duration of the screen shakeTimeLeft
  shakeMagnitude = 20 -- Magnitude of the screen shake
  
}

function gameplay:enter()
  screenShake.stop()
  --screenShake.trigger(5, 1.0) -- Trigger a screen shake with strength 5 and duration 0.5 seconds
end

function gameplay:draw()
  push:apply("start")
  love.graphics.translate(screenShake.shakeOffsetX, screenShake.shakeOffsetY)
  love.graphics.setColor(themes.current.secondary)
  love.graphics.rectangle("fill", 0, 0, GAMEWIDTH, GAMEHEIGHT)
  
  local mouseX, mouseY = love.mouse.getPosition()
  mouseX, mouseY = push:toGame(mouseX, mouseY)
  --nil is returned if mouse is outside the game screen

  
  love.graphics.setColor(themes.current.primary)
  love.graphics.setFont(LargeFont)

  if mouseX and mouseY then love.graphics.circle("line", mouseX, mouseY, 10) end
  
  love.graphics.printf("mouse x : " .. (mouseX or "outside"), 25, 25, GAMEWIDTH, "left")
  love.graphics.printf("mouse y : " .. (mouseY or "outside"), 25, 50, GAMEWIDTH, "left")
  love.graphics.printf("shake works ya cunt", 25, 75, GAMEWIDTH, "left")
  love.graphics.translate(-screenShake.shakeOffsetX, -screenShake.shakeOffsetY)
  push:apply("end")
end

function gameplay:update(dt)
  screenShake.update(dt) --update game logic here
  if love.mouse.isDown(1) then
    screenShake.trigger(20, 0.1) 
  end
end

return gameplay