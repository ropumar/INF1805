-- renomear para main.lua

function love.load()
  ret={}
  for i=1, 4 do
    ret[i]=retangulo(100*(i-1)+50,100*(i-1)+50, 200, 150)
  end
end

function retangulo (x,y,w,h)
  local originalx, originaly, rx, ry, rw, rh = x, y, x, y, w, h
  local function naimagem (mx, my, x, y) 
    return (mx>x) and (mx<x+w) and (my>y) and (my<y+h)
  end
  return{
    draw=
      function()
        local mx, my=love.mouse.getPosition()
        if naimagem(mx,my,rx,ry) then
          love.graphics.setColor( 255, 255, 0, 255 )
        else
          love.graphics.setColor( 255, 255, 255, 255 )          
        end
        love.graphics.rectangle("line",rx,ry,rw,rh)
      end,
    
    keypressed =
      function (key)
          local mx, my=love.mouse.getPosition()
          if key == 'b' and naimagem (mx,my, rx, ry) then
             ry = originaly
             rx = originalx
          end
          if key == "down" and naimagem (mx,my, rx, ry) then
            ry = ry + 10
          end
          if key == "right" and naimagem (mx,my, rx, ry) then
            rx = rx + 10
          end
          if key == "up" and naimagem (mx,my, rx, ry) then
            ry = ry - 10
          end
          if key == "left" and naimagem (mx,my, rx, ry) then
            rx = rx - 10
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

