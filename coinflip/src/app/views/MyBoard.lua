local Levels = import("..data.MyLevels")
local Cell   = import("..views.Cell")
local curSwapBeginRow = -1
local curSwapBeginCol = -1

local scheduler = cc.Director:getInstance():getScheduler()
local Board = class("Board", function()
    return display.newNode()
end)
local isInAnimation = false
local isInTouch = false
local isEnableTouch = true
local NODE_PADDING   = 100 * GAME_CELL_STAND_SCALE
local NODE_ZORDER    = 0
local SWAP_TIME = 0.6
local COIN_ZORDER    = 1000

function Board:ctor(levelData)
    cc.GameObject.extend(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    math.randomseed(tostring(os.time()):reverse():sub(1,6))

    --self.batch = display.newBatchNode(GAME_TEXTURE_IMAGE_FILENAME)
    self.batch = display.newNode()
    self.batch:setPosition(display.cx, display.cy)
    self:addChild(self.batch)
    self.grid = {}

    --多加上一个屏幕的缓冲格子
    for i=1,levelData.rows * 2 do
        self.grid[i] = {}
        if levelData.grid[i] == nil then
            levelData.grid[i] = {}
        end
        for j=1,levelData.cols do
            self.grid[i][j] = levelData.grid[i][j]
        end
    end
     self.grid = clone(levelData.grid)
    self.rows = levelData.rows
    self.cols = levelData.cols
    self.cells = {}
    self.flipAnimationCount = 0

   if self.cols <= 8 then
        self.offsetX = -math.floor(NODE_PADDING * self.cols / 2) - NODE_PADDING / 2
        self.offsetY = -math.floor(NODE_PADDING * self.rows / 2) - NODE_PADDING / 2
        for row = 1, self.rows do
            local y = row * NODE_PADDING + self.offsetY
            for col = 1, self.cols do
                local x = col * NODE_PADDING + self.offsetX
                local nodeSprite = display.newSprite("#BoardNode.png", x, y)
                nodeSprite:setScale(GAME_CELL_STAND_SCALE)
                self.batch:addChild(nodeSprite, NODE_ZORDER)

                local node = self.grid[row][col]
                if node ~= Levels.NODE_IS_EMPTY then
                    local cell = Cell.new()
                    cell:setScale(GAME_CELL_STAND_SCALE )
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
        GAME_CELL_EIGHT_ADD_SCALE = 8.0 / self.cols
        NODE_PADDING = NODE_PADDING * GAME_CELL_EIGHT_ADD_SCALE
        self.offsetX = -math.floor(NODE_PADDING * self.cols / 2) - NODE_PADDING / 2
        self.offsetY = -math.floor(NODE_PADDING * self.rows / 2) - NODE_PADDING / 2
        GAME_CELL_STAND_SCALE = GAME_CELL_EIGHT_ADD_SCALE * GAME_CELL_STAND_SCALE 
        for row = 1, self.rows do
            local y = row * NODE_PADDING + self.offsetY
            for col = 1, self.cols do
                local x = col * NODE_PADDING + self.offsetX
                local nodeSprite = display.newSprite("#BoardNode.png", x, y)
                nodeSprite:setScale(GAME_CELL_STAND_SCALE)
                self.batch:addChild(nodeSprite, NODE_ZORDER)

                local node = self.grid[row][col]
                if node ~= Levels.NODE_IS_EMPTY then
                    local cell = Cell.new()
                    cell:setScale(GAME_CELL_STAND_SCALE )
                    cell:setPosition(x, y)
                    cell.row = row
                    cell.col = col
                    self.grid[row][col] = cell
                    self.cells[#self.cells + 1] = cell
                    self.batch:addChild(cell, COIN_ZORDER)
                end
            end
        end
        GAME_CELL_EIGHT_ADD_SCALE = 1.0
    end

    self:setNodeEventEnabled(true)
    self:setTouchEnabled(true)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        return self:onTouch(event.name, event.x, event.y)
    end)
    while self:checkAll() do
        self:changeSingedCell()  
    end
end

function Board:getCell(row, col)
    if self.grid[row] then
        return self.grid[row][col]
    end
end

function Board:changeSingedCell(onAnimationComplete)
    --统计所有的掉落项

    local DropList = {}

    --统计所有的最高掉落项
    local DropListFinal = {}

    for i,v in pairs(self.cells) do
        if v.isNeedClean then
            local drop_pad = 1
            local row = v.row
            local col = v.col
            local x = col * NODE_PADDING + self.offsetX
            local y = (self.rows + 1)* NODE_PADDING + self.offsetY
            for i,v in pairs(DropList) do
                if col == v.col then
                    drop_pad = drop_pad + 1
                    y = y + NODE_PADDING
                    --table.remove(DropList,i) 
                    for i2,v2 in pairs(DropListFinal) do
                        if v2.col == v.col then
                            table.remove(DropListFinal,i2)
                        end
                    end
                end
            end

            local cell = Cell.new()
            DropList [#DropList + 1] = cell
            DropListFinal [#DropListFinal + 1] = cell
            cell.isNeedClean = false
            cell:setPosition(x, y)
            cell:setScale(GAME_CELL_STAND_SCALE * GAME_CELL_EIGHT_ADD_SCALE )
            cell.row = self.rows + drop_pad
            cell.col = col
            --self.grid[self.rows + 1 + drop_pad][col] = cell
            self.grid[self.rows +  drop_pad][col] = cell
            if onAnimationComplete == nil then
                self.batch:removeChild(v, true)
                self.grid[row][col] = nil
            else
                --
            end
            
            self.cells[i] = cell
            self.batch:addChild(cell, COIN_ZORDER)
        end
    end

    --进行一次DropListFinal的精简
    for i=1,#DropListFinal do
        if DropListFinal[i] then
            for j=1,#DropList do
                if DropListFinal[i].col == DropList[j].col and DropListFinal[i].row < DropList[j].row then
                    DropListFinal[i] = DropList[j]
                end
            end
        end
    end

    -- 填补self.grid空缺
    -- 重新排列grid
    for i , v in pairs(DropListFinal) do
        if v then
            local c = v.row 
            local j = 1
            while j <=  self.rows  do
                if self.grid[j][v.col] == nil then
                    local k = j
                    while k <  c + 1 do
                        self:swap(k,v.col,k+1,v.col)
                        k = k + 1
                    end
                    j = j - 1
                end
                j = j + 1
            end
        end
    end

    for i=1,self.rows do
        for j=1,self.cols do
            if self.grid[i][j] then
                self.grid[i][j].row = i
                self.grid[i][j].col = j
            end
        end
    end

    if onAnimationComplete == nil then
        for i=1,self.rows do
            for j=1,self.cols do
                local y = i * NODE_PADDING + self.offsetY
                local x = j * NODE_PADDING + self.offsetX
                if self.grid[i][j] then
                    self.grid[i][j]:setPosition(x,y)
                end
            end
        end
    else
        --
    end
end

function Board:swap(row1,col1,row2,col2,isInAnimation,callBack)
    local temp
    if self.grid[row1] and self.grid[row1][col1] then
        self.grid[row1][col1].row = row2
        self.grid[row1][col1].col = col2
    end
    if self.grid[row2] and self.grid[row2][col2] then
        self.grid[row2][col2].row = row1
        self.grid[row2][col2].col = col1
    end
    if self.grid[row1] == nil or self.grid[row2] == nil then 
        print("error")
        return
    end
    
    temp = self.grid[row1][col1] 
    self.grid[row1][col1] = self.grid[row2][col2]
    self.grid[row2][col2] = temp
     if  isInAnimation ~= nil then
        isEnableTouch = true 
          if  isInAnimation  then
       local X2,Y2 = col1 * NODE_PADDING + self.offsetX , row1  * NODE_PADDING + self.offsetY
        local X1,Y1 = col2 * NODE_PADDING + self.offsetX , row2  * NODE_PADDING + self.offsetY
    if (row1 == row2 - 1 and col1 == col2)
     or  (row1 == row2 + 1 and col1 == col2)
      or (col1 == col2 - 1 and row1 == row2)
       or (col1 == col2 + 1 and row1 == row2) then
        if callBack then

            self.grid[row1][col1]:runAction(transition.sequence({
                    cc.MoveTo:create(0.8, cc.p(X2,Y2)),
                    cc.CallFunc:create(function()

                        self:swap(row1,col1,row2,col2)

                        callBack()
                         
                    end)
                }))
            self.grid[row2][col2]:runAction(cc.MoveTo:create(0.8, cc.p(X1,Y1)))
        else
            self.grid[row1][col1]:runAction(cc.MoveTo:create(0.8, cc.p(X2,Y2)))
            self.grid[row2][col2]:runAction(cc.MoveTo:create(0.8, cc.p(X1,Y1)))
            self:swap(row1,col1,row2,col2)
            
        end
    end
        self:swap(row1,col1,row2,col2)
    end
end
end


function Board:checkAll()
    for _, cell in ipairs(self.cells) do
        self:checkCell(cell)
    end
    for i,v in pairs (self.cells) do
        if v.isNeedClean  then
            return true
        end
    end
    return false
end

function Board:checkCell(cell)
    local listH = {}
    listH [#listH + 1] = cell
    local i=cell.col
    --格子中左边对象是否相同的遍历
    while i > 1 do
        i = i -1
        local cell_left = self:getCell(cell.row,i)
        if cell.nodeType == cell_left.nodeType then
            listH [#listH + 1] = cell_left
        else
            break
        end
    end
    --格子中右边对象是否相同的遍历
    if cell.col ~= self.cols then
        for j=cell.col+1 , self.cols do
            local cell_right = self:getCell(cell.row,j)
            if cell.nodeType == cell_right.nodeType then
                listH [#listH + 1] = cell_right
            else
                break
            end
        end
    end

    --目前的当前格子的左右待消除对象(连同自己)

    if #listH < 3 then
    else
        -- print("find a 3 coup H cell")
        for i,v in pairs(listH) do
            v.isNeedClean = true
        end

    end
    for i=2,#listH do
        listH[i] = nil
    end

    --判断格子的上边的待消除对象

    if cell.row ~= self.rows then
        for j=cell.row+1 , self.rows do
            local cell_up = self:getCell(j,cell.col)
            if cell.nodeType == cell_up.nodeType then
                listH [#listH + 1] = cell_up
            else
                break
            end
        end
    end

    local i=cell.row

    --格子中下面对象是否相同的遍历
    while i > 1 do
        i = i -1
        local cell_down = self:getCell(i,cell.col)
        if cell.nodeType == cell_down.nodeType then
            listH [#listH + 1] = cell_down
        else
            break
        end
    end

    if #listH < 3 then
        for i=2,#listH do
            listH[i] = nil
        end
    else
        for i,v in pairs(listH) do
            v.isNeedClean = true
        end
    end
end

function Board:onTouch(event, x, y)
    if not isEnableTouch then
        return false
    end
    if event == "began" then
        local row,col = self:getRandC(x, y)
        curSwapBeginRow = row
        curSwapBeginCol = col
        if curSwapBeginRow == -1 or curSwapBeginCol == -1 then
            return false 
        end
        isInTouch = true
        self.grid[curSwapBeginRow][curSwapBeginCol]:setLocalZOrder(CELL_ZORDER+1)
        return true
    end
    if isInTouch and (event == "moved" or event == "ended"  )then
        local padding = NODE_PADDING / 2
        local cell_center = self.grid[curSwapBeginRow][curSwapBeginCol]
        local cx, cy = cell_center:getPosition()
        cx = cx + display.cx
        cy = cy + display.cy
        --锚点归位
        local AnchBack = function()
            isInTouch = false
            local p_a = cell_center:getAnchorPoint()
            local x_a = (0.5 - p_a.x ) *  NODE_PADDING + curSwapBeginCol * NODE_PADDING + self.offsetX
            local y_a = (0.5 - p_a.y) *  NODE_PADDING + curSwapBeginRow * NODE_PADDING + self.offsetY
            cell_center:setAnchorPoint(cc.p(0.5,0.5))
            cell_center:setPosition(cc.p(x_a  , y_a ))
        end
        --动画回到格子定义点
        local AnimBack = function()
            isEnableTouch = false
                cell_center:runAction(
                    transition.sequence({
                    cc.MoveTo:create(SWAP_TIME/2,cc.p(curSwapBeginCol * NODE_PADDING + self.offsetX,curSwapBeginRow * NODE_PADDING + self.offsetY)),
                    cc.CallFunc:create(function()
                          isEnableTouch = true
                    end)
                }))
            cell_center:runAction(cc.ScaleTo:create(SWAP_TIME/2,CELL_SCALE))
            self.grid[curSwapBeginRow][curSwapBeginCol]:setLocalZOrder(CELL_ZORDER)
        end
        if event == "ended" then
            AnchBack()
            AnimBack()
            return
        end

        if x < cx - 2*padding
            or x > cx + 2*padding
            or y < cy - 2*padding
            or y > cy + 2*padding then
            isInTouch = false
            AnchBack()
            local row,col = self:getRandC(x, y)
            --进入十字框以内
            if ((x >= cx - padding
            and x <= cx + padding)
            or (y >= cy - padding
            and y <= cy + padding) )and (row ~= -1 and col ~= -1)  then
                --防止移动超过一格的情况
                if row - curSwapBeginRow > 1 then row = curSwapBeginRow + 1 end
                if curSwapBeginRow - row > 1 then row = curSwapBeginRow - 1 end
                if col -  curSwapBeginCol > 1 then col = curSwapBeginCol + 1 end
                if curSwapBeginCol - col  > 1 then col = curSwapBeginCol - 1 end
                    self:swap(row,col,curSwapBeginRow,curSwapBeginCol,function()
                        -- if START_TAG then
                        --     step = step + 1
                        --     GAME_STEP = GAME_STEP + 1
                        -- end
                        self:checkCell(self.grid[row][col])
                        self:checkCell(self.grid[curSwapBeginRow][curSwapBeginCol])
                        if self:checkNotClean() then
                            -- WAIT_TIME = 0
                            -- self:changeSingedCell(true)
                        else
                            self:swap(row,col,curSwapBeginRow,curSwapBeginCol,function()
                                isEnableTouch = true
                            end,0.5)
                        end
                    end
                    )
                cell_center:runAction(cc.ScaleTo:create(SWAP_TIME/2,CELL_SCALE))
            else
                AnimBack()
                return
            end
        else
            x_vec = (cx - x)/ NODE_PADDING * 0.3 + 0.5
            y_vec = (cy - y)/ NODE_PADDING * 0.3 + 0.5
            cell_center:setAnchorPoint(cc.p(x_vec,y_vec))
        end
    end
end
function Board:checkNotClean()
    for i,v in pairs (self.cells) do
        if v.isNeedClean  then
            isEnableTouch = false
            return true
        end
    end
    isEnableTouch = true
    return false
end
function Board:getRandC(x,y)
    local padding = NODE_PADDING / 2
    for _, cell in ipairs(self.cells) do
        local cx, cy = cell:getPosition()
        cx = cx + display.cx
        cy = cy + display.cy
        if x >= cx - padding
            and x <= cx + padding
            and y >= cy - padding
            and y <= cy + padding then
            return cell.row , cell.col
        end
    end
    return -1 , -1
end


function Board:check()
    local i = 1
    local j = 1
    while i <= self.rows do
        j = 1
        while j <= self.cols do
            local cell = self.grid[i][j]
            local sum = 1
            while j < self.cols and cell.nodeType == self.grid[i][j+1].nodeType do
                cell = self.grid[i][j+1]
                j = j + 1
                sum = sum + 1
            end
            if sum >= 3 then
                print(i,j)
            end
            j = j + 1
        end
        i = i + 1
    end

    i = 1
    j = 1
    while i <= self.cols do
        j = 1
        while j <= self.rows do
            local cell = self.grid[j][i]
            local sum = 1
            while j < self.rows and cell.nodeType == self.grid[j+1][i].nodeType do
                cell = self.grid[j+1][i]
                j = j + 1
                sum = sum + 1
            end
            if sum >= 3 then
                print(j,i)
            end
            j = j + 1
        end
        i = i + 1
    end
end

function Board:onEnter()
    self:setTouchEnabled(true)
end

function Board:onExit()
    self:removeAllEventListeners()
    
    GAME_CELL_STAND_SCALE = GAME_CELL_EIGHT_ADD_SCALE * 0.75
    NODE_PADDING = 100 * 0.75
end

return Board