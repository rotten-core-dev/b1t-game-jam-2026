local gameplay = {
  nextState = nil
}

function gameplay:enter()
  --screenShake.trigger(5, 1.0) -- Trigger a screen shake with strength 5 and duration 0.5 seconds
end

function gameplay:draw()
  push:apply("start")
  
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
  love.graphics.printf("gameplay", 25, 75, GAMEWIDTH, "left")

  push:apply("end")
end

function gameplay:update(dt)

end

return gameplay