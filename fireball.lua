function checkKbd()
  if btn(1) -- right
  then
     wizard.send(0)
  end
  if btn(0) -- left
  then
    dragon.send(1)
  end
  return true
end

function drawWizard()
   local t = wizard
   t.jump(10, 64)
   t.setcolor(3)
   t.fd(10)
end

function drawDragon(t)
   local t = dragon
   t.jump(118, 64, 180)
   t.setcolor(8)
   t.fd(10)
end

function castFireball()
   ball = mkturtle()
   ball.jump(10, 64)
   ball.setcolor(9)
   ball.hide()
   n=1
   ball.exec(function()
         ball.pu()
         ball.fd(10)
         ball.rt(90)
         ball.pd()
         state=ball.save()
         for i = 1, n
         do
            ball.rt(15)
            ball.fd(1)
         end
         ball.load(state)
         ball.lt(180)
         for i = 1, n
         do
            ball.lt(15)
            ball.fd(1)
         end
         ball.load(state)
         ball.lt(90)

         return ball.onscreen()
   end)
   return false
end

function breatheFire()
   fire = mkturtle()
   fire.jump(118, 64, 180)
   s = 100
   fire.setcolor(9)
   fire.lt(30)
   fire.fd(s * 0.866)
   fire.rt(120)
   fire.fd(s)
   fire.rt(120)
   fire.fd(s * 0.866)
end
