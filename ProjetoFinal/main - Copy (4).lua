local mqtt = require("mqtt_library")

function mqttcb(topic, message)
   --print("Received from topic: " .. topic .. " - message:" .. message .. "numero: " .. numero)
   --numero=numero+1
   if message=="gameover" then
     gamestatus =3
   else
    str = {}
    local i=1
    string.gsub(message,"{(.-)}", function (a) str[i]=a i=i+1 end)
   end
end


function newparede (bx,by)
  local paredex, paredey = bx, by
  return {
    draw = function ()
    love.graphics.rectangle("fill", paredex-tamanho/2, paredey-tamanho/2, tamanho, tamanho)
  end,
  }
end

function newbomb (vel, tx,ty)
  local bombx, bomby = tx,ty
  local bombi, bombj = (tx+tamanho/2)/tamanho,(ty-10+tamanho/2)/tamanho
  --local atirou=false
  local bombtamx, bombtamy =tamanho/3,tamanho/3
  local bombpulse=0
  local bombexplosionsize = player.explosionsize
  expu,expd,expr,expl =0,0,0,0
  --bombi=bombi-bombi%1
  --bombj=bombj-bombj%1
  listatile[bombi][bombj]=2 --bomba
  return {
    update = coroutine.wrap (function (self)
      
      while(1) do
        if bombtamx==tamanho/3 then
          bombtamy=tamanho/2
          bombtamx=tamanho/2
        else
          bombtamy=tamanho/3
          bombtamx=tamanho/3
        end
        bombpulse=bombpulse+1
        if bombpulse == 10 then self.explode = true end
        
        
        if bombpulse==9 then
        --bombi=bombi-bombi%1
        --bombj=bombj-bombj%1
        _,_,pi,pj=player.try()
        for i=1, player.explosionsize do
          if (bombi+i)<16 then
            if listatile[bombi+i][bombj]==3 then
              listatile[bombi+i][bombj] = 0 --vazio
              expr=i
              break
            elseif listatile[bombi+i][bombj]==1 then
              expr=i
              break
            end
            if bombi+i==(pi-pi%4)/4 and bombj==(pj-pj%4)/4 then
              gamestatus=2
              print("gameover")
            end
            expr=i
          end
        end
        for i=1,player.explosionsize do
          if (bombi-i)>0 then
            if listatile[bombi-i][bombj]==3 then
              listatile[bombi-i][bombj] = 0 --vazio
              expl=i
              break
            elseif listatile[bombi-i][bombj]==1 then
              expl=i
              break
            end
            if bombi-i==(pi-pi%4)/4 and bombj==(pj-pj%4)/4 then
              gamestatus=2
              print("gameover")
            end
            expl=i
          end
        end
        for i=1, player.explosionsize do
          if (bombj+i)<14 then
            if listatile[bombi][bombj+i]==3 then
              listatile[bombi][bombj+i] = 0 --vazio
              expd=i
              break
            elseif listatile[bombi][bombj+i]==1 then
              expd=i
              break
            end
            if bombi==(pi-pi%4)/4 and bombj+i==(pj-pj%4)/4 then
              gamestatus=2
              print("gameover")
            end
            expd=i
          end
        end
        for i=1, player.explosionsize do
            if (bombj-i)>0 then
              if listatile[bombi][bombj-i]==3 then
                listatile[bombi][bombj-i] = 0 --vazio
                expu=i
                break
              elseif listatile[bombi][bombj-i]==1 then
                expu=i
                break
              end
              if bombi==(pi-pi%4)/4 and bombj-i==(pj-pj%4)/4 then
                gamestatus=2
              print("gameover")
            end
              expu=i
            end
        end
        listatile[bombi][bombj] = 0 --vazio
        player.nbombs=player.nbombs-1
      end
      
        wait(vel,self)
      end
    end),
    isactive = (function (self)
        local now=love.timer.getTime()
        return (now>=self.timetowake)
      end),
      try = function ()
        return bombx, bomby, bombi, bombj
      end,
    draw = function ()
      if bombpulse<9 then
        love.graphics.circle("fill", bombx, bomby, bombtamx, bombtamy)
      else --eplosion drawing
        love.graphics.setColor(100,100,0)
        --love.graphics.rectangle("fill", bombx-bombi, bomby-bombj, bombtamx, bombtamy)
        print(expr)
        love.graphics.rectangle("fill", bombx-bombi, bomby-bombj, expr*tamanho, tamanho/3)
        love.graphics.rectangle("fill", bombx-bombi, bomby-bombj, -expl*tamanho, tamanho/3)
        love.graphics.rectangle("fill", bombx-bombi, bomby-bombj, tamanho/3, expd*tamanho)
        love.graphics.rectangle("fill", bombx-bombi, bomby-bombj, tamanho/3, -expu*tamanho)
        love.graphics.setColor(255,255,255)
      end
    end,
    timetowake=0,
    explode=false
  }
end


function newplayer (number)
  width, height = love.graphics.getDimensions( )
  local playerx, playery = 1.5* tamanho,10+1.5*tamanho
  local playerposi, playerposj = 8,8
  if number==2 then
    playerx, playery = tamanho/2+13*tamanho,10+tamanho/2+11*tamanho
    playerposi, playerposj = 56,48
  end

  return {
  try = function ()
    return playerx , playery, playerposi, playerposj
  end,
  update = function (ux,uy,uposi,uposj)
    playerx=ux
    playery=uy
    playerposi=uposi
    playerposj=uposj
  end,
  keypressed = function (key)
    if listatile[(playerposi-playerposi%4)/4+1][(playerposj-playerposj%4)/4]==0 and (playerposj%4==0 or listatile[(playerposi-playerposi%4)/4+1][(playerposj-playerposj%4)/4+1]==0) then
      if key == "right" or key=="d" then
          playerx = playerx + tamanho/4
          playerposi=playerposi+1
      end
    end
    if listatile[(playerposi-1-(playerposi-1)%4)/4][(playerposj-playerposj%4)/4]==0 and (playerposj%4==0 or listatile[(playerposi-1-(playerposi-1)%4)/4][(playerposj-playerposj%4)/4-1]==0) then
      if key == "left" or key=="a" then
        playerx = playerx - tamanho/4
        playerposi=playerposi-1
      end
    end
    if listatile[(playerposi-playerposi%4)/4][(playerposj-playerposj%4)/4+1]==0 and (playerposi%4==0 or listatile[(playerposi-playerposi%4)/4+1][(playerposj-playerposj%4)/4+1]==0) then
          if key == "down" or key=="s" then
        playery = playery + tamanho/4
        playerposj=playerposj+1
      end
    end
    if listatile[(playerposi-playerposi%4)/4][(playerposj-1-(playerposj-1)%4)/4]==0 and (playerposi%4==0 or listatile[(playerposi-playerposi%4)/4-1][(playerposj-1-(playerposj-1)%4)/4]==0) then
      if key == "up" or key=="w" then
        playery = playery - tamanho/4
        playerposj=playerposj-1
      end
    end
  end,
  affected = function (playerposx,playerposy)
      if (playerposx>=playerx and playerposx<=playerx+30 and playerposy<= playery+10 and playerposy>= playery-10) then
      -- "pegou" o jogador
        return true
      else
        return false
      end
  end,
  draw = function ()
    love.graphics.rectangle("fill", playerx-tamanho/2, playery-tamanho/2, tamanho, tamanho)
  end,
  nbombs=1,
  explosionsize=3
}
end

function love.keypressed(key)
  if key == "1" and gamestatus==0 then
    controle=1
    gamestatus=1
    mqtt_client:connect("player1")
    mqtt_client:subscribe({"player2"})
    player =  newplayer(1)
    playero=  newplayer(2)
  elseif key == "2" and gamestatus==0 then
    controle=2
    gamestatus=1
    mqtt_client:connect("player2")
    mqtt_client:subscribe({"player1"})
    player =  newplayer(2)
    playero=  newplayer(1)
  end
  if key == ' ' and gamestatus==1 then
    posx, posy, pi, pj = player.try()
    if player.nbombs <4 then
      if pi%4 >=2 then
        pi=pi+4
      end
      if pj%4 >=2 then
        pj=pj+4
      end
      if listatile[(pi-pi%4)/4][(pj-pj%4)/4]==0 then
        bx=((pi-pi%4)/4)*tamanho-tamanho/2
        by=10+((pj-pj%4)/4)*tamanho-tamanho/2
        table.insert(listabomb,1, newbomb(50,bx,by))
        listabomb[1].atirou=true
        player.nbombs=player.nbombs+1
      end
    end
  end
  if gamestatus==1 then
    player.keypressed(key)
  end
end

function love.load()
  numero = 1
  update=1
  bx=0
  by=0
  mqtt_client = mqtt.client.create("test.mosquitto.org", 1883, mqttcb)
  width, height = love.graphics.getDimensions( )
  tamanho=45
  controle=1
  gamestatus=0
  --pos = player.try()
  love.keyboard.setKeyRepeat(true)
  listabomb = {}
  listatile={}
  listaparede={}
  for i=1,15 do
    listatile[i]={}
    for j=1,13 do
      listatile[i][j] = 3 --parede detruivel
      if (i<4 and j<4) or (i>12 and j>10) then
        listatile[i][j] = 0 --vazio
      end
    end
  end
  
  for i=1,15 do
    listatile[i][1] = 1 --parede
    listatile[i][13] = 1 --parede
  end
  for j=1,13 do
    listatile[1][j] = 1 --parede
    listatile[15][j] = 1 --parede
  end
  
  for i=1,15 do
    for j=1,13 do
      if ((i%2 ==1) and (j%2==1)) then
        listatile[i][j] = 1 --parede
      end
    end
  end
  
  for i=1,15 do
    listaparede[i]={}
    for j=1,13 do
      listaparede[i][j]=newparede(tamanho/2+(i-1)*tamanho,10+tamanho/2+(j-1)*tamanho)
    end
  end
  
end

function love.draw()
  if gamestatus==0 then --tela de inicio
    love.graphics.print( "BOMBERGUY", (width/2)-120, height/2, 0, 3, 3, 0, 0, 0, 0 )
    love.graphics.print( "Pressione '1' ou '2' para definir jogador", width/2-240, (height)/2+70, 0, 2, 2, 0, 0, 0, 0 )
  elseif gamestatus == 1 then --jogo
    for i=1,15 do
      for j=1,13 do
        if listatile[i][j] == 1 then
          listaparede[i][j].draw()
        end
        if listatile[i][j] == 3 then
          love.graphics.setColor(255,0,0)
          listaparede[i][j].draw()
          love.graphics.setColor(255,255,255)
        end
      end
    end
    for i = 1,#listabomb do
      listabomb[i].draw()
    end
    love.graphics.setColor(0,0,255)
    player.draw()
    love.graphics.setColor(0,255,0)
    playero.draw()
    love.graphics.setColor(255,255,255)
  elseif gamestatus == 2 then
    love.graphics.print( "YOU LOSE", (width/2)-120, height/2, 0, 3, 3, 0, 0, 0, 0 )
    if controle==1 then
        mqtt_client:publish("player1", "gameover")
    else
        mqtt_client:publish("player2", "gameover")
    end
  elseif gamestatus == 3 then
    love.graphics.print( "YOU WIN", (width/2)-120, height/2, 0, 3, 3, 0, 0, 0, 0 )
  end
end

function love.update(dt)
    if gamestatus>0 then
      mqtt_client:handler()
      if controle==1 then
        string=string.format("{%.2f}{%.2f}{%.2f}{%.2f}{%.2f}{%.2f}",bx,by,player.try())
        --print ("envia "..string)
        mqtt_client:publish("player1", string)
      else
        string=string.format("{%.2f}{%.2f}{%.2f}{%.2f}{%.2f}{%.2f}",bx,by,player.try())
        --print ("envia "..string)
        mqtt_client:publish("player2", string)
      end
      if(str~=nil) then
        playero.update(tonumber(str[3]),tonumber(str[4]),tonumber(str[5]),tonumber(str[6]))
        --print(numero)
        if(tonumber(str[1])~=0 and tonumber(str[2])~=0) and listatile[(tonumber(str[1])+tamanho/2)/tamanho][(tonumber(str[2])-10+tamanho/2)/tamanho]==0 then
          table.insert(listabomb,newbomb(50,tonumber(str[1]),tonumber(str[2])))
          bx=0
          by=0
        end
      end
    end
      
    for i in ipairs(listabomb) do 
      if listabomb[i]:isactive() then
        listabomb[i]:update()
      end
    end
    for i in ipairs(listabomb) do
      if listabomb[i].explode then
        table.remove(listabomb, j)
      end
    end
end

function wait(segundos,meuobjeto)
  meuobjeto.timetowake=love.timer.getTime()+ segundos/100
  coroutine.yield()
end