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
    else
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
