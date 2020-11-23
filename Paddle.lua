Paddle = Class{}

function Paddle:init(x, y, WIDTH, HEIGHT, SCORE, isAI)
    self.x = x
    self.y = y 
    self.WIDTH = WIDTH 
    self.HEIGHT = HEIGHT
    self.dy = 0
    self.SCORE = SCORE
    self.isAI = isAI
end

function Paddle:update(dt)
    if self.y <= 0 then
        self.y = math.max(0, self.y + self.dy * dt)
    elseif  self.y > 0 then
   
        self.y = math.min(V_HEIGHT - self.HEIGHT, self.y + self.dy * dt)      
    end
end

function Paddle:render()
    love.graphics.rectangle('fill', self.x, self.y, self.WIDTH, self.HEIGHT)
end