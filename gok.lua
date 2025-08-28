-- H2K 99 Nights Forest Mod Menu - Android KRNL
-- By H2K
-- Funciona en Android KRNL, minimizable, todas opciones activables

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Limpiar GUIs anteriores
pcall(function()
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui.Name:find("H2K") then
            gui:Destroy()
        end
    end
end)

-- Estado del script
local ScriptState = {
    isOpen = false,
    speed = false,
    infiniteJump = false,
    killAura = false,
    killAuraRange = 80,
    currentSpeed = 16
}

local connections = {}

-- Función para identificar enemigos
local function isTarget(obj)
    if not obj or not obj.Parent then return false end
    local name = obj.Name:lower()
    local parentName = obj.Parent.Name:lower()
    local targetList = {"wolf","bear","rabbit","bunny","deer","boar","pig","alpha","cultist","enemy","npc","bandit","raider"}
    for _, t in pairs(targetList) do
        if name:find(t) or parentName:find(t) then
            -- Ignorar jugador local
            if Players:GetPlayerFromCharacter(obj) == LocalPlayer then
                return false
            end
            return true
        end
    end
    if obj:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(obj) then
        return true
    end
    return false
end

-- Kill Aura
local function performKillAura()
    if not ScriptState.killAura then return end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart
    local tool = char:FindFirstChildOfClass("Tool")
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if isTarget(obj) then
            local targetRoot = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChildOfClass("Part")
            local targetHum = obj:FindFirstChildOfClass("Humanoid")
            if targetRoot and targetHum and targetHum.Health > 0 then
                local dist = (root.Position - targetRoot.Position).Magnitude
                if dist <= ScriptState.killAuraRange then
                    pcall(function()
                        if tool then tool:Activate() end
                        -- Daño directo
                        targetHum:TakeDamage(999)
                        targetHum.Health = 0
                        -- RemoteEvents del juego
                        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                            if remote:IsA("RemoteEvent") then
                                local rn = remote.Name:lower()
                                if rn:find("damage") or rn:find("hit") or rn:find("attack") then
                                    remote:FireServer(obj, 999)
                                end
                            end
                        end
                    end)
                end
            end
        end
    end
end

-- Speed toggle
local function toggleSpeed()
    ScriptState.speed = not ScriptState.speed
    if ScriptState.speed then
        ScriptState.currentSpeed = 100
        connections.speed = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = ScriptState.currentSpeed
            end
        end)
    else
        if connections.speed then connections.speed:Disconnect() end
        ScriptState.currentSpeed = 16
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = 16
        end
    end
end

-- Infinite Jump toggle
local function toggleInfiniteJump()
    ScriptState.infiniteJump = not ScriptState.infiniteJump
    if ScriptState.infiniteJump then
        connections.jump = UserInputService.JumpRequest:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if connections.jump then connections.jump:Disconnect() end
    end
end

-- Teleport to Campfire
local function findCampfire()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") and obj.Name:lower():find("campfire") then return obj
        elseif obj:IsA("Model") and obj.Name:lower():find("campfire") then
            return obj:FindFirstChild("Part") or obj:FindFirstChildOfClass("Part")
        end
    end
    return Vector3.new(0,50,0)
end

local function teleportToCamp()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local camp = findCampfire()
    if typeof(camp) == "Vector3" then
        char.HumanoidRootPart.CFrame = CFrame.new(camp)
    else
        char.HumanoidRootPart.CFrame = camp.CFrame + Vector3.new(0,5,0)
    end
end

-- Insta Chests
local function instaOpenChests()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Parent and obj.Parent.Name:lower():find("chest") then
            obj.HoldDuration = 0
            obj.MaxActivationDistance = 50
            fireproximityprompt(obj)
        end
    end
end

-- Crear GUI minimizable
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "H2K_99Nights"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = PlayerGui

    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0,320,0,420)
    mainFrame.Position = UDim2.new(0.5,-160,0.5,-210)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20,20,30)
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0,12)
    local mainStroke = Instance.new("UIStroke", mainFrame)
    mainStroke.Color = Color3.fromRGB(0,200,255)
    mainStroke.Thickness = 2

    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1,0,0,50)
    header.BackgroundColor3 = Color3.fromRGB(0,200,255)
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    Instance.new("UICorner", header).CornerRadius = UDim.new(0,12)

    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(0,60,0,35)
    logo.Position = UDim2.new(0,10,0,7)
    logo.BackgroundColor3 = Color3.fromRGB(0,0,0)
    logo.Text = "H2K"
    logo.TextColor3 = Color3.fromRGB(0,200,255)
    logo.TextScaled = true
    logo.Font = Enum.Font.GothamBold
    logo.Parent = header
    Instance.new("UICorner", logo).CornerRadius = UDim.new(0,8)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,-140,1,0)
    title.Position = UDim2.new(0,80,0,0)
    title.BackgroundTransparency = 1
    title.Text = "99 NIGHTS FOREST"
    title.TextColor3 = Color3.fromRGB(0,0,0)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = header

    -- Minimize button
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0,30,0,30)
    minimizeBtn.Position = UDim2.new(1,-40,0,10)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(255,200,0)
    minimizeBtn.Text = "-"
    minimizeBtn.TextColor3 = Color3.fromRGB(0,0,0)
    minimizeBtn.TextScaled = true
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.Parent = header
    Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0,15)

    -- Content
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1,-20,1,-70)
    content.Position = UDim2.new(0,10,0,60)
    content.BackgroundTransparency = 1
    content.Parent = mainFrame

    local function createButton(text,pos,size,color,parent)
        local btn = Instance.new("TextButton")
        btn.Size = size
        btn.Position = pos
        btn.BackgroundColor3 = color
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.TextScaled = true
        btn.Font = Enum.Font.Gotham
        btn.Parent = parent
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
        return btn
    end

    -- Botones
    local speedBtn = createButton("SPEED: OFF", UDim2.new(0,10,0,20), UDim2.new(0,135,0,40), Color3.fromRGB(50,150,50), content)
    local jumpBtn = createButton("INF JUMP: OFF", UDim2.new(0,155,0,20), UDim2.new(0,135,0,40), Color3.fromRGB(100,50,150), content)
    local killAuraBtn = createButton("KILL AURA: OFF", UDim2.new(0,10,0,80), UDim2.new(0,200,0,40), Color3.fromRGB(200,50,50), content)
    local tpCampBtn = createButton("TP TO CAMP", UDim2.new(0,10,0,140), UDim2.new(0,135,0,40), Color3.fromRGB(255,140,0), content)
    local openChestBtn = createButton("INSTA CHESTS", UDim2.new(0,155,0,140), UDim2.new(0,135,0,40), Color3.fromRGB(150,100,200), content)

    local targetInfo = Instance.new("TextLabel")
    targetInfo.Size = UDim2.new(1,-20,0,30)
    targetInfo.Position = UDim2.new(0,10,0,200)
    targetInfo.BackgroundColor3 = Color3.fromRGB(30,30,40)
    targetInfo.Text = "Targets in range: 0 | Animals & Cultists"
    targetInfo.TextColor3 = Color3.fromRGB(200,200,200)
    targetInfo.TextSize = 12
    targetInfo.Font = Enum.Font.Gotham
    targetInfo.Parent = content
    Instance.new("UICorner", targetInfo).CornerRadius = UDim.new(0,6)

    local credits = Instance.new("TextLabel")
    credits.Size = UDim2.new(1,-20,0,40)
    credits.Position = UDim2.new(0,10,0,300)
    credits.BackgroundColor3 = Color3.fromRGB(25,25,35)
    credits.Text = "BY H2K\nAndroid KRNL"
    credits.TextColor3 = Color3.fromRGB(0,200,255)
    credits.TextSize = 14
    credits.Font = Enum.Font.GothamBold
    credits.Parent = content
    Instance.new("UICorner", credits).CornerRadius = UDim.new(0,8)

    -- Icono minimizado
    local miniIcon = Instance.new("Frame")
    miniIcon.Name = "MiniIcon"
    miniIcon.Size = UDim2.new(0,60,0,60)
    miniIcon.Position = UDim2.new(0,30,0,100)
    miniIcon.BackgroundColor3 = Color3.fromRGB(0,200,255)
    miniIcon.BorderSizePixel = 0
    miniIcon.Active = true
    miniIcon.Draggable = true
    miniIcon.Visible = false
    miniIcon.Parent = screenGui
    Instance.new("UICorner", miniIcon).CornerRadius = UDim.new(0,30)
    local miniText = Instance.new("TextLabel")
    miniText.Size = UDim2.new(1,0,1,0)
    miniText.BackgroundTransparency = 1
    miniText.Text = "H2K"
    miniText.TextColor3 = Color3.fromRGB(0,0,0)
    miniText.TextScaled = true
    miniText.Font = Enum.Font.GothamBold
    miniText.Parent = miniIcon
    local miniBtn = Instance.new("TextButton")
    miniBtn.Size = UDim2.new(1,0,1,0)
    miniBtn.BackgroundTransparency = 1
    miniBtn.Text = ""
    miniBtn.Parent = miniIcon

    -- Conectar eventos
    minimizeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        miniIcon.Visible = true
        ScriptState.isOpen = false
    end)
    miniBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = true
        miniIcon.Visible = false
        ScriptState.isOpen = true
    end)
    speedBtn.MouseButton1Click:Connect(function()
        toggleSpeed()
        speedBtn.Text = "SPEED: " .. (ScriptState.speed and "ON" or "OFF")
        speedBtn.BackgroundColor3 = ScriptState.speed and Color3.fromRGB(0,200,0) or Color3.fromRGB(50,150,50)
    end)
    jumpBtn.MouseButton1Click:Connect(function()
        toggleInfiniteJump()
        jumpBtn.Text = "INF JUMP: " .. (ScriptState.infiniteJump and "ON" or "OFF")
        jumpBtn.BackgroundColor3 = ScriptState.infiniteJump and Color3.fromRGB(150,0,200) or Color3.fromRGB(100,50,150)
    end)
    killAuraBtn.MouseButton1Click:Connect(function()
        ScriptState.killAura = not ScriptState.killAura
        killAuraBtn.Text = "KILL AURA: " .. (ScriptState.killAura and "ON" or "OFF")
        killAuraBtn.BackgroundColor3 = ScriptState.killAura and Color3.fromRGB(255,0,0) or Color3.fromRGB(200,50,50)
    end)
    tpCampBtn.MouseButton1Click:Connect(function()
        teleportToCamp()
    end)
    openChestBtn.MouseButton1Click:Connect(function()
        instaOpenChests()
    end)

    -- Contador de enemigos en rango
    spawn(function()
        while screenGui.Parent do
            if ScriptState.killAura and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local count = 0
                local root = LocalPlayer.Character.HumanoidRootPart
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if isTarget(obj) then
                        local targetRoot = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChildOfClass("Part")
                        if targetRoot and (root.Position - targetRoot.Position).Magnitude <= ScriptState.killAuraRange then
                            count = count + 1
                        end
                    end
                end
                targetInfo.Text = "Targets in range: "..count.." | Animals & Cultists"
            else
                targetInfo.Text = "Targets in range: 0 | Animals & Cultists"
            end
            wait(1)
        end
    end)

    return screenGui
end

-- Kill Aura loop
spawn(function()
    while wait(0.1) do
        performKillAura()
    end
end)

-- Inicializar GUI
createGUI()

print("H2K 99 Nights Forest Mod Menu loaded! Double tap screen or Right Ctrl to open/close.")