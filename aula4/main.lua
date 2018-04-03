-- INF1805
--Filipe Ferraz Franco e Costa 1711109
--Rodrigo Pumar Alves de Souza 1221007

function love.load()
  ret={}
  for i=1, 4 do
    ret[i]=retangulo(100*(i-1)+50,100*(i-1)+50,200,150)
  end
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
             ry = originaly
             rx = originalx
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
  for i = 1, #ret do
    ret[i].keypressed(key)
  end
end

function love.update (dt)
  local mx, my = love.mouse.getPosition() 
end

function love.draw ()
 for i = 1, #ret do
   ret[i].draw()
 end
end

