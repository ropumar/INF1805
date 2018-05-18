-- file : application.lua
local module = {}
m = nil

-- Sends a simple ping to the broker
local function send_ping()
    m:publish("apertou-tecla","id=" .. "1221007",0,0)
end

-- Sends my id to the broker for registration
local function register_myself()
    m:subscribe("apertou-tecla" .. "1221007",0,function(conn)
        print("Successfully subscribed to data endpoint")
    end)
end

local function mqtt_start()
    m = mqtt.Client("1221007", 120)
    -- register message callback beforehand
    m:on("message", function(conn, topic, data) 
      if data ~= nil then
        print(topic .. ": " .. data)
        -- do something, we have received a message
      end
    end)
    -- Connect to broker
    m:connect("test.mosquitto.org", "1883", 0, 1, function(con) 
        register_myself()
        -- And then pings each 1000 milliseconds
        tmr.stop(6)
        tmr.alarm(6, 1000, 1, send_ping)
    end) 

end

function module.start()
  mqtt_start()
end

return module