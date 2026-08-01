--[[ Mouse input ]]--

local title = {
  nextState = require("states/gameplay")
}

function title:enter()
  self.screenTime = 2.0
end
  
function title:draw()
  push:apply("start")

  love.graphics.setColor(themes.current.secondary)
  love.graphics.rectangle("fill", 0, 0, GAMEWIDTH, GAMEHEIGHT)
    
  local mouseX, mouseY = love.mouse.getPosition()
  mouseX, mouseY = push:toGame(mouseX, mouseY)
  --nil is returned if mouse is outside the game screen
  love.graphics.setFont(TitleFont)
  love.graphics.setColor(themes.current.primary)
  if mouseX and mouseY then love.graphics.circle("line", mouseX, mouseY, 10) end
  
  love.graphics.printf("COCK-A-DOODLE-DOO", 0, GAMEHEIGHT/3, GAMEWIDTH, "center")
  
  push:apply("end")
end



function title:update(dt)
  self.screenTime = self.screenTime - dt
  if self.screenTime <= 0 then
    state.switch(self.nextState) --switch to the next state
  end
end

return title