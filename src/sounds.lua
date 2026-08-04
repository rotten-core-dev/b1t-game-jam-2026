--sounds

local sounds = {}
--music

--sound effects
sounds.crowing = love.audio.newSource("assets/sounds/crowing.ogg", "static")
sounds.chicken = love.audio.newSource("assets/sounds/chicken2.ogg", "static")
sounds.rooster = love.audio.newSource("assets/sounds/rooster3.ogg", "static")
sounds.gasp = love.audio.newSource("assets/sounds/gasp2.ogg", "static")
sounds.snore = love.audio.newSource("assets/sounds/snore2.ogg", "static")
sounds.dudeGasp = love.audio.newSource("assets/sounds/dudeGasp.ogg", "static")
sounds.dudeGasp2 = love.audio.newSource("assets/sounds/dudeGasp2.ogg", "static")
sounds.click = love.audio.newSource("assets/sounds/heavyClick.ogg", "static")
sounds.lalaby = love.audio.newSource("assets/sounds/lalaby.ogg", "static")



sounds.chicken:setVolume(0.7)
sounds.gasp:setVolume(0.5)
sounds.snore:setVolume(0.6)




return sounds