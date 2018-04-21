function newblip (vel,bx,by)
  local x, y = bx, by
  return {
    update = coroutine.wrap (function (self)
      while(1) do
        x = x+10
        if x > width then
        -- volta para a esquerda da janela
          x = 0
          y = y + 10
        end
        if(y>=530) then
          gameover=true
        end
        wait(vel,self)
      end
      end),
    affected = function (posx,posy)
      if (posx>=x and posx<=x+20 and posy<= y and posy>= y-20) then
      -- "pegou" o blip
        return true
      else
        return false
      end
    end,
      isactive = (function (self)
        local now=love.timer.getTime()
        return (now>=self.timetowake)
      end),
    draw = function ()
      love.graphics.rectangle("line", x, y, 20, 20)
    end,
    timetowake=0
  }
end

function newtiro (vel, tx)
  local x, y = tx, 550
  local atirou=false
  return {
    update = coroutine.wrap (function (self)
      
      while(1) do
        if(self.atirou==false) then
          x = pos
        else
          y = y - 10
          if y < 0 then
            self.atirou = false
            y = 550
          end
        end
        wait(vel,self)
      end
      end),
    isactive = (function (self)
        local now=love.timer.getTime()
        return (now>=self.timetowake)
      end),
      try = function ()
        return x, y
      end,
    draw = function ()
      love.graphics.rectangle("fill", x, y, 5, 10)
    end,
    timetowake=0
  }
end

function newtiroblip (vel, tx)
  local x, y = tx, 0
  return {
    update = coroutine.wrap (function (self)
      
      while(1) do
          y = y + 12
          if y > 560 then
            y = 0
            x = love.math.random(0,width)
          end
        wait(vel,self)
      end
      end),
    isactive = (function (self)
        local now=love.timer.getTime()
        return (now>=self.timetowake)
      end),
      try = function ()
        return x, y, vel
      end,
    draw = function ()
      love.graphics.rectangle("fill", x, y, 5, 10)
    end,
    timetowake=0
  }
end

function newplayer ()
  local width, height = love.graphics.getDimensions( )
  local x, y = (width/2)-15,550
  return {
  try = function ()
    return x
  end,
  update = function (dt)
    if x > width then
      x = 0
    end
  end,
  keypressed = function (key)
    if key == "right" then
      x = x + 10
    end
    if key == "left" then
      x = x - 10
    end
  end,
  affected = function (posx,posy)
      if (posx>=x and posx<=x+30 and posy<= y+10 and posy>= y-10) then
      -- "pegou" o jogador
        return true
      else
        return false
      end
  end,
  draw = function ()
    love.graphics.rectangle("fill", x, y, 30, 10)
  end
  }
end

function love.keypressed(key)
   if key == ' ' and (gameover == true or score == k) then
     love.load()
  end
  if key == ' ' then
    pos = player.try()
    if(tiro.atirou==false) then
      tiro=newtiro(1,pos+12)
    end
    tiro.atirou=true
  end
    player.keypressed(key)
end

function love.load()
  score=0
  lifes=3
  width, height = love.graphics.getDimensions( )
  gameover=false
  player =  newplayer()
  pos = player.try()
  tiro=newtiro(2,2000)
  tiro.atirou = false
  listabls = {}
  listatirob = {}
  love.keyboard.setKeyRepeat(true)
  k=0
  for j = 1, 6 do
    for i = 1, 12 do
      k=k+1
      listabls[k] = newblip(3,40*i,40*j)
    end
  end
    for j = 2, 6 do
      listatirob[j-1] = newtiroblip(j,2000)
    end
end

function love.draw()
  player.draw()
  for i = 1,#listabls do
    listabls[i].draw()
  end
  if(tiro.atirou) then
    tiro:draw()
  end
  for i = 1,#listatirob do
    listatirob[i].draw()
  end
  love.graphics.print( "Score: ".. score .. "  Lives: " .. lifes, (width)-150, height-30, 0, 1, 1, 0, 0, 0, 0 )
  if(gameover) then
    love.graphics.clear( )
    love.graphics.print( "GAME OVER", (width/2)-120, height/2, 0, 3, 3, 0, 0, 0, 0 )
    love.graphics.print( "Score: ".. score, width/2-70, (height)/2+40, 0, 2, 2, 0, 0, 0, 0 )
    love.graphics.print( "Clique space para tentar de novo", width/2-240, (height)/2+70, 0, 2, 2, 0, 0, 0, 0 )
  end
    if(score==k) then
    love.graphics.clear( )
    love.graphics.print( "WINNER", (width/2)-120, height/2, 0, 3, 3, 0, 0, 0, 0 )
    love.graphics.print( "Score: ".. score .. "  Lives: " .. lifes, width/2-150, (height)/2+40, 0, 2, 2, 0, 0, 0, 0 )
    love.graphics.print( "Clique space para tentar de novo", width/2-240, (height)/2+70, 0, 2, 2, 0, 0, 0, 0 )
  end
end

function love.update(dt)
  if (gameover==false and score < k) then
    player.update(dt)
    for i = 1,#listabls do
      if (listabls[i]:isactive()) then
        listabls[i]:update()
      end
    end
    for i = 1,#listatirob do
      if (listatirob[i]:isactive()) then
        listatirob[i]:update()
      end
    end
    if (tiro:isactive() and tiro.atirou) then
      tiro:update()
    end
    
    for i in ipairs(listatirob) do
      posx, posy, v = listatirob[i].try()
      local hit = player.affected(posx,posy)
      if hit then
        lifes=lifes-1
        listatirob[i]=newtiroblip(v,love.math.random(0,width))
        if (lifes==0) then
          gameover=true
        end
      end
    end
    
    pos = player.try()
    posx, posy = tiro.try()
    for i in ipairs(listabls) do
      local hit = listabls[i].affected(posx,posy)
      if hit then
        table.remove(listabls, i) -- esse blip "morre" 
        tiro=newtiro(2,2000) 
        tiro.atirou = false
        score= score+1
        return -- assumo que apenas um blip morre
      end
    end
  end
end

function wait(segundos,meuobjeto)
  meuobjeto.timetowake=love.timer.getTime()+ segundos/100
  coroutine.yield()
end