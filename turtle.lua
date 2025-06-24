function mkturtle()
   local t={}
   t.th=-90
   t.x=64
   t.y=64
   t.color=15
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
      line(t.x, t.y, newx, newy, t.color)
      t.x = newx
      t.y = newy
   end
   t.onscreen = function()
      return 0 <= t.x and t.x < 128 and 0 <= t.y and t.y < 128
   end
   t.setcolor = function(c)
      t.color = c
   end
   return t
end

function spiral(t, th, dr)
   local r = 0
   while (t.onscreen()) do
      t.fd(r)
      t.rt(th)
      r += dr
   end
end
