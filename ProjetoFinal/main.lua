function newparede (bx,by)
  local x, y = bx, by
  return {
    draw = function ()
    love.graphics.rectangle("fill", x-tamanho/2, y-tamanho/2, tamanho, tamanho)
  end
  }
end

function newbomb (vel, tx,ty)
  local x, y = tx,ty
  local bi, bj = (tx+tamanho/2)/tamanho,(ty-10+tamanho/2)/tamanho
  --local atirou=false
  local tamx, tamy =tamanho/3,tamanho/3
  local pulse=0
  
  return {
    update = coroutine.wrap (function (self)
      
      while(1) do
        if tamx==tamanho/3 then
          tamy=tamanho/2
          tamx=tamanho/2
        else
          tamy=tamanho/3
          tamx=tamanho/3
        end
        pulse=pulse+1
        if pulse == 10 then self.explode = true end
        wait(vel,self)
      end
    end),
    isactive = (function (self)
        local now=love.timer.getTime()
        return (now>=self.timetowake)
      end),
      try = function ()
        return x, y, bi, bj
      end,
    draw = function ()
      love.graphics.circle("fill", x, y, tamx, tamy)
    end,
    timetowake=0,
    explode=false
  }
end

function newplayer ()
  local width, height = love.graphics.getDimensions( )
  local x, y = 1.5* tamanho,10+1.5*tamanho
  local posi, posj = 8,8
  return {
  try = function ()
    return x , y, posi, posj
  end,
  update = function (dt)
    if x > width then
      x = width
    end
    if y > height then
      y = height
    end
    if y < 0 then
      y= 0
    end
    if x < 0 then
      x= 0
    end
  end,
  keypressed = function (key)
    if listatile[(posi-posi%4)/4+1][(posj-posj%4)/4]==0 and (posj%4==0 or listatile[(posi-posi%4)/4+1][(posj-posj%4)/4+1]==0) then
      if key == "right" or key=="d" then
          x = x + tamanho/4
          posi=posi+1
      end
    end
    if listatile[(posi-1-(posi-1)%4)/4][(posj-posj%4)/4]==0 and (posj%4==0 or listatile[(posi-1-(posi-1)%4)/4][(posj-posj%4)/4-1]==0) then
      if key == "left" or key=="a" then
        x = x - tamanho/4
        posi=posi-1
      end
    end
    if listatile[(posi-posi%4)/4][(posj-posj%4)/4+1]==0 and (posi%4==0 or listatile[(posi-posi%4)/4+1][(posj-posj%4)/4+1]==0) then
          if key == "down" or key=="s" then
        y = y + tamanho/4
        posj=posj+1
      end
    end
    if listatile[(posi-posi%4)/4][(posj-1-(posj-1)%4)/4]==0 and (posi%4==0 or listatile[(posi-posi%4)/4-1][(posj-1-(posj-1)%4)/4]==0) then
      if key == "up" or key=="w" then
        y = y - tamanho/4
        posj=posj-1
      end
    end
  end,
  affected = function (posx,posy)
      if (posx>=x and posx<=x+30 and posy<= y+10 and posy>= y-10) then
      -- "pegou" o jogador
        return true
      else
        return false
      end
  end,
  draw = function ()
    love.graphics.rectangle("line", x-tamanho/2, y-tamanho/2, tamanho, tamanho)
  end,
  nbombs=1
}
end

function love.keypressed(key)
  if key == ' ' then
    posx, posy, pi, pj = player.try()
    if player.nbombs <4 then
      if pi%4 >=2 then
        pi=pi+4
      end
      if pj%4 >=2 then
        pj=pj+4
      end
      if listatile[(pi-pi%4)/4][(pj-pj%4)/4]==0 then
        listabomb[player.nbombs] = newbomb(50,((pi-pi%4)/4)*tamanho-tamanho/2,10+((pj-pj%4)/4)*tamanho-tamanho/2)
        listabomb[player.nbombs].atirou=true
        player.nbombs=player.nbombs+1
        listatile[(pi-pi%4)/4][(pj-pj%4)/4]=2 --bomba
      end
    end
  end
    player.keypressed(key)
end

function love.load()
  width, height = love.graphics.getDimensions( )
  tamanho=45
  player =  newplayer()
  pos = player.try()
  love.keyboard.setKeyRepeat(true)
  listabomb = {}
  listatile={}
  listaparede={}
  for i=1,15 do
    listatile[i]={}
    for j=1,13 do
      listatile[i][j] = 0 --vazio
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
    for j=1,13 do
      if listatile[i][j] == 1 then
        table.insert(listaparede,newparede(tamanho/2+(i-1)*tamanho,10+tamanho/2+(j-1)*tamanho))
      end
    end
  end
  
end

function love.draw()
  player.draw()
  for i = 1,#listabomb do
    listabomb[i].draw()
  end
  for i in ipairs(listaparede) do
     listaparede[i].draw()
  end
end

function love.update(dt)
    player.update(dt)
    for i = 1,#listabomb do 
      if listabomb[i]:isactive() then
        listabomb[i]:update()
      end
    end
    for i in ipairs(listabomb) do
      if listabomb[i].explode then
        _,_, pi, pj = listabomb[i].try()
        print(pi,pj)
        listatile[pi][pj] = 0 --vazio
        table.remove(listabomb, i)
        player.nbombs=player.nbombs-1
        end
    end
end

function wait(segundos,meuobjeto)
  meuobjeto.timetowake=love.timer.getTime()+ segundos/100
  coroutine.yield()
end