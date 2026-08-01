--[[ Mouse input ]]--

local intro = {
  nextState = require("states/title"),
  screenTime = 2.0,
  enterTime = 0.0
}

function intro:enter()
  self.enterTime = love.timer.getTime()
  --screenShake.trigger(5, 1.0) -- Trigger a screen shake with strength 5 and duration 0.5 seconds
end

function intro:draw()
  push:apply("start")
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
  push:apply("end")
end

function intro:update(dt)
  --screenShake.update(dt) --update game logic here
  if love.timer.getTime() - self.enterTime >= self.screenTime then
    state.switch(self.nextState) --switch to the next state
  end
end


  
return intro