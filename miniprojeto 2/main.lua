function newblip (vel,bx,by)
  local x, y = bx, by
  return {
    update = coroutine.wrap (function (self)
      local width, height = love.graphics.getDimensions( )
      while(1) do
        x = x+10
        if x > width then
        -- volta para a esquerda da janela
          x = 0
          y = y + 10
        end
        --coroutine.yield()
        waitblip(vel,self)
      end
      end),
    affected = function (posx,posy)
      if (posx>x and posx<x+20 and posy< y and posy> y-20) then
      -- "pegou" o blip
        print(acertou)
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
      love.graphics.rectangle("line", x, y, 10, 10)
    end,
    timetowake=0
  }
end

function newtiro (vel, tx)
  local x, y = tx, 550
  local atirou=false
  return {
    update = coroutine.wrap (function (self)
      local width, height = love.graphics.getDimensions( )
      
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
        --coroutine.yield()
        waittiro(vel,self)
      end
      end),
    affected = function (pos)
      if pos>x and pos<x+10 then
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
      try = function ()
        return x, y
      end,
    draw = function ()
      love.graphics.rectangle("line", x, y, 5, 10)
    end,
    timetowake=0
  }
end

function newplayer ()
  local x, y = 0,550
  local width, height = love.graphics.getDimensions( )
  return {
  try = function ()
    return x
  end,
  update = function (dt)
    x = x + 0.5
    if x > width then
      x = 0
    end
  end,
  draw = function ()
    love.graphics.rectangle("fill", x, y, 30, 10)
  end
  }
end

function love.keypressed(key)
  if key == ' ' then
    pos = player.try()
    if(tiro.atirou==false) then
      --table.remove(tiro)
      tiro=newtiro(2,pos+12)
    end
    tiro.atirou=true
  end
end

function love.load()
  --love.window.setMode(1024, 720)
  player =  newplayer()
  pos = player.try()
  tiro=newtiro(2,2000)
  tiro.atirou = false
  listabls = {}
  
  local k=1
  for j = 1, 5 do
    for i = 1, 10 do
      listabls[k] = newblip(5,30*i,50*j)
      k=k+1
    end
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
end

function love.update(dt)
  player.update(dt)
  for i = 1,#listabls do
    if (listabls[i]:isactive()) then
      listabls[i]:update()
    end
  end
  if (tiro:isactive() and tiro.atirou) then
    tiro:update()
  end
  pos = player.try()
  posx, posy = tiro.try()
    for i in ipairs(listabls) do
      local hit = listabls[i].affected(posx,posy)
      if hit then
        table.remove(listabls, i) -- esse blip "morre" 
        tiro=newtiro(2,2000) 
        tiro.atirou = false
        return -- assumo que apenas um blip morre
      end
    end
end

function waitblip(segundos,meublip)
  meublip.timetowake=love.timer.getTime()+ segundos/100
  coroutine.yield()
end

function waittiro(segundos,meutiro)
  meutiro.timetowake=love.timer.getTime()+ segundos/100
  coroutine.yield()
end

  
