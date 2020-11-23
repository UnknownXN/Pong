Ball = Class{}

function Ball:init(x, y, WIDTH, HEIGHT)
    self.x = x
    self.y = y
    self.WIDTH = WIDTH
    self.HEIGHT = HEIGHT
    self.dx = getSpeed()
    self.dy = math.random(-bounce, bounce)
end
function Ball:reset()
    self.x = V_WIDTH / 2 - 2
    self.y = V_HEIGHT / 2 - 2
    self.dx = getSpeed()
    self.dy = math.random(-bounce, bounce)
end
function Ball:screenCollide()
    if self.y <= 0 then
        self.y = 0
        self.dy = -self.dy
        sounds['wallBlip']:play()
    elseif self.y >= V_HEIGHT - self.HEIGHT then
        self.y = V_HEIGHT - self.HEIGHT
        self.dy = -self.dy
        sounds['wallBlip']:play()
    end
end

function Ball:collides(box)
    if self.x > box.x + box.WIDTH or self.x + self.WIDTH < box.x then
        return false
    elseif self.y < box.y or self.y > box.y + box.HEIGHT then
        return false
    end
    
    return true

end
function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end
function Ball:render()
    love.graphics.rectangle('fill', self.x - 2, self.y - 2, self.WIDTH, self.HEIGHT)
end

function getSpeed()
    if server == 1 then
        x = ballSpeed
    elseif server == 2 then
        x = -ballSpeed
    end
    return x
end