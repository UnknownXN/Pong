--things to adjust; bounce, AI PADDLE SPEED, ball speed
-- add option to decide number of players
--print number and add rectangle without fill around number use arrow keys to change players
W_WIDTH = 1280
W_HEIGHT = 720
V_WIDTH = 432
V_HEIGHT = 243
PADDLE_SPEED = 200
AI_PADDLE_SPEED = 200
ballSpeed = 250
push = require 'push'
Class = require 'class'
bounce = 150
require 'Paddle'
require 'Ball'
rallies = 0
sounds = {
    ['paddleBlip'] = love.audio.newSource('sounds/paddleBlip.wav', 'static'),
    ['point'] = love.audio.newSource('sounds/point.wav', 'static'),
    ['wallBlip'] = love.audio.newSource('sounds/wallBlip.wav', 'static'),
    ['win'] = love.audio.newSource('sounds/win.wav', 'static')
}
players = 1
server = math.random(2) == 1 and 1 or 2
choosing = true
winner = 0 

function love.load(key)
    love.window.setTitle('Pong')
    
    --initializes paddles and ball
    player1 = Paddle(10, 35, 5, 35, 0)
    player2 = Paddle(V_WIDTH - 15, V_HEIGHT - 70, 5, 35, 0, false)
   
    Ball = Ball(V_WIDTH / 2 - 2, V_HEIGHT / 2 - 2, 4, 4)

    love.graphics.setDefaultFilter('nearest', 'nearest')
    smallFont = love.graphics.newFont('smallFont.ttf', 8)
    largeFont = love.graphics.newFont('smallFont.ttf', 32)
    mediumFont = love.graphics.newFont('smallFont.ttf', 16)
    --scores
    

    push:setupScreen(V_WIDTH, V_HEIGHT, W_WIDTH, W_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })

    --initial game state
    gameState = 'start'
    paused = false

end

function love.resize(w, h)
    push:resize(w, h)
    
end

function love.update(dt)
    --moves player 1 (with w and s)
    math.randomseed(os.time())
    if love.keyboard.isDown('w') and paused ~= true then
        player1.dy = -PADDLE_SPEED 
    elseif love.keyboard.isDown('s') and paused ~= true then
        player1.dy = PADDLE_SPEED 
    else
        player1.dy = 0
    end
    --the AI
    --moves player 2 (with arrow keys)
    --if ball is within paddle, dont move
    --0.8 so that it's not dangerously close to edge
    if player2.isAI then
        if paused ~= true and Ball.y + 0.5 * Ball.HEIGHT > player2.y + player2.HEIGHT * 0.2 and Ball.y + 0.5 * Ball.HEIGHT < player2.y + 0.8 * player2.HEIGHT then  
            player2.dy = 0
        elseif paused ~= true and Ball.y < player2.y + 0.5 * player2.HEIGHT then
            player2.dy = -AI_PADDLE_SPEED
        elseif paused ~= true and Ball.y > player2.y + 0.5 * player2.HEIGHT then
            player2.dy = AI_PADDLE_SPEED
        else
            player2.dy = 0
        end
    elseif player2.isAI == false then
        if love.keyboard.isDown('up') and paused ~=true then
            player2.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('down') then
            player2.dy = PADDLE_SPEED
        else
            player2.dy = 0
        end
    end



    if gameState == 'play' then
        Ball:update(dt)
    end
    
    if Ball:collides(player1) then
        Ball.dx = -Ball.dx
        sounds['paddleBlip']:play()
        rallies = rallies + 0.5
        Ball.dy = math.random(-bounce, bounce)
    elseif Ball:collides(player2) then
        Ball.dx = -Ball.dx
        rallies = rallies + 0.5
        sounds['paddleBlip']:play()
        Ball.dy = math.random(-bounce, bounce)
        --gives the player a chance by decreasing it's speed slowly
        --caps out at a percentage of the original speed
        if rallies >= 4 and (AI_PADDLE_SPEED < 0.4 * PADDLE_SPEED) == false  then
            AI_PADDLE_SPEED = AI_PADDLE_SPEED - ((rallies / 40) * AI_PADDLE_SPEED) 
        end
        
        
    end

    Ball:screenCollide()
    player1:update(dt)
    player2:update(dt)

    if Ball.x + Ball.WIDTH < player1.x then
        player2.SCORE = player2.SCORE + 1
        sounds['point']:play()
        Ball:reset()
        gameState = 'start'
        server = 1
        rallies = 0
        AI_PADDLE_SPEED = PADDLE_SPEED
        victory(player1, player2)
    elseif Ball.x > player2.x + player2.WIDTH then
        player1.SCORE = player1.SCORE + 1
        sounds['point']:play()
        Ball:reset()
        gameState = 'start'
        server = 2
        rallies = 0
        AI_PADDLE_SPEED = PADDLE_SPEED
        victory(player1, player2)
        
    end


end
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'return' then
        Ball:reset()
        choosing = false
        if players == 1 then
            player2.isAI = true
        else
            player2.isAI = false
        end
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'play' then
            gameState = 'start'
        elseif gameState == 'pause' then
            --sets paused to false so that you can move the paddle again
            paused = false
            gameState = 'start'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'victory' then
            gameState = 'start'
        end
    elseif key == 'space' then
        if gameState == 'play'then
            gameState = 'pause'
            paused = true
        elseif gameState == 'pause' then
            gameState = 'play'
            paused = false
        end
    end
    if players == 2 and (key == 'left' or key == 'right')  then         
        players = 1
    elseif  players == 1 and (key == 'left' or key == 'right') then
        players = 2
    end

end
function love.draw(key)
    push:apply('start')
    love.graphics.clear(45 / 255, 45 / 255, 52 / 255, 255 / 255)
    --ball
    Ball:render()
    --paddles
    --paddle 1
    player1:render()
    --paddle 2
    player2:render()
    
    love.graphics.setFont(smallFont)
    if gameState == 'start' and choosing ~= true then
        love.graphics.printf("Press enter to start!", 0, 20, V_WIDTH, 'center')
    elseif gameState == 'serve' and choosing ~= true then
        love.graphics.printf("Player " .. tostring(server) .. "'s turn to server", 0, 20, V_WIDTH, 'center')
        love.graphics.printf("Press enter to serve", 0, 32, V_WIDTH, 'center')
    elseif gameState == 'pause' then
        love.graphics.setFont(mediumFont)
        love.graphics.printf("Paused", 0, 20, V_WIDTH, 'center')
    elseif gameState == 'play' then
        love.graphics.printf("Press space to pause", 0, 20, V_WIDTH, 'center')
    elseif gameState == 'victory' then
        love.graphics.setFont(largeFont)
        love.graphics.printf("Player " .. tostring(winner) .. " wins", 0, 20, V_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press enter to play again", 0, 56, V_WIDTH, 'center')
    end
    if gameState ~= 'victory' and choosing ~= true then
        love.graphics.setFont(largeFont)
        love.graphics.printf(player1.SCORE, 68, 40, V_WIDTH, 'center')
        love.graphics.printf(player2.SCORE, -68, 40, V_WIDTH, 'center')
    end
    if choosing then
        love.graphics.setFont(mediumFont)
        love.graphics.printf('Choose the number of players', 0, 14, V_WIDTH, 'center')
        
        
        love.graphics.printf('1', -35, 50, V_WIDTH, 'center')
        love.graphics.printf('2', 35, 50, V_WIDTH, 'center')
   
        
        if players == 1 then
            love.graphics.rectangle('line', V_WIDTH / 2 - 35 - 10, 50, 20, 20)
        elseif players == 2 then
            love.graphics.rectangle('line', V_WIDTH / 2 + 35 - 10, 50, 20, 20)
        end
        love.graphics.setFont(smallFont)
        love.graphics.printf('Using left or right and press enter', 0, 30, V_WIDTH, 'center')
    end

    displayFPS()
    push:apply('end')

end

function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 1, 0, 0.3)
    love.graphics.printf('FPS: ' .. tostring(love.timer.getFPS()), 2, 2, V_WIDTH, 'left')

end

function victory(box1, box2)
    if box1.SCORE == 3 then
        gameState = 'victory'
        winner = 1
    elseif box2.SCORE == 3 then
        gameState = 'victory'
        winner = 2
        
    end
    if gameState == 'victory' then
        sounds['win']:play()
        box1.SCORE = 0
        box2.SCORE = 0
    end
end