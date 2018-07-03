local mqtt = require("mqtt_library")

function mqttcb(topic, message)
   --print("Received from topic: " .. topic .. " - message:" .. message .. "numero: " .. numero)
   --numero=numero+1
   if message=="gameover" then
     gamestatus =9
   elseif message=="ping" or message=="pong" then str = message 
  else
    str = {}
    local i=1
    string.gsub(message,"{(.-)}", function (a) str[i]=a i=i+1 end)
   end
end

function love.keypressed(key)
  if key == "1" and gamestatus==0 then
    controle=1
    gamestatus=1
    mqtt_client:connect("player1")
    mqtt_client:subscribe({"player2"})
  elseif key == "2" and gamestatus==0 then
    controle=2
    gamestatus=1
    mqtt_client:connect("player2")
    mqtt_client:subscribe({"player1"})
  end
  if gamestatus==1 then
  end
end

function love.load()
  mqtt_client = mqtt.client.create("test.mosquitto.org", 1883, mqttcb)
  width, height = love.graphics.getDimensions( )
  controle=1
  gamestatus=0
  love.keyboard.setKeyRepeat(true)
end

function love.draw()
  if gamestatus==0 then --tela de inicio
    love.graphics.print( "BOMBERGUY", (width/2)-120, height/2, 0, 3, 3, 0, 0, 0, 0 )
    love.graphics.print( "Pressione '1' ou '2' para definir jogador", width/2-240, (height)/2+70, 0, 2, 2, 0, 0, 0, 0 )
  elseif gamestatus==1 then --esperando outro jogador
    love.graphics.print( "AGUARDE", (width/2)-120, height/2, 0, 3, 3, 0, 0, 0, 0 )
  elseif gamestatus==2 then --comeco
    love.graphics.print( "a", (width/2)-120, height/2, 0, 3, 3, 0, 0, 0, 0 )
  elseif gamestatus==3 then --comeco
    love.graphics.print( "b", (width/2)-120, height/2, 0, 3, 3, 0, 0, 0, 0 )
  end
end

function love.update()
    if gamestatus>0 then
      mqtt_client:handler()
    end
    if gamestatus==1 then
        mqtt_client:publish("player"..controle, "ping")
      if str == "ping" then
          mqtt_client:publish("player"..controle, "pong")
      end
      if str == "pong" then
        gamestatus=2
      end
    elseif gamestatus==2 then
      mqtt_client:publish("player1", "a")
      if str~=nil then
        gamestatus=3
      end
    elseif gamestatus==3 then
      mqtt_client:publish("player2", "p")
      if str~=nil then
        gamestatus=2
      end
    end
end 

function wait(segundos,meuobjeto)
  meuobjeto.timetowake=love.timer.getTime()+ segundos/100
  coroutine.yield()
end