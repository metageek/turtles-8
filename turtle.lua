routines={}
routines.rs = {}
routines.nextid = 1

turtles={}

turtleLines = {}

function mkLine(x1, y1, x2, y2, color)
   return {
      x1=x1, y1=y1,
      x2=x2, y2=y2,
      color=color
   }
end

-- Coroutine. step is a function which returns true if there are more
-- steps to perform, or false if not.
function mkroutine(step, register)
   local r={}
   r._step = step
   if register then
      r._id = routines.nextid
      routines.nextid = routines.nextid + 1
      routines.rs[r._id] = r
   end
   return r
end

function run()
   busy = true
   while busy
   do
      busy = runStep()
   end
end

function runStep()
   busy = false
   local removed = {}
   rs = routines.rs
   for i,r in ipairs(rs)
   do
      if r ~= nil
      then
         busy = true
         if not r._step(r)
         then
            removed[#removed + 1] = r
         end
      end
   end

   for _, r in ipairs(removed)
   do
      routines.rs[r._id] = nil
   end

   return busy
end

function turtleStep(t)
   if t.numsteps == 0
   then
      return false
   end

   local step = t.steps[1]
   if step._step(step)
   then
      return true
   end

   del(t.steps, 1)
   t.numsteps -= 1
   return t.numsteps > 0
end

function mkturtle()
   local t=mkroutine(turtleStep, true)
   turtles[t._id] = t
   t.th=-90
   t.x=64
   t.y=64
   t.color=15
   t.pen=true
   t.visible=true
   t.rt = function(dth)
      t.th += dth
      t.th %= 360
   end
   t.lt = function(dth)
      t.rt(-dth)
   end
   t.fd = function(s)
      local th = t.th / 360
      local newx = t.x + s * cos(th)
      local newy = t.y - s * sin(th)
      if t.pen then
         turtleLines[#turtleLines + 1] = mkLine(t.x, t.y, newx, newy, t.color)
      end
      t.x = newx
      t.y = newy
   end
   t.jump = function(x, y, th)
      t.x = x
      t.y = y
      t.th = th
   end
   t.onscreen = function()
      return 0 <= t.x and t.x < 128 and 0 <= t.y and t.y < 128
   end
   t.setcolor = function(c)
      t.color = c
   end
   t.pu = function()
      t.pen=false
   end
   t.pd = function()
      t.pen=true
   end
   t.show = function()
      t.visible = true
   end
   t.hide = function()
      t.visible = false
   end
   t.draw = function()
      local s = 6
      local th1 = t.th / 360
      local x1 = t.x - s * cos(th1)
      local y1 = t.y - s * sin(th1)
      local th2 = (t.th + 90) / 360
      local x2 = t.x + (s / 2) * cos(th2)
      local y2 = t.y + (s / 2) * sin(th2)
      local th3 = (t.th - 90) / 360
      local x3 = t.x + (s / 2) * cos(th3)
      local y3 = t.y + (s / 2) * sin(th3)

      line(x1, y1, x2, y2, t.color)
      line(x2, y2, x3, y3, t.color)
      line(x3, y3, x1, y1, t.color)
   end
   t.steps={}
   t.numsteps = 0
   t.exec = function(step)
      t.steps[t.numsteps + 1] = step
      t.numsteps += 1
   end
   return t
end

function spiralStep(r)
   r.t.rt(r.th)
   r.t.fd(r.r)
   r.r += r.dr
   return r.t.onscreen()
end

function mkspiral(t, th, dr)
   r = mkroutine(spiralStep)
   r.t = t
   r.th = th
   r.dr = dr
   r.r = 0
   return r
end

function spiral(t, th, dr)
   t.exec(mkspiral(t, th, dr))
end

function turtleDraw()
   for _, l in ipairs(turtleLines)
   do
      line(l.x1, l.y1, l.x2, l.y2, l.color)
   end
   for _, t in ipairs(turtles)
   do
      if t ~= nil and t.visible
      then
         t.draw()
      end
   end
end
