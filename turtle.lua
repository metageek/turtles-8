routines={}
routines.rs = {}
routines.nextid = 1

turtles={}

turtleLines = {}

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

-- Not for use in a game loop. Instead, call runStep() from _update()
-- and turtleDraw() from _draw().
function runTurtles()
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
         print(r._id)
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

function mkturtle()
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

      deli(t.steps, 1)
      t.numsteps -= 1
      return t.numsteps > 0
   end

   function mkLine(x1, y1, x2, y2, color)
      return {
         x1=x1, y1=y1,
         x2=x2, y2=y2,
         color=color
      }
   end

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
      t.x = x or 64
      t.y = y or 64
      t.th = th or 0
   end
   t.home = function()
      t.jump()
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
   t.enqueue = function(step)
      t.steps[t.numsteps + 1] = step
      t.numsteps += 1
   end
   t.exec = function(f)
      print(f == nil)
      t.enqueue(mkroutine(f))
   end
   t.msgs = {}
   t.numMsgs = 0
   t.send = function(msg)
      t.msgs[t.numMsgs + 1] = msg
      t.numMsgs += 1
   end
   t.peekMsg = function()
      if t.numMsgs > 0
      then
         return t.msgs[1]
      else
         return nil
      end
   end
   t.recv = function(callback)
      t.exec(function()
            msg = t.peekMsg()
            if msg ~= nil
            then
               if t.numMsgs == 1
               then
                  t.numMsgs = 0
                  t.msgs = {}
               else
                  t.numMsgs -= 1
                  deli(t.msgs, 1)
               end
               callback(msg)
               return false
            else
               return true
            end
      end)
   end
   t.save = function()
      return {
         x = t.x,
         y = t.y,
         th = t.th,
         pen = t.pen
      }
   end
   t.load = function(state)
      t.jump(state.x, state.y, state.th)
      t.pen = state.pen
   end
   return t
end

function spiral(t, th, dr)
   local r = 0
   function spiralStep()
      t.rt(th)
      t.fd(r)
      r += dr
      return t.onscreen()
   end

   t.exec(spiralStep)
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
