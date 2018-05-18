local mqtt = require("mqtt_library")
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

function mqttcb(topic, message)
   print("Received from topic: " .. topic .. " - message:" .. message)
   local str = {}
   local i=1
   string.gsub(message,"{(.-)}", function (a) str[i]=a i=i+1 end)
   ret.keypressed(str[1])
   --controle = not controle
end

function love.keypressed(key)
  local mx, my=love.mouse.getPosition()
  mqtt_client:publish("apertou-tecla", "{"..key.."}".."{"..mx.."}".."{"..my.."}")
end

function love.load()

  controle = true
  mqtt_client = mqtt.client.create("test.mosquitto.org", 1883, mqttcb)
  mqtt_client:connect("1221007")
  --mqtt_client:subscribe({"apertou-tecla"})
  ret = retangulo (10,10,200,150) 
end


function love.draw()
   if controle then
     ret.draw()
   end
end

function love.update(dt)
  mqtt_client:handler()
end
  
