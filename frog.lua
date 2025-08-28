-- H2K Mod Menu (99 Nights in the Forest) - Android KRNL
-- By H2K
-- Minimizable, draggable, Android touch-ready
-- Opciones: Speed +/- , Infinite Jump, TP to Camp, Kill Aura (80 studs animales), Insta Open Chests

-- Servicios
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Estado
local State = {
    visible = true,
    killAura = false,
    infJump = false,
    speed = 16,
    killRange = 80,
    autoOpen = false
}

local Connections = {}

-- UTIL: safe connect for touch + mouse
local function bindButton(btn, fn)
    pcall(function() btn.MouseButton1Click:Connect(fn) end)
    pcall(function() if btn.TouchTap then btn.TouchTap:Connect(fn) end end)
end

-- BUSCADORES (campfire, mobs, chests)
local function findCampfire()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = obj.Name:lower()
            if name:find("campfire") or name:find("firepit") or name:find("camp") then
                return obj
            end
        end
    end
    return nil
end

local mobPatterns = {"wolf","alpha wolf","bear","alpha bear","cultist","rabbit","bunny","fox","wolf_alpha","bear_alpha","animal"}
local function isMobModel(model)
    if not model or not model:IsA("Model") then return false end
    local nm = model.Name:lower()
    for _,p in ipairs(mobPatterns) do
        if nm:find(p) then return true end
    end
    -- also check for Humanoid + keywords in descendants
    for _,desc in ipairs(model:GetDescendants()) do
        if desc:IsA("BasePart") then
            local n = desc.Name:lower()
            for _,p in ipairs(mobPatterns) do
                if n:find(p) then return true end
            end
        end
    end
    return false
end

local function findNearbyMobs(originPos, radius)
    local found = {}
    for _, model in ipairs(Workspace:GetDescendants()) do
        if model:IsA("Model") and isMobModel(model) then
            local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
            local humanoid = model:FindFirstChildOfClass("Humanoid")
            if root and humanoid and humanoid.Health > 0 then
                local dist = (root.Position - originPos).Magnitude
                if dist <= radius then
                    table.insert(found, {model = model, root = root, humanoid = humanoid, dist = dist})
                end
            end
        end
    end
    return found
end

local function findChests()
    local chests = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("Folder") then
            if obj:FindFirstChildWhichIsA("ProximityPrompt") or obj:FindFirstChild("Chest") or obj.Name:lower():find("chest") or obj.Name:lower():find("crate") then
                table.insert(chests, obj)
            end
        elseif obj:IsA("BasePart") then
            if obj:FindFirstChildWhichIsA("ProximityPrompt") or obj.Name:lower():find("chest") or obj.Name:lower():find("crate") then
                table.insert(chests, obj)
            end
        end
    end
    return chests
end

-- ACTIONS
local function tpToCamp()
    local camp = findCampfire()
    local char = LocalPlayer.Character
    if not camp or not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    pcall(function()
        hrp.CFrame = camp.CFrame + Vector3.new(0,5,0)
    end)
end

-- Kill Aura: daño a mobs en radio (no toca a jugadores humanos)
local function doKillAura()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local origin = char.HumanoidRootPart.Position
    local mobs = findNearbyMobs(origin, State.killRange)
    for _,info in ipairs(mobs) do
        pcall(function()
            -- Intentamos reducir su vida de forma segura
            local h = info.humanoid
            if h and h.Health > 0 then
                -- intentamos TakeDamage (funciona en la mayoría)
                if pcall(function() h:TakeDamage(9999) end) then
                    -- ok
                else
                    -- fallback: set health to 0
                    if pcall(function() h.Health = 0 end) then end
                end
            end
        end)
    end
end

-- Insta-open chests: dispara ProximityPrompt si existe
local function instantOpenChests()
    local chests = findChests()
    for _,obj in ipairs(chests) do
        pcall(function()
            -- buscar ProximityPrompt en modelo
            local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then
                -- fire proximity prompt (exploit helper)
                if pcall(function() fireproximityprompt(prompt) end) then
                    -- fired
                else
                    -- fallback: try :InputHoldBegin/:InputHoldEnd via prompt module (best-effort)
                    -- many exploits provide fireproximityprompt; if not available, skip
                end
            end
        end)
    end
end

-- Infinite jump toggle
local function toggleInfJump(on)
    if on then
        Connections.infJump = UserInputService.JumpRequest:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if Connections.infJump then Connections.infJump:Disconnect() Connections.infJump = nil end
    end
end

-- Speed apply loop
Connections.speedLoop = RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        if char.Humanoid.WalkSpeed ~= State.speed then
            pcall(function() char.Humanoid.WalkSpeed = State.speed end)
        end
    end
end)

-- Kill aura loop
Connections.killLoop = RunService.Heartbeat:Connect(function()
    if State.killAura then
        doKillAura()
    end
    if State.autoOpen then
        instantOpenChests()
    end
end)

-- GUI (minimal + aesthetic)
local gui = Instance.new("ScreenGui")
gui.Name = "H2K_Menu"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 320, 0, 260)
main.Position = UDim2.new(0, 20, 0.25, 0)
main.BackgroundColor3 = Color3.fromRGB(18,18,22)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui

local mc = Instance.new("UICorner", main); mc.CornerRadius = UDim.new(0,12)
local stroke = Instance.new("UIStroke", main); stroke.Color = Color3.fromRGB(0,200,120); stroke.Thickness = 2

-- header / title
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1,0,0,48)
header.Position = UDim2.new(0,0,0,0)
header.BackgroundColor3 = Color3.fromRGB(10,10,12)
local hc = Instance.new("UICorner", header); hc.CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1,-80,1,0)
title.Position = UDim2.new(0,12,0,0)
title.BackgroundTransparency = 1
title.Text = "⚔ H2K - 99 Nights"
title.TextColor3 = Color3.fromRGB(0,240,140)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.TextScaled = true

local minBtn = Instance.new("TextButton", header)
minBtn.Size = UDim2.new(0,36,0,36)
minBtn.Position = UDim2.new(1,-44,0,6)
minBtn.BackgroundColor3 = Color3.fromRGB(40,40,44)
minBtn.Text = "—"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextColor3 = Color3.fromRGB(255,255,255)
local minc = Instance.new("UICorner", minBtn); minc.CornerRadius = UDim.new(0,8)

bindButton(minBtn, function()
    State.visible = not State.visible
    for _,v in ipairs(main:GetChildren()) do
        if v ~= header then v.Visible = State.visible end
    end
end)

-- footer "by h2k"
local footer = Instance.new("TextLabel", main)
footer.Size = UDim2.new(1, -16, 0, 24)
footer.Position = UDim2.new(0,8,1,-30)
footer.BackgroundTransparency = 1
footer.Text = 'by "h2k"'
footer.TextColor3 = Color3.fromRGB(180,180,180)
footer.TextScaled = true
footer.Font = Enum.Font.Gotham

-- container for buttons
local function makeButton(text, pos)
    local b = Instance.new("TextButton", main)
    b.Size = UDim2.new(0,148,0,40)
    b.Position = pos
    b.BackgroundColor3 = Color3.fromRGB(35,35,40)
    b.TextColor3 = Color3.fromRGB(230,230,230)
    b.Font = Enum.Font.Gotham
    b.TextScaled = true
    local cr = Instance.new("UICorner", b); cr.CornerRadius = UDim.new(0,8)
    return b
end

-- Row 1
local btnSpeedUp = makeButton("Speed +5", UDim2.new(0,12,0,56))
local btnSpeedDown = makeButton("Speed -5", UDim2.new(0,164,0,56))
local lblSpeed = Instance.new("TextLabel", main)
lblSpeed.Size = UDim2.new(0,148,0,30); lblSpeed.Position = UDim2.new(0,12,0,100)
lblSpeed.BackgroundTransparency = 1; lblSpeed.Text = "Speed: "..tostring(State.speed)
lblSpeed.TextColor3 = Color3.fromRGB(200,200,200); lblSpeed.Font = Enum.Font.Gotham

bindButton(btnSpeedUp, function()
    State.speed = State.speed + 5
    lblSpeed.Text = "Speed: "..tostring(State.speed)
end)
bindButton(btnSpeedDown, function()
    State.speed = math.max(8, State.speed - 5)
    lblSpeed.Text = "Speed: "..tostring(State.speed)
end)

-- Row 2: Infinite Jump toggle
local btnInfJump = makeButton("Infinite Jump: OFF", UDim2.new(0,12,0,134))
bindButton(btnInfJump, function()
    State.infJump = not State.infJump
    btnInfJump.Text = "Infinite Jump: "..(State.infJump and "ON" or "OFF")
    toggleInfJump(State.infJump)
end)

-- Row 3: TP to camp
local btnTP = makeButton("TP to Camp", UDim2.new(0,164,0,134))
bindButton(btnTP, function()
    tpToCamp()
end)

-- Row 4: Kill Aura toggle
local btnKA = makeButton("Kill Aura: OFF", UDim2.new(0,12,0,178))
bindButton(btnKA, function()
    State.killAura = not State.killAura
    btnKA.Text = "Kill Aura: "..(State.killAura and "ON" or "OFF")
end)

-- Row 5: Insta Open Chests toggle
local btnOpen = makeButton("Insta Open Chests: OFF", UDim2.new(0,164,0,178))
bindButton(btnOpen, function()
    State.autoOpen = not State.autoOpen
    btnOpen.Text = "Insta Open Chests: "..(State.autoOpen and "ON" or "OFF")
end)

-- Extras: show kill range and allow change
local lblRange = Instance.new("TextLabel", main)
lblRange.Size = UDim2.new(0,148,0,22); lblRange.Position = UDim2.new(0,12,0,218)
lblRange.BackgroundTransparency = 1; lblRange.Text = "Kill Range: "..tostring(State.killRange)
lblRange.TextColor3 = Color3.fromRGB(200,200,200); lblRange.Font = Enum.Font.Gotham; lblRange.TextScaled = true

local incRange = makeButton("+ Range", UDim2.new(0,164,0,212))
bindButton(incRange, function()
    State.killRange = math.min(200, State.killRange + 10)
    lblRange.Text = "Kill Range: "..tostring(State.killRange)
end)

-- initial visibility
for _,v in ipairs(main:GetChildren()) do
    if v ~= header then v.Visible = State.visible end
end

-- Touch double-tap to show/hide (optional)
local lastTap = 0
UserInputService.TouchTapInWorld:Connect(function(_, processed)
    if processed then return end
    local now = tick()
    if now - lastTap < 0.45 then
        State.visible = not State.visible
        for _,v in ipairs(main:GetChildren()) do
            if v ~= header then v.Visible = State.visible end
        end
    end
    lastTap = now
end)

-- Cleanup on respawn: reparent gui
Players.PlayerRemoving:Connect(function(p) end)
LocalPlayer.CharacterAdded:Connect(function(char)
    wait(0.6)
    -- ensure speed and infjump applied
    if State.infJump then toggleInfJump(true) end
end)

print("H2K Menu loaded - Android KRNL (Kill Aura | TP Camp | Speed | InfJump | InstaOpen)")