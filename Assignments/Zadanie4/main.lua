local cols, rows = 10, 20
local blockSize = 30
local dropInterval = 0.5

local linesToClear = {}
local clearAnimationTimer = 0
local clearAnimationStep = 0
local clearAnimationStepDuration = 0.05

local gameState = "menu"

-- values that need to be saved
local grid = {}
local dropTimer = 0
local blockX, blockY
local currentBlock

local blocks = {
    { {1, 1, 1, 1} },
    { {2, 2}, {2, 2} },
    { {0, 3, 0}, {3, 3, 3} },
    { {0, 0, 4}, {4, 4, 4} }
}

local colors = {
    {0, 1, 1},
    {1, 1, 0},
    {1, 0, 1},
    {1, 0.5, 0}
}

local sounds = {}

function rotate(block)
    local newBlock = {}
    local blockRows, blockCols = #block, #block[1]
    
    for x = 1, blockCols do
        newBlock[x] = {}
        for y = 1, blockRows do
            newBlock[x][y] = block[blockRows-y+1][x]
        end
    end
    return newBlock
end

function love.load()
    love.window.setMode(cols * blockSize, rows * blockSize)
    love.window.setTitle("Tetris")
    love.keyboard.setKeyRepeat(true)

    sounds.move = love.audio.newSource("sounds/move.wav", "static")
    sounds.rotate = love.audio.newSource("sounds/rotate.wav", "static")
    sounds.lock = love.audio.newSource("sounds/lock.wav", "static")
    sounds.clear = love.audio.newSource("sounds/clear.wav", "static")
    sounds.gameover = love.audio.newSource("sounds/gameover.wav", "static")
    
    for x = 1, rows do
        grid[x] = {}
        for y = 1, cols do
            grid[x][y] = 0
        end
    end
    spawnBlock()
end

function startNewGame()
    for x = 1, rows do
        grid[x] = {}
        for y = 1, cols do
            grid[x][y] = 0
        end
    end
    
    dropTimer = 0
    spawnBlock()
    
    gameState = "playing"
end

function spawnBlock()
    local blockIndex = love.math.random(1, #blocks)
    currentBlock = blocks[blockIndex]
    blockX = math.floor(cols/2) - math.floor(#currentBlock[1]/2)
    blockY = 1

    if checkCollision(currentBlock, blockX, blockY) then
        gameState = "gameover"
        currentBlock = nil
        sounds.gameover:play()  
    end
end

function checkCollision(block, px, py)
    for y, row in ipairs(block) do
        for x, val in ipairs(row) do
            if val > 0 then
                local gx, gy = px + x - 1, py + y - 1
                if gx < 1 or gx > cols or gy > rows then return true end
                if gy > 0 and grid[gy][gx] > 0 then return true end
            end
        end
    end
    return false
end

function lockBlock()
    for y, row in ipairs(currentBlock) do
        for x, val in ipairs(row) do
            if val > 0 then
                grid[blockY + y - 1][blockX + x - 1] = val
            end
        end
    end

    currentBlock = nil
    clearLines()
end

function clearLines()
    linesToClear = {}
    local y = rows

    for y = 1, rows do
        local isFull = true
        for x = 1, cols do
            if grid[y][x] == 0 then
                isFull = false
                break
            end
        end
        if isFull then
            table.insert(linesToClear, y)
        end
    end

    if #linesToClear > 0 then
        gameState = "clearing"
        clearAnimationTimer = 0
        clearAnimationStep = 1
        sounds.clear:play()
        
        local leftCol = math.floor(cols / 2) - clearAnimationStep + 1
        local rightCol = math.floor(cols / 2) + clearAnimationStep
        
        for _, y in ipairs(linesToClear) do
            grid[y][leftCol] = 0
            grid[y][rightCol] = 0
        end
    else
        spawnBlock()
    end
end

function removeClearedLines()
    for i = #linesToClear, 1, -1 do
        local y = linesToClear[i]
        table.remove(grid, y)
    end
    
    for i = 1, #linesToClear do
        local newRow = {}
        for x = 1, cols do newRow[x] = 0 end
        table.insert(grid, 1, newRow)
    end
    
    linesToClear = {}
    spawnBlock()
    gameState = "playing"
end


-- updating functions

function love.update(dt)
    if gameState == "playing" then
        dropTimer = dropTimer + dt
        if dropTimer >= dropInterval then
            dropTimer = 0
            if not checkCollision(currentBlock, blockX, blockY + 1) then
                blockY = blockY + 1
            else
                sounds.lock:play()
                lockBlock()
            end
        end

    elseif gameState == "clearing" then
        clearAnimationTimer = clearAnimationTimer + dt
        
        if clearAnimationTimer >= clearAnimationStepDuration then
            clearAnimationTimer = 0
            clearAnimationStep = clearAnimationStep + 1
            
            if clearAnimationStep > cols / 2 then
                removeClearedLines()
            else
                local leftCol = math.floor(cols / 2) - clearAnimationStep + 1
                local rightCol = math.floor(cols / 2) + clearAnimationStep
                
                for _, y in ipairs(linesToClear) do
                    grid[y][leftCol] = 0
                    grid[y][rightCol] = 0
                end
            end
        end
    end
end

function love.keypressed(key)
    if gameState == "menu" then
        if key == "1" then
            startNewGame()
        elseif key == "2" then
            if loadGame() then
                gameState = "playing"
            end
        end
        
    elseif gameState == "playing" then
        if key == "left" then
            if not checkCollision(currentBlock, blockX - 1, blockY) then 
                blockX = blockX - 1 
                sounds.move:play()
            end
        elseif key == "right" then
            if not checkCollision(currentBlock, blockX + 1, blockY) then 
                blockX = blockX + 1 
                sounds.move:play()
            end
        elseif key == "down" then
            if not checkCollision(currentBlock, blockX, blockY + 1) then 
                blockY = blockY + 1 
                sounds.move:play()
            end
        elseif key == "up" then
            local rotated = rotate(currentBlock)
            if not checkCollision(rotated, blockX, blockY) then
                currentBlock = rotated
                sounds.rotate:play()
            end
        end
        
        if key == "s" then
            saveGame()
            gameState = "menu"
        end
        
    elseif gameState == "gameover" then
        if key == "return" then
            gameState = "menu"
        end
    end
end





-- rendering functions

function drawBlock(x, y, colorIndex)
    love.graphics.setColor(colors[colorIndex])
    love.graphics.rectangle("fill", (x - 1) * blockSize, (y - 1) * blockSize, blockSize - 1, blockSize - 1)
end


function drawGame()
    for y = 1, rows do
        for x = 1, cols do
            if grid[y][x] > 0 then
                drawBlock(x, y, grid[y][x])
            end
        end
    end

    if currentBlock then
        for y, row in ipairs(currentBlock) do
            for x, val in ipairs(row) do
                if val > 0 then
                    drawBlock(blockX + x - 1, blockY + y - 1, val)
                end
            end
        end
    end
end

function love.draw()
    if gameState == "menu" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("TETRIS", 120, 200)
        love.graphics.print("Press [1] - New Game", 70, 250)
        love.graphics.print("Press [2] - Load Game", 70, 280)
        
    elseif gameState == "playing" then
        drawGame()

    elseif gameState == "clearing" then
        drawGame()
        
    elseif gameState == "gameover" then
        drawGame() 
        love.graphics.setColor(0, 0, 0, 0.85)
        love.graphics.rectangle("fill", 0, 0, cols * blockSize, rows * blockSize)

        love.graphics.setColor(1, 0, 0)
        love.graphics.print("GAME OVER", 110, 250)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Press [Enter] to return to menu", 40, 300)
    end
end



-- saving game functions

-- helper function to convert a table to a string representation
function tableToString(table)
    local result = "{"
    for k, v in pairs(table) do
        if type(k) == "number" then
            result = result .. "[" .. k .. "]="
        else
            result = result .. k .. "="
        end
        
        if type(v) == "table" then
            result = result .. tableToString(v) .. ","
        elseif type(v) == "number" then
            result = result .. v .. ","
        elseif type(v) == "string" then
            result = result .. string.format("%q", v) .. ","
        elseif type(v) == "boolean" then
            result = result .. tostring(v) .. ","
        end
    end
    return result .. "}"
end

function saveGame()
    local gameState = {
        grid = grid,
        currentBlock = currentBlock,
        blockX = blockX,
        blockY = blockY,
        dropTimer = dropTimer
    }
    
    local gameData = "return " .. tableToString(gameState)
    success, message = love.filesystem.write("tetris_save.lua", gameData)
    
    if success then
        print("Game saved successfully!")
    else
        print("Error saving game: " .. tostring(message))
    end
end

function loadGame()
    if love.filesystem.getInfo("tetris_save.lua") then
        local gameState = love.filesystem.load("tetris_save.lua")()

        grid = gameState.grid
        currentBlock = gameState.currentBlock
        blockX = gameState.blockX
        blockY = gameState.blockY
        dropTimer = gameState.dropTimer
        
        print("Game loaded successfully!")
        return true
    else
        print("No save file to load.")
        return false
    end
end