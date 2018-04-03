-- renomear para main.lua

function love.load()
  --x = 50 y = 200
  --w = 200 h = 150

  a=retangulo(50,200,200,150)
  b=retangulo(300,200,200,150)
  c=retangulo(300,50,200,150)
  ret={a,b,c}
end

function naimagem (mx, my, x, y, w ,h) 
  return (mx>x) and (mx<x+w) and (my>y) and (my<y+h)
end

function retangulo (x,y,w,h)
  local originalx, originaly, rx, ry, rw, rh = x, y, x, y, w, h
  return{
    draw=
      function()
        love.graphics.rectangle("line",rx,ry,rw,rh)
      end,
    keypressed =
      function (key)
          local mx, my=love.mouse.getPosition()
          if key == 'b' and naimagem (mx,my, rx, ry, rw, rh) then
             ry = 200
          end
          if key == "down" and naimagem (mx,my, rx, ry, rw, rh) then
            ry = ry + 10
          end
          if key == "right" and naimagem (mx,my, rx, ry, rw, rh) then
            rx = rx + 10
          end
      end
    }
end

function love.keypressed(key)
--  local mx, my = love.mouse.getPosition() 
--  if key == 'b' and naimagem (mx,my, x, y) then
--     y = 200
--  end
--  if key == "down" and naimagem (mx,my, x, y) then
--    y = y + 10
--  end
--  if key == "right" and naimagem (mx,my, x, y) then
--    x = x + 10
--  end
  for i = 1, #ret do
    ret[i].keypressed(key)
  end
end

function love.update (dt)
  local mx, my = love.mouse.getPosition() 
  --ret1.update()
  --ret2.update()
end

function love.draw ()
  --love.graphics.rectangle("line", x, y, w, h)
 for i = 1, #ret do
   ret[i].draw()
 end
end

