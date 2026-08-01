--[[ Mouse input ]]--

return function ()
  
  function love.draw()
    push:apply("start")
    
    love.graphics.setColor(50, 0, 0)
    love.graphics.rectangle("fill", 0, 0, GAMEWIDTH, GAMEHEIGHT)
    
    local mouseX, mouseY = love.mouse.getPosition()
    mouseX, mouseY = push:toGame(mouseX, mouseY)
    --nil is returned if mouse is outside the game screen
    
    love.graphics.setColor(255, 255, 255)
    if mouseX and mouseY then love.graphics.circle("line", mouseX, mouseY, 10) end
    
    love.graphics.printf("mouse x : " .. (mouseX or "outside"), 25, 25, GAMEWIDTH, "left")
    love.graphics.printf("mouse y : " .. (mouseY or "outside"), 25, 50, GAMEWIDTH, "left")
    love.graphics.printf("title", 25, 75, GAMEWIDTH, "left")
    
    push:apply("end")
  end
  
end