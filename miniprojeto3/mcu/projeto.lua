sw1 = 1
sw2 = 2
last = tmr.now()

local meuid = "1221007"
local m = mqtt.Client("clientid " .. meuid, 120)

texto=""

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
    --print(saida)

    http.post('https://www.googleapis.com/geolocation/v1/geolocate?key=AIzaSyCb99xDgITIsgK-9m9GMnumqKLGAxvR6ww',
      'Content-Type: application/json\r\n',saida,
      function(code, data)
        if (code < 0) then
          print("HTTP request failed :", code)
          texto="deu erro"
        else
          print(code, data)
          texto=data
        end
      end)
      publica(cliente, texto)
end

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
    wifi.sta.getap(listap)
    print("teste")


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



function mqttcb(topic, message)
   print("Received from topic: " .. topic .. " - message:" .. message)
  local str = {}
  local i=1
  string.gsub(message,"{(.-)}", function (a) str[i]=a i=i+1 end)
end

gpio.mode(sw1,gpio.INT,gpio.PULLUP)
gpio.mode(sw2,gpio.INT,gpio.PULLUP)

function newpincb (sw)
  local delay = 500000
  local now = tmr.now()
  if now - last < delay then
    return
  end
  last = now
  wifi.sta.getap(listap)
end
gpio.trig(sw1, "down", newpincb)
gpio.trig(sw2, "down", newpincb)
