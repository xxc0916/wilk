local Levels = import("..data.MyLevels")
local Cell   = import("..views.Cell")

local Board = class("Board", function()
    return display.newNode()
end)

local NODE_PADDING   = 100 * GAME_CELL_STAND_SCALE
local NODE_ZORDER    = 0

local COIN_ZORDER    = 1000

function Board:ctor(levelData)
    cc.GameObject.extend(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    math.randomseed(tostring(os.time()):reverse():sub(1,6))

    --self.batch = display.newBatchNode(GAME_TEXTURE_IMAGE_FILENAME)
    self.batch = display.newNode()
    self.batch:setPosition(display.cx, display.cy)
    self:addChild(self.batch)

    self.grid = clone(levelData.grid)
    self.rows = levelData.rows
    self.cols = levelData.cols
    self.cells = {}
    self.flipAnimationCount = 0

    if self.cols <= 8 then
        local offsetX = -math.floor(NODE_PADDING * self.cols / 2) - NODE_PADDING / 2
        local offsetY = -math.floor(NODE_PADDING * self.rows / 2) - NODE_PADDING / 2
        -- create board, place all cells
        for row = 1, self.rows do
            local y = row * NODE_PADDING + offsetY
            for col = 1, self.cols do
                local x = col * NODE_PADDING + offsetX
                local nodeSprite = display.newSprite("#BoardNode.png", x, y)
                nodeSprite:setScale(GAME_CELL_STAND_SCALE)
                self.batch:addChild(nodeSprite, NODE_ZORDER)

                local node = self.grid[row][col]
                if node ~= Levels.NODE_IS_EMPTY then
                    local cell = Cell.new()
                    cell:setPosition(x, y)

                    cell.row = row
                    cell.col = col
                    self.grid[row][col] = cell
                    self.cells[#self.cells + 1] = cell
                    self.batch:addChild(cell, COIN_ZORDER)
                    

                end

            end
          

        end
       

    else
        GAME_CELL_EIGHT_ADD_SCALE = 8.0/ self.cols
        NODE_PADDING = NODE_PADDING * GAME_CELL_EIGHT_ADD_SCALE
        local offsetX = -math.floor(NODE_PADDING * self.cols / 2) - NODE_PADDING / 2
        local offsetY = -math.floor(NODE_PADDING * self.rows / 2) - NODE_PADDING / 2
        GAME_CELL_STAND_SCALE = GAME_CELL_STAND_SCALE * GAME_CELL_EIGHT_ADD_SCALE
        -- create board, place all cells
        for row = 1, self.rows do
            local y = row * NODE_PADDING + offsetY
            for col = 1, self.cols do
                local x = col * NODE_PADDING + offsetX
                local nodeSprite = display.newSprite("#BoardNode.png", x, y)
                nodeSprite:setScale(GAME_CELL_STAND_SCALE)
                self.batch:addChild(nodeSprite, NODE_ZORDER)

                local node = self.grid[row][col]
                if node ~= Levels.NODE_IS_EMPTY then
                    local cell = Cell.new()
                    cell:setPosition(x, y)

                    cell.row = row
                    cell.col = col
                    self.grid[row][col] = cell
                    self.cells[#self.cells + 1] = cell
                    self.batch:addChild(cell, COIN_ZORDER)
                    --self:checkcell(cell)

                end
            end
        end
        GAME_CELL_EIGHT_ADD_SCALE = 1.0
        GAME_CELL_STAND_SCALE = GAME_CELL_EIGHT_ADD_SCALE * 0.75
        NODE_PADDING = 100 *0.75
        
    end


    self:setNodeEventEnabled(true)
    self:setTouchEnabled(true)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        return self:onTouch(event.name, event.x, event.y)
    end)
    -- for  _, cell in ipairs(self.cells) do
    --         self:checkcell(cell)
    --     end
    self:checkAll()

end
function Board:checkAll()
    -- for i=1,self.rows-2 do
    --     for j=1,self.cols-2 do
            
    --         local cell=self.grid[i][j]
    --         if cell.nodeType == self.grid[i+1][j+1].nodeType and cell.nodeType == self.grid[i+2][j+2].nodeType then
    --             print(i,j)
    --         end

    --     end
    -- end


    -- for i=1,self.rows do
    -- -- local row = 1
    -- -- local col = 1
    -- -- local I = self.grid[row][col]
    -- -- row = row + 1

    -- -- local J = self.grid[row][col]
    -- -- col = col + 1
    -- -- local K = self.grid[row][col+1]
    -- -- if I.nodeType == J.nodeType then
    -- --     print (I.row,I.col)
    -- -- end
    -- -- if I.nodeType == K.nodeType then
    -- --     print (I.row,I.col)
    -- -- end
    --  -- local I = self.grid[i][col]
    --  --  i = i + 1

    --  -- local J = self.grid[i][col]
    --  -- if I.nodeType == J.nodeType then
    --  --    print (I.row,I.col)
    --  -- end
    --   for j=1,self.cols do
    --  --  local X = self.grid[row][j]
    --  --  j = j + 1

    --  -- local Y = self.grid[row][j]
    --  -- if X.nodeType == Y.nodeType then
    --  --    print (X.row,X.col)
    --  -- end  
    --   --local cell = self.grid[i][j]
    --   --print (cell.row,cell.col)
    --    local I = self.grid[i][j]
       
    --    i = i + 1
    --    if i < self.rows then
    --    local J = self.grid[i][j]
        

    -- if I.nodeType == J.nodeType then
    --     print ("I",I.row,I.col)
    -- end
    -- end
    -- end
    -- local i = 1
    -- local j = 1
    -- while i <= self.rows do
    --     j=1
    -- while j <=self.cols do
    --         --todo
        
    --     local cell = self.grid[i][j]
    --     local sum = 1
    --     while j <self.cols and cell.nodeType == self.grid[i][j+1].nodeType do
    --         cell = self.grid[i][j+1]
    --         j = j+1
    --         sum = sum +1
    --     end
    --     if sum >=3 then 
    --         print (i,j)
    --     end
    --     j=j+1
    -- end

    -- i=i+1
    -- end 
    -- i = 1
    -- j = 1
    -- while i <= self.cols do
    --     j=1
    -- while j <=self.rows do
    --     local cell = self.grid[j][i]
    --     local sum = 1
    --     while j <self.cols and cell.nodeType == self.grid[i][j+1].nodeType do
    --         cell = self.grid[j+1][i]
    --         j = j+1
    --         sum = sum +1
    --     end
    --     if sum >=3 then 
    --         print (j,i)
    --     end
    --     j=j+1
    -- end
    -- i=i+1
    -- end
    local i = 1
    local j = 1
    while i <= self.rows do
        j=1
    while j <= self.cols do
           
           
           
        
        local cell = self.grid[i][j]
        local sum = 1
        while j <self.cols and i <self.rows and cell.nodeType == self.grid[i+1][j+1].nodeType do
            cell = self.grid[i+1][j+1]
            j = j+1
            i = i+1
            sum = sum +1
        end
        if sum >=3 then 
            print (i,j)
        end
        
        j=j+1
        
    end
   i=i+1
   
end

end

function  Board:checkcell(cell) 
    local listH = {}
    local listD = {}
    listH [#listH + 1] = cell
    listD [#listD + 1] = cell
    local i = cell.col
    
     
    for row = 1,self.rows do
        local cell_chusi =self:getCell(cell.row,i)
        i = i -1

        local cell_left = self:getCell(cell.row,i)
        if cell_left and cell_chusi then
            if cell_chusi.nodeType == cell_left.nodeType then
                listH [#listH + 1] = cell_left
            else
                break
            end
        end
    end
    
     if #listH < 3  then
        listH = {}
    else
        for _,v in pairs(listH) do
            print("H",v.row,"   ",v.col)
        end
        
     end
    local j = cell.row
    for col = 1,self.cols do
        local cell_chushiu =self:getCell(j,cell.col)
        j = j - 1

        local cell_down = self:getCell(j,cell.col)
        if cell_down and cell_chusi then
            if cell_chushiu.nodeType == cell_down.nodeType then
                listD [#listD + 1] = cell_down
            else
                break
            end
        end
    end
   
    if #listD < 3  then
        listD = {}
    else
        for _,v in pairs(listD) do
            print("D",v.row,"   ",v.col)
        end
        
     end
    
    
end
function Board:getCell( row , col )
    if self.grid[row] then
        return self.grid[row][col]
    end

    return nil
end

function Board:checkLevelCompleted()
    local count = 0
    for _, cell in ipairs(self.cells) do
        if cell.isWhite then count = count + 1 end
    end
    if count == #self.cells then
        -- completed
        self:setTouchEnabled(false)
        self:dispatchEvent({name = "LEVEL_COMPLETED"})
    end
end

function Board:getCoin(row, col)
    if self.grid[row] then
        return self.grid[row][col]
    end
end

function Board:flipCoin(cell, includeNeighbour)
    if not cell or cell == Levels.NODE_IS_EMPTY then return end

    self.flipAnimationCount = self.flipAnimationCount + 1
    cell:flip(function()
        self.flipAnimationCount = self.flipAnimationCount - 1
        self.batch:reorderChild(cell, COIN_ZORDER)
        if self.flipAnimationCouncellt == 0 then
            self:checkLevelCompleted()
        end
    end)
    if includeNeighbour then
        audio.playSound(GAME_SFX.flipCoin)
        self.batch:reorderChild(cell, COIN_ZORDER + 1)
        self:performWithDelay(function()
            self:flipCoin(self:getCoin(cell.row - 1, cell.col))
            self:flipCoin(self:getCoin(cell.row + 1, cell.col))
            self:flipCoin(self:getCoin(cell.row, cell.col - 1))
            self:flipCoin(self:getCoin(cell.row, cell.col + 1))
        end, 0.25)
    end
end

function Board:onTouch(event, x, y)
    if event ~= "began" or self.flipAnimationCount > 0 then return end

    --[[local padding = NODE_PADDING / 2
    for _, coin in ipairs(self.cells) do
        local cx, cy = coin:getPosition()
        cx = cx + display.cx
        cy = cy + display.cy
        if x >= cx - padding
            and x <= cx + padding
            and y >= cy - padding
            and y <= cy + padding then
            self:flipCoin(coin, true)
            break
        end
    end]]--
end

function Board:onEnter()
    self:setTouchEnabled(true)
end

function Board:onExit()
    self:removeAllEventListeners()
end

return Board
