
led1 = 3
led2 = 6
sw1 = 1
sw2 = 2
speed = 1000
led2State = 0
but1 = 0
but2 = 0
timerstate=1
local meusleds = {led1, led2}

function gps2()
-- print AP list in old format (format not defined)
function listap(t)
    saida ="[[\n"
    saida=saida.."{\n\"WifiAccessPoints\": [\n"
    for k,v in pairs(t) do
      macAdress = v:match("%w+:%w+:%w+:%w+:%w+:%w+")
      macStart, macEnd = v:find(macAdress)
      channel = v:sub(macEnd+2)
      signalStrength = v:sub(v:find("-"),v:find(",",v:find("-")+1)-1)
      
      saida=saida.."\t{\n\t\t\"macAddress\": \"".. macAdress.."\",\n\t\t\"signalStrength\": "..signalStrength.. ",\n\t\t\"channel\": "..channel.."\n\t},\n"
      
      --print("\nSSID = ", k, "\tmacAdress = ",macAdress,"\tChannel = ",channel,"\tSignalStrength = ",signalStrength,"\n")
      
      --print(k.." : "..v, "\n")
    end
    saida=string.sub(saida, 0,-3)
    saida=saida.."\n]\n}\n]]"
    print(saida)
end
wifi.sta.getap(listap)

--print (saida)
http.post('https://www.googleapis.com/geolocation/v1/geolocate?key=AIzaSyCb99xDgITIsgK-9m9GMnumqKLGAxvR6ww',
  'Content-Type: application/json\r\n',saida,
  function(code, data)
    if (code < 0) then
      print("HTTP request failed :", code)
    else
      print(code, data)
    end
  end)

end


local meuid = "1221007"
local m = mqtt.Client("clientid " .. meuid, 120)

function publica(c, palavra)
  c:publish("apertou-tecla",palavra,0,0, 
            function(client) print("mandou!") end)
end

function novaInscricao (c)
  local msgsrec = 0
  function novamsg (c, t, m)
    print ("mensagem ".. msgsrec .. ", topico: ".. t .. ", dados: " .. m)
    msgsrec = msgsrec + 1
    print("localizacao")
    gps2()
    publica(cliente,"localizacao")
  end
  c:on("message", novamsg)
end

function conectado (client)
 publica(client, meuid)
 cliente=client
 client:subscribe("pediu-gps", 0, novaInscricao)
end 


m:connect("test.mosquitto.org", 1883, 0, 
             conectado,
             function(client, reason) print("failed reason: "..reason) end)
--m:close()



-------------
function mqttcb(topic, message)
   print("Received from topic: " .. topic .. " - message:" .. message)
  local str = {}
  local i=1
  string.gsub(message,"{(.-)}", function (a) str[i]=a i=i+1 end)
   --controle = not controle
end


for _,ledi in ipairs (meusleds) do
  gpio.mode(ledi, gpio.OUTPUT)
end

for _,ledi in ipairs (meusleds) do
  gpio.write(ledi, gpio.LOW);
end

gpio.mode(led1, gpio.OUTPUT)
gpio.mode(led2, gpio.OUTPUT)

gpio.write(led1, gpio.LOW);
gpio.write(led2, gpio.LOW);

gpio.mode(sw1,gpio.INT,gpio.PULLUP)
gpio.mode(sw2,gpio.INT,gpio.PULLUP)

function newpincb (sw)
  
   
  local ledstate = false
  local delay = 500000
  local last = 0
  return
  function (level, timestamp)
    local now = tmr.now()
    if now - last < delay then
      return
    end
    if(sw==1) then
      but1=timestamp
    else
      but2=timestamp
    end
    if(math.abs(but1 - but2) < delay) then
      if(timerstate==1) then
        tmr.unregister(timerId)
        timerstate=0
      end
      return
    end
    last = now
    if(led2State==0) then
      led2State=1
    else
      led2State=0
    end
    gpio.write(led2, led2State)
    if(sw==1) then
      speed=speed+500
      publica(cliente, sw)
    else
      publica(cliente, sw)
      if(speed>500) then
        speed=speed-500
      else
        speed=500
      end
    end
  end
end

-- Blink using timer alarm --
timerId = 0
led1State = 0

function alarme()
  led1State = 1 - led1State;
  gpio.write(led1, led1State)
  tmr.unregister(timerId)
  tmr.alarm(timerId, speed, tmr.ALARM_SINGLE, alarme) 
end

-- timer loop
tmr.alarm( timerId, speed, tmr.ALARM_AUTO, alarme) 

gpio.trig(sw1, "down", newpincb(sw1))
gpio.trig(sw2, "down", newpincb(sw2))
