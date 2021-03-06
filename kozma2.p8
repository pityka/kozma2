pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
--game loop

debug = nil

started=false

function _init()
  vakond = init_plr()
  vakond.colls = 0
  vakond.spr_0 = 16
  vakond.under = false
  
  nagyp = init_plr()
  nagyp.colls = 1
  init_npc(nagyp)
  nagyp.can_piano = true
  nagyp.spr_0 = 32
  
  nagym = init_plr()
  nagym.colls = 1
  nagym.can_flower = true
  init_npc(nagym)
  nagym.spr_0 = 48
  
  holes = {}
  flowers = {}
  lanyok = {}
end

function _update()
  
  if not started then
  
    if btnp(❎) then
      started=true
    end
  else 
	  if not vakond.disabled then
	    control_plr(vakond)
	  end
	  update_npc(nagyp,targetlist())
	  update_npc(nagym,targetlist())
	  make_hole(vakond)
	  for hl in all(holes) do
	    update_hole(hl)
	  end
	  for fl in all(flowers) do
	    update_flower(fl)
	  end
	  if time() > 10 and
	   #lanyok == 0 then
	    local e = init_plr()
	    init_npc(e)
	    e.spr_0 = 96
	    e.def_idling=0
	    e.speed=10
	    e.maxspeed=1.5
	    local f = init_plr()
	    init_npc(f)
	    f.spr_0 = 80
	    f.speed=10
	    f.def_idling=0
	    f.maxspeed=1.5
	    lanyok = {e,f}
	    
	  end
	  for l in all(lanyok) do 
	    update_npc(l,{})
	  end
  end
  debug = #flowers
end 

function _draw()
  cls()
  if started then
	  map()
	  if not vakond.under then
	    draw_plr(vakond)
	  end
	  draw_plr(nagyp)
	  draw_plr(nagym)
	  
	  for hl in all(holes) do
	    draw_hole(hl)
  	end
	  for fl in all(flowers) do
	    draw_plr(fl)
	  end  	
	  
	  for fl in all(lanyok) do
	    draw_plr(fl)
	  end 
  	
  else
   print("contrary to first intuition",20,50) 
   print("what you see is a mole-hole",20,60)
   print("press ❎ to play!! ",20,70)  
   print("let's get started!!!",20,90)
   print("⬇️⬆️⬅️➡️ to move",0,112)
   print("❎ to dive",0,120)
   print("how to play:",0,100)
   
  end
 -- print(time(),0,16)
 -- print(nagyp.state,0,0)
 -- print(nagyp.targetx,0,8)
 --print(debug,0,30)

end
-->8
--plr
controly = 1.2
controlx = 1.2

function init_plr()
local plr = {}
plr.disabled=false
plr.x = flr(rnd(64)) + 32
plr.y = flr(rnd(64)) + 32
plr.dx = 0.0
plr.dy = 0.0
plr.spr_0 = 16
plr.spr_1 = 0
plr.friction = 0.8
plr.frame = 0
plr.frame_t = time()
plr.framerate = 0.3
plr.frame_length = 2
plr.flip = false
plr.maxspeed = 0.8
plr.anim=false
plr.colls=7
return plr
end 

function sprite(plr)
  return  plr.spr_0 +
          plr.spr_1 +
          plr.frame
end

function control_plr(plr)
  if btn(⬇️) then
    plr.dy += controly
  end
  if btn(⬆️) then
    plr.dy -= controly
  end
  if btn(⬅️) then
    plr.dx -= controlx 
  end
  if btn(➡️) then
    plr.dx += controlx
  end
  update_plr(plr)
end


function update_plr(plr)

plr.dx *= plr.friction
plr.dy *= plr.friction

plr.dx = mid(plr.dx,
        -plr.maxspeed,
        plr.maxspeed)
        
plr.dy = mid(plr.dy,
         -plr.maxspeed,
         plr.maxspeed)
         
if abs(plr.dx) < 0.1 then
plr.dx = 0
end
 
if abs(plr.dy) < 0.1 then
plr.dy = 0
end        
  if not plr.anim then
  if abs(plr.dx) > 0.1 and 
     plr.dx > 0 then
    plr.flip = true
    plr.spr_1 = 0
  elseif abs(plr.dx) > 0.1 and 
    plr.dx < 0 then
    plr.flip = false
    plr.spr_1 = 0
  elseif abs(plr.dy) > 0.1 and
    plr.dy > 0 then
    plr.flip = false
    plr.spr_1 = 2
  elseif abs(plr.dy) > 0.1 and 
    plr.dy < 0 then 
    plr.flip = false
    plr.spr_1 = 4
  else 
    plr.flip = false
    plr.spr_1 = 2
  end
  end
  
collide_map(plr)  
  
plr.x += plr.dx
plr.y += plr.dy 

if ((
     plr.dx != 0 or 
     plr.dy != 0
   ) or plr.anim) and
   (time() - plr.frame_t) > plr.framerate
then
  plr.frame_t = time()
  plr.frame = (plr.frame + 1) %
    plr.frame_length 
end

end 

function draw_plr(plr)
  if not plr.disabled then
  spr(sprite(plr),
      plr.x,
      plr.y,1,1,
      plr.flip)
  end
end

function collide_map(plr) 
 local nx = plr.x + plr.dx 
 local ny = plr.y + plr.dy 
 local flg =  fget(
        mget(nx/8,ny/8),plr.colls)
 
 if nx < 0 or nx > 127 or
    ny < 0 or ny > 127 then
    flg = true
 end
 if flg == true then
   plr.dx = 0
   plr.dy = 0
 end
end
-->8
--npc 

dropoffx = 20
dropoffy = 120
backx = 80
backy = 80
pianox = 20
pianoy = 10

function init_npc(npc)
  npc.speed=1
  npc.def_idling=3
  npc.state = 0
  -- 0 stand
  -- 1 random walk
  -- 2 on target
  -- 3 carry 
  -- 4 walk back
  -- 5 piano
  -- 6 plant
  npc.targetx = 0
  npc.targety = 0
  npc.last_change = time()
  npc.idling = 3
  npc.friction = 0.95
  return npc
end

function dist(a,b) 
 local dx = a.x - b.x 
 local dy = a.y - b.y
 return sqrt(dx * dx + dy * dy)
end

function npc_find(npc,targets)
   local found = nil
   local found_dist= 999999
	  local i = 1
	  
	  while 
	     i <= #targets
	    do 
	     local d = dist(targets[i],npc)
	    if 
	      d  < 20 and d < found_dist 
	    then
	       
	      found = targets[i]
	      found_dist = d
	    
	    end
	    i+=1
	  end
  return i,found,found_dist
end

function npc_state(
  npc,
  targets)
  if time() - 
     npc.last_change > 
     npc.idling
  then
    npc.anim=false
    npc.framerate=0.3
    if npc.state == 3 then
      dropoff(npc)
    elseif npc.state == 5 then
      
      play_piano(npc,
      follow_target(npc))
      
    elseif npc.state == 6 then
      plant_flower(npc,
       follow_target(npc))
     
    else
    npc.last_change = time()
    
		  local t_i,target,trgt_dst =
		     npc_find(npc,targets)
		  
		  if  npc.state != 4 and
		     target != nil
		   and trgt_dst < 3 then
		   
		   if contains(holes,target) then
		     del(holes,target)
		     npc.state = 0
		     npc.idling = 0
		   elseif target == vakond then
		     npc.state=3
		     npc.idling=0
		     vakond.disabled=true
		     npc.targetx = dropoffx
		     npc.targety = dropoffy
		     follow_target(npc)
		   end
		  elseif npc.state != 4
		   and target != nil then
		    npc.idling = 0.3
		    npc.state = 2
		    npc.targetx = target.x
		    npc.targety = target.y
		    follow_target(npc)
		  else 
		    npc.idling = npc.def_idling
		    local r = rnd(1)
		    if r < 0.3 and 
		      npc.can_piano then
		      npc.state=5
		      npc.idling=0
		      npc.targetx=pianox
		      npc.targety=pianoy
		      follow_target(npc)
		    elseif r < 0.7 and
		       npc.can_flower then
		      npc.state=6
		      npc.idling = 0
		      npc.targetx = flr(rnd(20))
		      npc.targety = flr(rnd(48))+32
		      follow_target(npc)
		    
		    elseif r < 0.8 then 
		      npc.state = 1
		      random_walk(npc)
		    else 
		      npc.state = 0
		    end
			  end
		  end
  end
  debug=npc.state
end

function dropoff(npc)
  npc.dx += npc.targetx - npc.x  
  npc.dy += npc.targety - npc.y
  local d = dist(npc,{x=npc.targetx,y=npc.targety})
  npc.dx /= d
  npc.dy /= d
  if d < 20 then
    npc.state = 4
    npc.idling= 5
    npc.targetx = backx
    npc.targety = backy
    vakond.x = dropoffx
    vakond.y = dropoffy
    vakond.disabled=false
    vakond.under=false
    follow_target(npc)
  end
end

function play_piano(npc,dist)  
  if dist < 2 then
    npc.last_change = time()
    npc.idling = 30
    music(0)
    npc.state = 0
    npc.dx=0
    npc.dy=0
    npc.spr_1=6
    npc.frame_length=3
    npc.anim=true
  end
end

function plant_flower(npc,dist)  
  if dist < 2 then
    npc.last_change = time()
    npc.idling = 9
    
    npc.state = 0
    npc.dx=0
    npc.dy=0
    npc.spr_1=6
    npc.frame_length=3
    npc.anim=true
    npc.framerate = 3
    add(flowers,init_flower(npc.x,npc.y))
  end
end

function follow_target(npc)
  npc.dx += npc.targetx - npc.x  
  npc.dy += npc.targety - npc.y
  d = dist(npc,{x=npc.targetx,y=npc.targety})
  npc.dx /= d
  npc.dy /= d
  return d
end

function random_walk(npc)
     
     local x = flr(rnd(11)-5)
     local y = flr(rnd(11)-5)
     npc.dx += x*npc.speed  
     npc.dy += y*npc.speed
end

function update_npc(npc,targets)
 npc_state(npc,targets)
 update_plr(npc)
end
  

-->8
--molehole
vakondki={4,3,2,1}
vakondbe={4,3,2,5}

function make_hole(vakond)
 if btnp(❎) then
   local hl = 
    init_hole(vakond,vakond.under)
   add(holes,hl)
   vakond.under = not vakond.under
   if vakond.under then
     vakond.colls = 7
   else 
     vakond.colls = 0
   end
   for fl in all(flowers) do
     local d = dist(fl,vakond)
     if d < 3 then
       del(flowers,fl)
     end
   end
 end

end

function init_hole(vakond,up)
 local hl = {}
 hl.x = vakond.x
 hl.y = vakond.y 
 hl.frame = 1
 hl.t = time()
 hl.up = up
 return hl
end

function update_hole(hl)
  if hl.frame < 3 and
     time() - hl.t < 0.3
  then
   hl.t = time()
   hl.frame += 1
  
  end
end

function draw_hole(hl)
   local seq
  if hl.up then
    seq = vakondki
  else 
    seq = vakondbe
  end 
	 spr(seq[hl.frame],
	      hl.x,
	      hl.y)
end
-->8
--targetlist

function targetlist()
  local lst = {}
  
  if not vakond.under and
    not vakond.disabled then
    add(lst,vakond)
  end
  
  for hl in all(holes) do
    add(lst,hl)
  end
  
  return lst
end


-->8
--util
function contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end
-->8
--flower
function init_flower(x,y)
  local fl = init_plr()
  fl.x = x
  fl.y = y
  fl.spr_0 = 64
  fl.spr_1=0
  fl.frame_length=3
  fl.anim=true
  fl.framerate = 3
  return fl
end

function update_flower(fl)
  if fl.frame == 2 then
   
  else
   update_plr(fl)
  end
end
__gfx__
000000000000000000000000000000000000000000000000000000000000000000009000bbbbbbbbb3bbbbbbbbbbbbbbccccccc38868888888688888888ccccc
000000000000000000000000000000000000000000000000000000000000000000099900bbbb3bbbbbbb3bbbbbbbbbbbccc88888888688888888688888888ccc
007007000000f00000000000000000000000000000005000000000000000000000099900bb3bbb3bbb3bbb3bbbbb8bbbcc8888888688688886888868868888cc
000770000055550000000000000000000000000000555500000000000000000000012800bbbbbbb3b3bb3bb3bbb838bbc888868888888888888688888886888c
000770000044440000044000000000000000000000444400000000000000000000ecd9e0bbbb9bbbbbbbbbbbbbbb8b3bc8888888886888688888868886888688
00700700044544400044540000044000000000000445444000000000000000000ee666eeb3b939bbb3bb3bbbb3bb3bbbc8868868888868888888888888688888
000000004444454404544440004454000005400044444544000000000000000000e666e0bbbb9bbbbbbbbbbbbbbbbbbb48888888888888868888888866666666
0000000000000000000000000000000000000000000000000000000000000000000d0d00bbbbbbbbbbb3bb3bbbbbbbbb36666666666666636888888664444466
000000000000000000000000000000000000000000000000000000000000000000000000b3bbbbbbb3bbbbbbb3bbbbbb36666444466666666688884664444466
000000000000000000000000000000000000000000000000000000000000000000000000bbbb3bbbbbbb3bbbbbbb3bbb36446466466664446646664664444466
00000000000000000005500000055000000ff000000ff000000ff000000ff000000000005556655655bbbb56bb3bbb3b36446466466664446644444664444466
005555000055550000f5550000555f0000555500005555000055550000555500000000006655566566bbbb65b3bb3bb336666444466664446666666664444466
0f2555500f25555500555f000055550000f5550000555f0000f5550000555f00000000005555655555414455444bbbbb36666666666664446666666664444466
05555550055555500055550000f5550000555f0000f5550000555f0000f55500000000005565556656444466444b3bbb33666699e9999ddd99999999999e9996
00f6006f006f00f60025250000525200000550000005500000055000000550000000000065565555bbbbbbbb444bbbbb3369999999e99ddd999e9e9999999e96
0000000000000000000ff000000ff000000000000000000000000000000000000000000055655565bbb3bb3b4443bb3b36699999e9999dddd99999e9999e9996
0033300000333000043334000433340004333400043334000433340004333400043334000000000000000000444bbbbbccccccc34464444444644444444ccccc
00f9f40000f9f400049f9400049f94000444440004444400049f9400049f9400049f94000000000000000000444b3bbbccc44444444644444444644444444ccc
0fefff000fefff000feeff000feeff000f444f000f444f000feeff000feeff000feeff000000000000000000444bbb3bcc4444444644644446444464464444cc
0045200000452000092520000025290000222000002220000095200000252000002590000000000000000000444b3bb3c444464444444444444644444446444c
0005900000059000002569000925200009222000002229000025900000992000002920000000000000000000444bbbbbc4444444446444644444464446444644
0022220000222200002220000022200000222000002220000171710006161600071117000000000000000000444b3bbbc4464464444464444444444444644444
05500d0000d0500000d0d00000d0d00000d050000050d00000d0d00000d0d00000d0d0000000000000000000444bbbbb44444444444444464466666666666666
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000004443bb3b36666666666666636666666666666666
00000000000000000000000000000000000000000000000000000000000000000000000000009000000000000000000036666444466666666644444666666666
00444400004444000044440000444400004444000044440000000000000000000000000000099900000000000000000036666466466664446646664666666666
001f4440041f4440041f1f40041f1f40044444400444444000044440000444400004444000099900000000000000000036666466466664446644444666666666
00ffff0000ffff0000ffff0000ffff0000444400004444000041f4440041f4440041f44400012800000000000000000036666444466664446666666666666666
0008800000088000000880000f088000000880000f088000000ffff0000ffff0800ffff000ecd9e0000000000000000036666666666664446666666666666666
008f88000088f8000f8888f00f8888f00f8888f00f8888f00000880000008800a80088000ee666ee000000000000000033666699e9999ddd99999999999e9996
002222000022220000222200002222f000222200002222f000088f8030088f8030088f8000e666e000000000000000003366669999e99ddd999e9e9999999e96
00d0e00000e0d00000d0de0000e0ed0000e0ed0000d0de00300222203302222033022220000d0d00000000000000000036666699e9999dddd99999e9999e9996
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000300000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000300000089800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000000300000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000000300000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00444400004444000044440000444400004444000044440000000000000000000000000000000000000000000000000000000000000000000000000000000000
441f1444441f1444441f1444441f1444441f1444441f144400000000000000000000000000000000000000000000000000000000000000000000000000000000
00fff00000fff00000fff00000fff00000fff00000fff00000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088000000880000008800000088000000880000008800000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f8888f00f8888f00f8888f00f8888f00f8888f00f8888f000000000000000000000000000000000000000000000000000000000000000000000000000000000
00f0f00000f0f00000f0f00000f0f00000f0f00000f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00999900009999000099990000999900009999000099990000000000000000000000000000000000000000000000000000000000000000000000000000000000
991f1999991f1999991f1999991f1999991f1999991f199900000000000000000000000000000000000000000000000000000000000000000000000000000000
00fff00000fff00000fff00000fff00000fff00000fff00000000000000000000000000000000000000000000000000000000000000000000000000000000000
000cc000000cc000000cc000000cc000000cc000000cc00000000000000000000000000000000000000000000000000000000000000000000000000000000000
0fccccf00fccccf00fccccf00fccccf00fccccf00fccccf000000000000000000000000000000000000000000000000000000000000000000000000000000000
00f0f00000f0f00000f0f00000f0f00000f0f00000f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
ccccccc38868888888688888888cccccb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbb000000000000000000000000
ccc88888888688888888688888888cccbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbb000000000000000000000000
cc8888888688688886888868868888ccbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3b000000000000000000000000
c888868888888888888688888886888cb3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3000000000000000000000000
c8888888886888688888868886888688bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000000000000000000000000
c8868868888868888888888888688888b3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbb000000000000000000000000
48888888888888868888888866666666bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000000000000000000000000
36666666666666636888888664444466bbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3b000000000000000000000000
36666444466666666688884664444466b3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbb00000000
36446466466664446646664664444466bbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbb00000000
36446466466664446644444664444466bb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3b00000000
36666444466664446666666664444466b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb300000000
36666666666664446666666664444466bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00000000
33666699e9999ddd99999999999e9996b3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbb00000000
3369999999e99ddd999e9e9999999e96bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00000000
36699999e9999dddd99999e9999e9996bbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3b00000000
b3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbb00000000
bbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbb00000000
bb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3b00000000
b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb300000000
444bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00000000
444b3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbb00000000
444bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00000000
4443bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3b00000000
444bbbbbb3bbbbbbbbbbbbbbbbbbbbbbb3bbbbbbb3bbbbbbbbbbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbb0000000000000000
444b3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbbbbbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbb0000000000000000
444bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbbbb8bbbbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3b0000000000000000
444b3bb3b3bb3bb3bbbbbbb3bbbbbbb3b3bb3bb3b3bb3bb3bbb838bbb3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb30000000000000000
444bbbbbbbbbbbbbbbbb9bbbbbbb9bbbbbbbbbbbbbbbbbbbbbbb8b3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000000000000000
444b3bbbb3bb3bbbb3b939bbb3b939bbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbb0000000000000000
444bbbbbbbbbbbbbbbbb9bbbbbbb9bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000000000000000
4443bb3bbbb3bb3bbbbbbbbbbbbbbbbbbbb3bb3bbbb3bb3bbbbbbbbbbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3b0000000000000000
444bbbbbb3bbbbbbbbbbbbbbbbbbbbbbb3bbbbbbbbbbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbbbbbbbbbbbbbbbbbb3bbbbbbbbbbbbbbbbbbbbbb
444b3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbbbbbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbb
444bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbbbb8bbbbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3b
444b3bb3b3bb3bb3bbbbbbb3bbbbbbb3b3bb3bb3bbb838bbb3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3bbbbbbb3bbbbbbb3b3bb3bb3bbbbbbb3bbbbbbb3
444bbbbbbbbbbbbbbbbb9bbbbbbb9bbbbbbbbbbbbbbb8b3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb9bbbbbbb9bbbbbbbbbbbbbbb9bbbbbbb9bbb
444b3bbbb3bb3bbbb3b939bbb3b939bbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3b939bbb3b939bbb3bb3bbbb3b939bbb3b939bb
444bbbbbbbbbbbbbbbbb9bbbbbbb9bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb9bbbbbbb9bbbbbbbbbbbbbbb9bbbbbbb9bbb
4443bb3bbbb3bb3bbbbbbbbbbbbbbbbbbbb3bb3bbbbbbbbbbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbbbbbbbbbbbbbbbbbb3bb3bbbbbbbbbbbbbbbbb
444bbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbbbbbbbbb
444b3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbb
444bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3b
444b3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3bbbbbbb3
444bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb9bbb
444b3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3b939bbb3b939bbb3b939bbb3b939bbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3b939bb
444bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb9bbb
4443bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbbbbbbb
444bbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbbbbbbbbbb3bbbbbbbbbbbbbb
444b3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbbbbbbbbbb3bbbbbbb3bbb
444bbb3b55bbbb56bb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbbbb8bbbbb3bbb3bbb3bbb3b
444b3bb366bbbb65bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3bbb838bbb3bb3bb3bbbbbbb3
444bbbbb55414455bbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb8b3bbbbbbbbbbbbb9bbb
444b3bbb56444466b3b939bbb3b939bbb3b939bbb3b939bbb3b939bbb3b939bbb3b939bbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3b939bb
444bbbbbbbbbbbbbbbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb9bbb
4443bb3bbbb3bb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbbbbbbbbbb3bb3bbbbbbbbb
444bbbbbb3bbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbbbbbbbbbbbb3bbbbbbbbbbbbbbb3bbbbbbbbbbbbbb
444b3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbbbbbbbbbb3bbbbbbbbbbbbbbb3bbbbbbb3bbb
444bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbbbb8bbbbb3bbb3bbbbb8bbbbb3bbb3bbb3bbb3b
444b3bb3b3bb3bb3b3bb3bb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3b3bb3bb3bbb838bbb3bb3bb3bbb838bbb3bb3bb3bbbbbbb3
444bbbbbbbbbbbbbbbbbbbbbbbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbbbbbbbbbbbbbb8b3bbbbbbbbbbbbb8b3bbbbbbbbbbbbb9bbb
444b3bbbb3bb3bbbb3bb3bbbb3b939bbb3b939bbb3b939bbb3b939bbb3b939bbb3b939bbb3b939bbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3b939bb
444bbbbbbbbbbbbbbbbbbbbbbbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb9bbb
4443bb3bbbb3bb3bbbb3bb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bb3bbbbbbbbbbbb3bb3bbbbbbbbbbbb3bb3bbbbbbbbb
444bbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbbbbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbb3bbbbbbb3bbbbbbbbbbbbbbbbbbbbbbb3bbbbbbb3bbbbbbbbbbbbbb
444b3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbb
444bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3b
444b3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3bbbbbbb3b3bb3bb3bbbbbbb3bbbbbbb3b3bb3bb3b3bb3bb3bbbbbbb3bbbbbbb3b3bb3bb3b3bb3bb3bbbbbbb3
444bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb9bbbbbbbbbbbbbbb9bbbbbbb9bbbbbbbbbbbbbbbbbbbbbbb9bbbbbbb9bbbbbbbbbbbbbbbbbbbbbbb9bbb
444b3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3b939bbb3bb3bbbb3b939bbb3b939bbb3bb3bbbb3bb3bbbb3b939bbb3b939bbb3bb3bbbb3bb3bbbb3b939bb
444bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb9bbbbbbbbbbbbbbb9bbbbbbb9bbbbbbbbbbbbbbbbbbbbbbb9bbbbbbb9bbbbbbbbbbbbbbbbbbbbbbb9bbb
4443bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbbbbbbbbbb3bb3bbbbbbbbbbbbbbbbbbbb3bb3bbbb3bb3bbbbbbbbbbbbbbbbbbbb3bb3bbbb3bb3bbbbbbbbb
444bbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbbbbbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbbbbbbbbb
444b3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbbbbbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbb
444bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbbbb8bbbbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3b
444b3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3bbb838bbb3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3bbbbbbb3
444bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb8b3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb9bbb
444b3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3b939bb
444bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb9bbb
4443bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbbbbbbbbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbbbbbbb
444bbbbbb3bbbbbbbbbbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbbbbbbbbb
444b3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbb
444bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3b
444b3bb3b3bb3bb3bbbbbbb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3bbbbbbb3
444bbbbbbbbbbbbbbbbb9bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb9bbb
444b3bbbb3bb3bbbb3b939bbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3b939bb
444bbbbbbbbbbbbbbbbb9bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb9bbb
4443bb3bbbb3bb3bbbbbbbbbbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbbbbbbb
444bbbbbb3bbbbbbb3bbbbbbbbbbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
444b3bbbbbbb3bbbbbbb3bbbbbbbbbbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbb
444bbb3bbb3bbb3bbb3bbb3bbbbb8bbbbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3b
444b3bb3b3bb3bb3b3bb3bb3bbb838bbb3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3
444bbbbbbbbbbbbbbbbbbbbbbbbb8b3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbb
444b3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3b939bbb3b939bbb3b939bbb3b939bbb3b939bb
444bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbb
4443bb3bbbb3bb3bbbb3bb3bbbbbbbbbbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbb3bbbbbbb3bbbbbbb3bbbbbbbbbbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbbbbbbbbbbbbbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbb
bb3bbb3bbb3bbb3bbb3bbb3bbbbb8bbbbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbbbb8bbbbbbb8bbbbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3b
bbbbbbb3bbbbbbb3bbbbbbb3bbb838bbb3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3bbbbbbb3bbb838bbbbb838bbbbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3
bbbb9bbbbbbb9bbbbbbb9bbbbbbb8b3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb9bbbbbbb8b3bbbbb8b3bbbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbb
b3b939bbb3b939bbb3b939bbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3b939bbb3bb3bbbb3bb3bbbb3b939bbb3b939bbb3b939bbb3b939bbb3b939bb
bbbb9bbbbbbb9bbbbbbb9bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb9bbbbbbbbbbbbbbbbbbbbbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbb
bbbbbbbbbbbbbbbbbbbbbbb333bbbbbbbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbf9f4bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbb3bbbbbbb3bbbbbbb3bfefffb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbb
bb3bbb3bbb3bbb3bbb3bbb34523bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3b
bbbbbbb3bbbbbbb3bbbbbbb359bbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3
bbbb9bbbbbbb9bbbbbbb9bb2222b9bbbbbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbb
b3b939bbb3b939bbb3b93955b3d939bbb3b939bbb3b939bbb3b939bbb3b939bbb3b939bbb3b939bbb3b939bbb3b939bbb3b939bbb3b939bbb3b939bbb3b939bb
bbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbbbbbb9bbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbccccccc34464444444644444444ccccc
bbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbccc44444444644444444644444444ccc
5556655655bbbb5655566556555665565556655655566556555665565556655655566556555665565556655655566556cc4444444644644446444464464444cc
6655566566bbbb6566555665665556656655566566555665665556656655566566555665665556656655566566555665c444464444444444444644444446444c
555565555541445555556555555565555555655555556555555565555555655555556555555565555555655555556555c4444444446444644444464446444644
556555665644446655655566556555665565556655655566556555665565556655655566556555665565556655655566c4464464444464444444444444644444
65565555bbbbbbbb6556555565565555655655556556555565565555655655556556555565565555655655556556555544444444444444464466666666666666
55655565bbb3bb3b5565556555655565556555655565556555655565556555655565556555655565556555655565556536666666666666636666666666666666
b3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbb36666444466666666644444666666666
bbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbb36666466466664446646664666666666
bb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3bbb3b36666466466664446644444666666666
b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb336666444466664446666666666666666
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb36666666666664446666666666666666
b3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbb33666699e9999ddd99999999999e9996
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3366669999e99ddd999e9e9999999e96
bbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3b36666699e9999dddd99999e9999e9996

__gff__
0000000000000000000000000303010100000000000000000003030001010101000000000000000000000000030303030000000000000000000000000303030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0c0d0e0f0a0a0a0a0a0a0a0a0a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1c1d1e1f0a0a0a0a0a0a0a0a0a0a0a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b0a0a0a0a0a0a0a0a0a0a0a0a0a0a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2b0a09090a0a0b0a0a0a0a0a0a0a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2b0a09090a0b0a0a0a0a0a09090a090900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2b0a0a0a0a0a090909090a0a0a0a0a0900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2b09090909090909090a0a0a0a0b0a0900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2b0a0a090909090909090a0b0a0b0a0900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2b0a0a0a0a090a09090a0a09090a0a0900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2b0a0a0a0a0a0a0a0b0a0a0a0a0a0a0900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2b0a090a0a0a0a0a0a0a0a0a0a0a0a0900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2b0a0a0b0a0a0a0a0a0a0a090909090900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0909090b0a0a0a0a090b0b090909090909000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0909090909090909090909090909090900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
191a191919191919191919192c2d2e2f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a0a0a0a0a0a0a0a0a0a0a0a3c3d3e3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0118000018055180501805518050180551805018050180501805018055170551505517055180551a0551a0501c0551c0501c0551c0501c0551c0501c0501c0501c0501c0551a055180551a0551c0551d0551d050
011800001f0551f0501f0501f0501805518050180501805018050210551f0551d0551c0551c0501a0551a050180551805018050180500c0001a0551c0551d0551f0551f0501d0551c0551a0551a0501a0501a050
011800001f0551f0501f0501f0501805518050180501805018050210551f0551d0551c0551c0501a0351a0302b0002b0002b000240001a0551c0551d0551f0551f0501f050180551805018050180501805018050
__music__
00 00424344
00 01424344
00 00424344
00 02424344

