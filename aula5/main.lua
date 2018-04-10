function newblip (vel)
  local x, y = 0, 50
  return {
    update = coroutine.wrap (function (self)
      local width, height = love.graphics.getDimensions( )
      while(1) do
        x = x+10
        if x > width then
        -- volta para a esquerda da janela
          x = 0
        end
        --coroutine.yield()
        wait(vel,self)
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
    draw = function ()
      love.graphics.rectangle("line", x, y, 10, 10)
    end,
    timetowake=0
  }
end

function newplayer ()
  local x, y = 0, 200
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
    love.graphics.rectangle("line", x, y, 30, 10)
  end
  }
end

function love.keypressed(key)
  if key == 'a' then
    pos = player.try()
    for i in ipairs(listabls) do
      local hit = listabls[i].affected(pos)
      if hit then
        table.remove(listabls, i) -- esse blip "morre" 
        return -- assumo que apenas um blip morre
      end
    end
  end
end

function love.load()
  --love.window.setMode(1024, 720)
  player =  newplayer()
  listabls = {}
  for i = 1, 5 do
    listabls[i] = newblip(i)
  end
end

function love.draw()
  player.draw()
  for i = 1,#listabls do
    listabls[i].draw()
  end
end

function love.update(dt)
  local now = love.timer.getTime()
  player.update(dt)
  for i = 1,#listabls do
    if (listabls[i]:isactive()) then
      listabls[i]:update()
    end
  end
end

function wait(segundos,meublip)
  meublip.timetowake=love.timer.getTime()+ segundos/100
  coroutine.yield()
end

  
