local cols, rows = 10, 20
local blockSize = 30
local grid = {}
local dropTimer = 0
local dropInterval = 0.5

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
    
    for x = 1, rows do
        grid[x] = {}
        for y = 1, cols do
            grid[x][y] = 0
        end
    end
    spawnBlock()
end

function spawnBlock()
    local blockIndex = love.math.random(1, #blocks)
    currentBlock = blocks[blockIndex]
    blockX = math.floor(cols/2) - math.floor(#currentBlock[1]/2)
    blockY = 1

    if checkCollision(currentBlock, blockX, blockY) then
        love.event.quit()
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
    clearLines()
    spawnBlock()
end

function clearLines()
    local y = rows
    while y > 0 do
        local isFull = true
        for x = 1, cols do
            if grid[y][x] == 0 then
                isFull = false
                break
            end
        end
        
        if isFull then
            table.remove(grid, y)
            local newRow = {}
            for x = 1, cols do newRow[x] = 0 end
            table.insert(grid, 1, newRow)
        else
            y = y - 1
        end
    end
end

function love.update(dt)
    dropTimer = dropTimer + dt
    if dropTimer >= dropInterval then
        dropTimer = 0
        if not checkCollision(currentBlock, blockX, blockY + 1) then
            blockY = blockY + 1
        else
            lockBlock()
        end
    end
end

function love.keypressed(key)
    if key == "left" then
        if not checkCollision(currentBlock, blockX - 1, blockY) then blockX = blockX - 1 end
    elseif key == "right" then
        if not checkCollision(currentBlock, blockX + 1, blockY) then blockX = blockX + 1 end
    elseif key == "down" then
        if not checkCollision(currentBlock, blockX, blockY + 1) then blockY = blockY + 1 end
    elseif key == "up" then
        local rotated = rotate(currentBlock)
        if not checkCollision(rotated, blockX, blockY) then
            currentBlock = rotated
        end
    end
end

function drawBlock(x, y, colorIndex)
    love.graphics.setColor(colors[colorIndex])
    love.graphics.rectangle("fill", (x - 1) * blockSize, (y - 1) * blockSize, blockSize - 1, blockSize - 1)
end

function love.draw()
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