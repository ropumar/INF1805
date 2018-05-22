wificonf = {
  -- verificar ssid e senha
  ssid = "MyASUS",
  pwd = "asd12345",
  save = false
}

wifi.sta.config(wificonf)
print("modo: ".. wifi.setmode(wifi.STATION))
print("IP = "..wifi.sta.getip())
