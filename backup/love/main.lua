local mqtt = require("mqtt_library")

texto= "texto"
j=0

function mqttcb(topic, message)
   print("Received from topic: " .. topic .. " - message:" .. message)
   texto ="Received : " .. topic .. " - message:" .. message.." click: ".. j
   j=j+1
   local str = {}
   local i=1
   string.gsub(message,"{(.-)}", function (a) str[i]=a i=i+1 end)
end

function love.keypressed(key)
  local mx, my=love.mouse.getPosition()
  if(key == 'a') then
    mqtt_client:publish("pediu-gps", "pediu")
  end
end

function love.load()
  width, height = love.graphics.getDimensions( )
  controle = true
  mqtt_client = mqtt.client.create("test.mosquitto.org", 1883, mqttcb)
  mqtt_client:connect("1221007")
  mqtt_client:subscribe({"apertou-tecla"})
end


function love.draw()
   love.graphics.print(texto, 10, height/2, 0, 2, 2, 0, 0, 0, 0 )
end

function love.update(dt)
  mqtt_client:handler()
end
  
