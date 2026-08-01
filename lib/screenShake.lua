local screenShake = {
        -- screen shake state
    shakeTimeLeft = 0,
    shakeDuration = 0,
    shakeMagnitude = 0,
    shakeOffsetX = 0,
    shakeOffsetY = 0,
    screenShaking = false
}

function screenShake.trigger(strength, duration)
    screenShake.shakeMagnitude = math.max(screenShake.shakeMagnitude, strength)
    screenShake.shakeDuration = math.max(screenShake.shakeDuration, duration)
    screenShake.shakeTimeLeft = math.max(screenShake.shakeTimeLeft, duration)
end

function screenShake.stop()
    screenShake.shakeTimeLeft = 0
    screenShake.shakeMagnitude = 0
    screenShake.shakeDuration = 0
    screenShake.shakeOffsetX = 0
    screenShake.shakeOffsetY = 0
end

function screenShake.updateScreenShake(dt)
    if screenShake.shakeTimeLeft > 0 then
        screenShake.shakeTimeLeft = math.max(0, screenShake.shakeTimeLeft - dt)
        local ratio = screenShake.shakeTimeLeft / math.max(screenShake.shakeDuration, 0.0001)
        local currentMagnitude = screenShake.shakeMagnitude * math.max(0, ratio)

        screenShake.shakeOffsetX = math.random(-currentMagnitude, currentMagnitude)
        screenShake.shakeOffsetY = math.random(-currentMagnitude, currentMagnitude)

        if screenShake.shakeTimeLeft <= 0 then
            screenShake.shakeMagnitude = 0
            screenShake.shakeDuration = 0
            screenShake.shakeOffsetX = 0
            screenShake.shakeOffsetY = 0
        end
    else
        screenShake.shakeOffsetX = 0
        screenShake.shakeOffsetY = 0
    end
end

function screenShake.isShaking()
    return screenShake.shakeTimeLeft > 0
end

function screenShake.update(dt)
    screenShake.updateScreenShake(dt)
end


function screenShake.draw()
    -- Apply the screen shake offset to the drawing
    love.graphics.translate(screenShake.shakeOffsetX, screenShake.shakeOffsetY)
end


return screenShake