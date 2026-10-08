local Plrs=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local Run=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local Tween=game:GetService("TweenService")
local Cam=workspace.CurrentCamera
local LP=Plrs.LocalPlayer
local function gp(n,f)local ok,v=pcall(function()return getgenv and getgenv()[n]or _G[n]end)if ok and v~=nil then return v end return f end
local Exec={getnil=gp("getnilinstances",function()return{}end),req=gp("request",function()return{StatusCode=0,Body=""}end),qot=gp("queue_on_teleport",function()end)}
local function log(...)end
local function notify(t,d)game:GetService("StarterGui"):SetCore("SendNotification",{Title=t,Text=d,Duration=3})end
local function char()return LP.Character or LP.CharacterAdded:Wait()end
local function hrp()local c=char()return c and c:FindFirstChild("HumanoidRootPart")end
local function hum()local c=char()return c and c:FindFirstChildOfClass("Humanoid")end
local function alive()local h=hum()return h and h.Health>0 end
local function dist(a,b)if typeof(a)=="Instance"then a=a.Position end if typeof(b)=="Instance"then b=b.Position end return(a-b).Magnitude end
local function tp(pos)local p=hrp()if p then p.CFrame=CFrame.new(pos+Vector3.new(0,3,0))end end
local function rar(name)
  local m={Common=1,Uncommon=2,Rare=3,Epic=4,Legendary=5,Mythical=6,Godly=7,Ancient=8,Exotic=9}
  return m[name]or 0
end
local Gun=""
local Remotes={}
local function norm(n)return n:lower():gsub("[%s_%-%.]","")end
local function scan()
  local all={}
  for _,c in ipairs(RS:GetChildren())do
    if c:IsA("RemoteEvent")or c:IsA("RemoteFunction")then table.insert(all,c)
    elseif c:IsA("Folder")then for _,s in ipairs(c:GetDescendants())do if s:IsA("RemoteEvent")or s:IsA("RemoteFunction")then table.insert(all,s)end end end
  end
  local nilInst=Exec.getnil()
  for _,n in ipairs(nilInst)do if n and(n:IsA("RemoteEvent")or n:IsA("RemoteFunction"))then table.insert(all,n)end end
  local seen,u={},{}
  for _,r in ipairs(all)do if not seen[r]then seen[r]=true;table.insert(u,r)end end
  Remotes=u
  local pat={
    collect={"coin","collect","pickup","grab"},
    shoot={"shoot","fire","gun","hit","damage"},
    stab={"stab","knife","slash","melee"},
    equip={"equip","unequip"},
    gun={"gun","sheriff"},
  }
  for cat,list in pairs(pat)do
    for _,r in ipairs(Remotes)do
      if not Remotes[cat]then
        local rn=norm(r.Name)
        for _,p in ipairs(list)do if rn:find(norm(p),1,true)then Remotes[cat]=r;break end end
      end
    end
  end
end
local function fire(cat,...)
  local r=Remotes[cat]
  if not r then return false end
  local args=table.pack(...)
  local ok,err=pcall(function()if r:IsA("RemoteEvent")then r:FireServer(table.unpack(args,1,args.n))else return r:InvokeServer(table.unpack(args,1,args.n))end end)
  if not ok then return false,err end
  return true
end

local Cfg={
  AutoFarm=false,
  FarmSpeed=150,
  AutoGun=false,
  SilentAim=false,
  SilentFOV=120,
  KillAura=false,
  AuraRange=15,
  ESP=false,
  Fly=false,
  FlySpeed=120,
  Speed=16,
  Noclip=false,
  AntiFling=false,
  TpMurderer=false,
  TpGun=false,
}

local function isMurderer(p)
  if not p.Character then return false end
  local knife=p.Character:FindFirstChild("Knife")
  local hum=p.Character:FindFirstChildOfClass("Humanoid")
  if knife then return true end
  if hum then
    local tool=p.Character:FindFirstChildWhichIsA("Tool")
    if tool and tool.Name:lower():find("knife")then return true end
  end
  return false
end
local function isSheriff(p)
  if not p.Character then return false end
  local gun=p.Character:FindFirstChild("Gun")
  if gun then return true end
  local tool=p.Character:FindFirstChildWhichIsA("Tool")
  if tool and tool.Name:lower():find("gun")then return true end
  return false
end
local function getMurderer()
  for _,p in ipairs(Plrs:GetPlayers())do
    if p~=LP and p.Character and p.Character.Parent and isMurderer(p)then return p end
  end
  return nil
end
local function getSheriff()
  for _,p in ipairs(Plrs:GetPlayers())do
    if p~=LP and p.Character and p.Character.Parent and isSheriff(p)then return p end
  end
  return nil
end
local function droppedGun()
  for _,o in ipairs(workspace:GetDescendants())do
    if o:IsA("Tool")and(o.Name:lower():find("gun")or o.Name:lower():find("sheriff"))and not o.Parent:FindFirstChildOfClass("Humanoid")then return o end
  end
  return nil
end

local function farmLoop()
  task.spawn(function()
    while true do
      if Cfg.AutoFarm then
        local p=hrp()
        if p then
          local best,bd=nil,math.huge
          for _,o in ipairs(workspace:GetDescendants())do
            if o:IsA("BasePart")and(o.Name:lower():find("coin")or o:FindFirstChild("Coin")or o:GetAttribute("Coin"))then
              local d=dist(p,o)
              if d<bd then bd=d;best=o end
            end
          end
          if best then
            local d=dist(p,best)
            if d>5 then
              local dir=(best.Position-p.Position).Unit
              p.CFrame=CFrame.new(p.Position+dir*math.min(Cfg.FarmSpeed*0.1,d))
            else
              fire("collect",best)
              if fireproximityprompt then pcall(fireproximityprompt,best:FindFirstChildOfClass("ProximityPrompt"))end
            end
          end
        end
      end
      task.wait(0.1)
    end
  end)
end

local function silentAimLoop()
  task.spawn(function()
    while true do
      if Cfg.SilentAim and alive() then
        local m=getMurderer()
        if m and m.Character then
          local mh=m.Character:FindFirstChild("HumanoidRootPart")
          if mh then
            local d=dist(hrp(),mh)
            if d<=Cfg.SilentFOV then
              fire("shoot",mh)
            end
          end
        end
      end
      task.wait(0.05)
    end
  end)
end

local function killAuraLoop()
  task.spawn(function()
    while true do
      if Cfg.KillAura and alive() then
        local me=hrp()
        if me then
          for _,p in ipairs(Plrs:GetPlayers())do
            if p~=LP and p.Character and p.Character.Parent then
              local th=p.Character:FindFirstChild("HumanoidRootPart")
              if th then
                local d=dist(me,th)
                if d<=Cfg.AuraRange then
                  fire("stab",th)
                end
              end
            end
          end
        end
      end
      task.wait(0.1)
    end
  end)
end

local function autoGunLoop()
  task.spawn(function()
    while true do
      if Cfg.AutoGun then
        local g=droppedGun()
        if g then
          tp(g.Position)
          task.wait(0.2)
          if fireproximityprompt then pcall(fireproximityprompt,g:FindFirstChildOfClass("ProximityPrompt"))end
        end
      end
      task.wait(0.3)
    end
  end)
end

local espFolder=nil
local function clearESP()
  if espFolder then espFolder:Destroy();espFolder=nil end
end
local function buildESP()
  clearESP()
  local sg=Instance.new("ScreenGui")
  sg.Name="ETFB_ESP"
  sg.ResetOnSpawn=false
  sg.IgnoreGuiInset=true
  sg.Parent=game:GetService("CoreGui")
  espFolder=sg
end
local function updateESP()
  if not Cfg.ESP then return end
  if not espFolder then buildESP()end
  for _,p in ipairs(Plrs:GetPlayers())do
    if p~=LP and p.Character then
      local h=p.Character:FindFirstChild("HumanoidRootPart")
      if h then
        local tag=espFolder:FindFirstChild(p.Name)
        if not tag then
          local bb=Instance.new("BillboardGui")
          bb.Name=p.Name
          bb.Adornee=h
          bb.Size=UDim2.new(0,200,0,50)
          bb.StudsOffset=Vector3.new(0,3,0)
          bb.AlwaysOnTop=true
          bb.Parent=espFolder
          local tl=Instance.new("TextLabel")
          tl.Size=UDim2.new(1,0,1,0)
          tl.BackgroundTransparency=1
          tl.TextColor3=Color3.new(1,1,1)
          tl.TextStrokeTransparency=0
          tl.TextSize=14
          tl.Font=Enum.Font.GothamBold
          tl.Parent=bb
        end
        local bb=espFolder:FindFirstChild(p.Name)
        if bb then
          local tl=bb:FindFirstChildOfClass("TextLabel")
          if tl then
            local role="Innocent"
            if isMurderer(p)then role="Murderer"elseif isSheriff(p)then role="Sheriff"end
            tl.Text=p.Name.." ["..role.."]"
            tl.TextColor3=role=="Murderer"and Color3.fromRGB(255,60,60)or(role=="Sheriff"and Color3.fromRGB(60,140,255)or Color3.fromRGB(100,255,100))
          end
          bb.Adornee=h
        end
      end
    end
  end
  for _,tag in ipairs(espFolder:GetChildren())do
    if not Plrs:FindFirstChild(tag.Name)then tag:Destroy()end
  end
end

local function movementLoop()
  task.spawn(function()
    while true do
      if Cfg.Fly and alive()then
        local h=hrp()
        if h then
          local bv=h:FindFirstChild("ETFB_FlyBV")
          if not bv then
            bv=Instance.new("BodyVelocity")
            bv.Name="ETFB_FlyBV"
            bv.MaxForce=Vector3.new(1e5,1e5,1e5)
            bv.Velocity=Vector3.zero
            bv.Parent=h
          end
          local move=Vector3.zero
          if UIS:IsKeyDown(Enum.KeyCode.W)then move=move+Cam.CFrame.LookVector end
          if UIS:IsKeyDown(Enum.KeyCode.S)then move=move-Cam.CFrame.LookVector end
          if UIS:IsKeyDown(Enum.KeyCode.A)then move=move-Cam.CFrame.RightVector end
          if UIS:IsKeyDown(Enum.KeyCode.D)then move=move+Cam.CFrame.RightVector end
          local v=0
          if UIS:IsKeyDown(Enum.KeyCode.Space)then v=1 end
          if UIS:IsKeyDown(Enum.KeyCode.LeftShift)then v=-1 end
          bv.Velocity=(move.Magnitude>0 and move.Unit or Vector3.zero)*Cfg.FlySpeed+Vector3.new(0,v*Cfg.FlySpeed,0)
        end
      else
        local h=hrp()
        if h then local bv=h:FindFirstChild("ETFB_FlyBV")if bv then bv:Destroy()end end
      end
      task.wait(0.05)
    end
  end)
end

local function noclipLoop()
  task.spawn(function()
    while true do
      if Cfg.Noclip then
        local c=char()
        if c then for _,o in ipairs(c:GetDescendants())do if o:IsA("BasePart")then o.CanCollide=false end end end
      end
      task.wait(0.1)
    end
  end)
end

local function speedLoop()
  task.spawn(function()
    while true do
      if alive()then
        local h=hum()
        if h and h.WalkSpeed~=Cfg.Speed then h.WalkSpeed=Cfg.Speed end
      end
      task.wait(0.2)
    end
  end)
end

local function tpLoop()
  task.spawn(function()
    while true do
      if Cfg.TpMurderer then
        local m=getMurderer()
        if m and m.Character then
          local h=m.Character:FindFirstChild("HumanoidRootPart")
          if h then tp(h.Position)end
        end
      end
      if Cfg.TpGun then
        local g=droppedGun()
        if g then tp(g.Position)end
      end
      task.wait(0.5)
    end
  end)
end

local function antiFlingLoop()
  task.spawn(function()
    while true do
      if Cfg.AntiFling then
        local h=hrp()
        if h and h.AssemblyLinearVelocity.Magnitude>200 then
          h.AssemblyLinearVelocity=h.AssemblyLinearVelocity.Unit*50
        end
      end
      task.wait(0.1)
    end
  end)
end

local function mainLoop()
  task.spawn(function()
    while true do
      pcall(updateESP)
      task.wait(0.2)
    end
  end)
end

scan()
farmLoop()
silentAimLoop()
killAuraLoop()
autoGunLoop()
movementLoop()
noclipLoop()
speedLoop()
tpLoop()
antiFlingLoop()
mainLoop()

local gui=Instance.new("ScreenGui")
gui.Name="ETFB_MM2"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.Parent=game:GetService("CoreGui")

local main=Instance.new("Frame")
main.Size=UDim2.new(0,260,0,420)
main.Position=UDim2.new(0.5,-130,0.5,-210)
main.BackgroundColor3=Color3.fromRGB(20,20,25)
main.BorderSizePixel=0
main.Parent=gui

local corner=Instance.new("UICorner")
corner.CornerRadius=UDim.new(0,8)
corner.Parent=main

local stroke=Instance.new("UIStroke")
stroke.Color=Color3.fromRGB(0,170,255)
stroke.Thickness=1.5
stroke.Transparency=0.3
stroke.Parent=main

local title=Instance.new("TextLabel")
title.Size=UDim2.new(1,0,0,36)
title.BackgroundColor3=Color3.fromRGB(15,15,20)
title.Text="ETFB MM2 | Farm + Combat"
title.TextColor3=Color3.fromRGB(240,240,240)
title.TextSize=14
title.Font=Enum.Font.GothamBold
title.BorderSizePixel=0
title.Parent=main

local tcorner=Instance.new("UICorner")
tcorner.CornerRadius=UDim.new(0,8)
tcorner.Parent=title

local close=Instance.new("TextButton")
close.Size=UDim2.new(0,28,0,28)
close.Position=UDim2.new(1,-32,0.5,-14)
close.BackgroundColor3=Color3.fromRGB(40,40,45)
close.Text="×"
close.TextColor3=Color3.fromRGB(240,240,240)
close.TextSize=18
close.Font=Enum.Font.GothamBold
close.BorderSizePixel=0
close.AutoButtonColor=false
close.Parent=title

local ccorner=Instance.new("UICorner")
ccorner.CornerRadius=UDim.new(0,6)
ccorner.Parent=close

close.MouseButton1Click:Connect(function()gui.Enabled=not gui.Enabled end)

local scroll=Instance.new("ScrollingFrame")
scroll.Size=UDim2.new(1,-16,1,-50)
scroll.Position=UDim2.new(0,8,0,42)
scroll.BackgroundTransparency=1
scroll.BorderSizePixel=0
scroll.CanvasSize=UDim2.new(0,0,0,600)
scroll.ScrollBarThickness=4
scroll.Parent=main

local layout=Instance.new("UIListLayout")
layout.Padding=UDim.new(0,6)
layout.SortOrder=Enum.SortOrder.LayoutOrder
layout.Parent=scroll

local function makeToggle(text,default,cb)
  local f=Instance.new("Frame")
  f.Size=UDim2.new(1,-8,0,32)
  f.BackgroundColor3=Color3.fromRGB(25,25,30)
  f.BorderSizePixel=0
  f.Parent=scroll
  local c=Instance.new("UICorner")
  c.CornerRadius=UDim.new(0,6)
  c.Parent=f
  local l=Instance.new("TextLabel")
  l.Size=UDim2.new(1,-60,1,0)
  l.Position=UDim2.new(0,10,0,0)
  l.BackgroundTransparency=1
  l.Text=text
  l.TextColor3=Color3.fromRGB(240,240,240)
  l.TextSize=12
  l.Font=Enum.Font.Gotham
  l.TextXAlignment=Enum.TextXAlignment.Left
  l.Parent=f
  local b=Instance.new("TextButton")
  b.Size=UDim2.new(0,36,0,18)
  b.Position=UDim2.new(1,-46,0.5,-9)
  b.BackgroundColor3=default and Color3.fromRGB(0,170,255)or Color3.fromRGB(50,50,55)
  b.Text=""
  b.BorderSizePixel=0
  b.AutoButtonColor=false
  b.Parent=f
  local bc=Instance.new("UICorner")
  bc.CornerRadius=UDim.new(0,9)
  bc.Parent=b
  local k=Instance.new("Frame")
  k.Size=UDim2.new(0,14,0,14)
  k.Position=default and UDim2.new(1,-16,0.5,-7)or UDim2.new(0,2,0.5,-7)
  k.BackgroundColor3=Color3.fromRGB(255,255,255)
  k.BorderSizePixel=0
  k.Parent=b
  local kc=Instance.new("UICorner")
  kc.CornerRadius=UDim.new(1,0)
  kc.Parent=k
  local state=default
  b.MouseButton1Click:Connect(function()
    state=not state
    b.BackgroundColor3=state and Color3.fromRGB(0,170,255)or Color3.fromRGB(50,50,55)
    Tween:Create(k,TweenInfo.new(0.15),{Position=state and UDim2.new(1,-16,0.5,-7)or UDim2.new(0,2,0.5,-7)}):Play()
    if cb then cb(state)end
  end)
end

local function makeSlider(text,min,max,default,cb)
  local f=Instance.new("Frame")
  f.Size=UDim2.new(1,-8,0,44)
  f.BackgroundColor3=Color3.fromRGB(25,25,30)
  f.BorderSizePixel=0
  f.Parent=scroll
  local c=Instance.new("UICorner")
  c.CornerRadius=UDim.new(0,6)
  c.Parent=f
  local l=Instance.new("TextLabel")
  l.Size=UDim2.new(0.5,0,0,20)
  l.Position=UDim2.new(0,10,0,2)
  l.BackgroundTransparency=1
  l.Text=text
  l.TextColor3=Color3.fromRGB(240,240,240)
  l.TextSize=12
  l.Font=Enum.Font.Gotham
  l.TextXAlignment=Enum.TextXAlignment.Left
  l.Parent=f
  local v=Instance.new("TextLabel")
  v.Size=UDim2.new(0.5,-10,0,20)
  v.Position=UDim2.new(0.5,0,0,2)
  v.BackgroundTransparency=1
  v.Text=tostring(default)
  v.TextColor3=Color3.fromRGB(0,170,255)
  v.TextSize=12
  v.Font=Enum.Font.GothamBold
  v.TextXAlignment=Enum.TextXAlignment.Right
  v.Parent=f
  local bg=Instance.new("Frame")
  bg.Size=UDim2.new(1,-20,0,8)
  bg.Position=UDim2.new(0,10,0,28)
  bg.BackgroundColor3=Color3.fromRGB(45,45,55)
  bg.BorderSizePixel=0
  bg.Parent=f
  local bc=Instance.new("UICorner")
  bc.CornerRadius=UDim.new(0,4)
  bc.Parent=bg
  local fill=Instance.new("Frame")
  fill.Size=UDim2.new((default-min)/(max-min),0,1,0)
  fill.BackgroundColor3=Color3.fromRGB(0,170,255)
  fill.BorderSizePixel=0
  fill.Parent=bg
  local fc=Instance.new("UICorner")
  fc.CornerRadius=UDim.new(0,4)
  fc.Parent=fill
  local dragging=false
  local function upd(inp)
    local rx=math.clamp((inp.Position.X-bg.AbsolutePosition.X)/bg.AbsoluteSize.X,0,1)
    local val=math.floor(min+(max-min)*rx)
    fill.Size=UDim2.new(rx,0,1,0)
    v.Text=tostring(val)
    if cb then cb(val)end
  end
  bg.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true;upd(i)end end)
  UIS.InputChanged:Connect(function(i)if dragging and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then upd(i)end end)
  UIS.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
end

local function makeButton(text,cb)
  local b=Instance.new("TextButton")
  b.Size=UDim2.new(1,-8,0,32)
  b.BackgroundColor3=Color3.fromRGB(30,30,38)
  b.Text=text
  b.TextColor3=Color3.fromRGB(240,240,240)
  b.TextSize=12
  b.Font=Enum.Font.Gotham
  b.BorderSizePixel=0
  b.AutoButtonColor=false
  b.Parent=scroll
  local c=Instance.new("UICorner")
  c.CornerRadius=UDim.new(0,6)
  c.Parent=b
  b.MouseEnter:Connect(function()b.BackgroundColor3=Color3.fromRGB(40,40,50)end)
  b.MouseLeave:Connect(function()b.BackgroundColor3=Color3.fromRGB(30,30,38)end)
  b.MouseButton1Click:Connect(function()if cb then cb()end end)
end

local function section(t)
  local l=Instance.new("TextLabel")
  l.Size=UDim2.new(1,-8,0,22)
  l.BackgroundTransparency=1
  l.Text="── "..t.." ──"
  l.TextColor3=Color3.fromRGB(0,170,255)
  l.TextSize=12
  l.Font=Enum.Font.GothamBold
  l.TextXAlignment=Enum.TextXAlignment.Left
  l.Parent=scroll
end

section("FARM")
makeToggle("Auto Farm Coins",Cfg.AutoFarm,function(v)Cfg.AutoFarm=v end)
makeSlider("Farm Speed",50,300,Cfg.FarmSpeed,function(v)Cfg.FarmSpeed=v end)
makeToggle("Auto Grab Gun",Cfg.AutoGun,function(v)Cfg.AutoGun=v end)
makeButton("Собрать монету рядом",function()local p=hrp()if p then local b,bd=nil,math.huge for _,o in ipairs(workspace:GetDescendants())do if o:IsA("BasePart")and o.Name:lower():find("coin")then local d=dist(p,o)if d<bd then bd=d;b=o end end end if b then tp(b.Position)end end end)

section("COMBAT")
makeToggle("Silent Aim (Sheriff)",Cfg.SilentAim,function(v)Cfg.SilentAim=v end)
makeSlider("Silent FOV",30,300,Cfg.SilentFOV,function(v)Cfg.SilentFOV=v end)
makeToggle("Kill Aura (Murderer)",Cfg.KillAura,function(v)Cfg.KillAura=v end)
makeSlider("Aura Range",5,50,Cfg.AuraRange,function(v)Cfg.AuraRange=v end)
makeButton("Убить всех (Murderer)",function()
  for _,p in ipairs(Plrs:GetPlayers())do
    if p~=LP and p.Character then
      local h=p.Character:FindFirstChild("HumanoidRootPart")
      if h then fire("stab",h)end
    end
  end
end)

section("VISUAL")
makeToggle("ESP (роли)",Cfg.ESP,function(v)Cfg.ESP=v;if not v then clearESP()end end)
makeButton("Убийца",function()local m=getMurderer()if m then notify("Murderer",m.Name)end end)
makeButton("Шериф",function()local s=getSheriff()if s then notify("Sheriff",s.Name)end end)

section("MOVEMENT")
makeToggle("Fly",Cfg.Fly,function(v)Cfg.Fly=v end)
makeSlider("Fly Speed",20,400,Cfg.FlySpeed,function(v)Cfg.FlySpeed=v end)
makeToggle("Noclip",Cfg.Noclip,function(v)Cfg.Noclip=v end)
makeSlider("Speed",16,200,Cfg.Speed,function(v)Cfg.Speed=v end)
makeToggle("Anti Fling",Cfg.AntiFling,function(v)Cfg.AntiFling=v end)

section("TELEPORT")
makeToggle("TP to Murderer",Cfg.TpMurderer,function(v)Cfg.TpMurderer=v end)
makeToggle("TP to Gun",Cfg.TpGun,function(v)Cfg.TpGun=v end)
makeButton("К убийце",function()local m=getMurderer()if m and m.Character then local h=m.Character:FindFirstChild("HumanoidRootPart")if h then tp(h.Position)end end end)
makeButton("К шерифу",function()local s=getSheriff()if s and s.Character then local h=s.Character:FindFirstChild("HumanoidRootPart")if h then tp(h.Position)end end end)
makeButton("К пушке",function()local g=droppedGun()if g then tp(g.Position)end end)

section("UTILITY")
makeButton("Ре-джойн",function()Exec.qot("loadstring(game:HttpGet('https://raw.githubusercontent.com/nPuBATHOCTb/sfpoidujuaoufoidsuauf/main/ETFB.lua'))()")game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId,game.JobId,LP)end)
makeButton("Сменить сервер",function()
  local ok,data=pcall(function()
    local r=Exec.req({Url="https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=100",Method="GET"})
    return r.StatusCode==200 and game:GetService("HttpService"):JSONDecode(r.Body)or nil
  end)
  if ok and data and data.data then
    local list={}
    for _,s in ipairs(data.data)do if s.id~=game.JobId and s.playing<s.maxPlayers then table.insert(list,s.id)end end
    if #list>0 then game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId,list[math.random(1,#list)],LP)end
  end
end)
