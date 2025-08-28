-- H2K 99 Nights in the Forest Script - ANDROID OPTIMIZED
-- Funcional para KRNL Android
-- By H2K

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Limpiar scripts anteriores
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

-- Funciones principales
local function findCampfire()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") and obj.Name:lower():find("campfire") then
            return obj
        elseif obj:IsA("Model") and obj.Name:lower():find("campfire") then
            return obj:FindFirstChild("Part") or obj:FindFirstChildOfClass("Part")
        end
    end
    
    -- Buscar por spawn del jugador
    local spawn = Workspace:FindFirstChild("SpawnLocation")
    if spawn then return spawn end
    
    return Vector3.new(0, 50, 0) -- Posición por defecto
end

local function isAnimalOrCultist(obj)
    if not obj or not obj.Parent then return false end
    
    local name = obj.Name:lower()
    local parentName = obj.Parent.Name:lower()
    
    -- Animales del juego
    local animalNames = {
        "wolf", "bear", "rabbit", "bunny", "deer", "boar", "pig",
        "animal", "mob", "hostile", "creature"
    }
    
    -- Cultistas
    local cultistNames = {
        "cultist", "enemy", "npc", "bandit", "raider"
    }
    
    local allTargets = {}
    for _, v in pairs(animalNames) do table.insert(allTargets, v) end
    for _, v in pairs(cultistNames) do table.insert(allTargets, v) end
    
    for _, target in pairs(allTargets) do
        if name:find(target) or parentName:find(target) then
            return true
        end
    end
    
    -- Verificar si tiene Humanoid (cultistas) pero no es jugador
    if obj:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(obj) then
        return true
    end
    
    return false
end

local function performKillAura()
    if not ScriptState.killAura then return end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local rootPart = character.HumanoidRootPart
    local tool = character:FindFirstChildOfClass("Tool")
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if isAnimalOrCultist(obj) then
            local targetRoot = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChildOfClass("Part")
            local targetHuman = obj:FindFirstChildOfClass("Humanoid")
            
            if targetRoot and targetHuman and targetHuman.Health > 0 then
                local distance = (rootPart.Position - targetRoot.Position).Magnitude
                
                if distance <= ScriptState.killAuraRange then
                    pcall(function()
                        -- Usar herramienta equipada
                        if tool then
                            tool:Activate()
                            
                            -- Disparar RemoteEvents del tool
                            for _, remote in pairs(tool:GetDescendants()) do
                                if remote:IsA("RemoteEvent") then
                                    remote:FireServer(targetRoot, targetHuman, 999)
                                end
                            end
                        end
                        
                        -- Daño directo
                        targetHuman:TakeDamage(999)
                        targetHuman.Health = 0
                        
                        -- Buscar RemoteEvents del juego para combate
                        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                            if remote:IsA("RemoteEvent") then
                                local remoteName = remote.Name:lower()
                                if remoteName:find("damage") or remoteName:find("hit") or 
                                   remoteName:find("attack") or remoteName:find("combat") then
                                    remote:FireServer(obj, 999)
                                    remote:FireServer(targetRoot, targetHuman, 999)
                                end
                            end
                        end
                    end)
                end
            end
        end
    end
end

local function toggleSpeed()
    ScriptState.speed = not ScriptState.speed
    
    if ScriptState.speed then
        ScriptState.currentSpeed = 100
        connections.speed = RunService.Heartbeat:Connect(function()
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid.WalkSpeed = ScriptState.currentSpeed
            end
        end)
    else
        ScriptState.currentSpeed = 16
        if connections.speed then
            connections.speed:Disconnect()
        end
        
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.WalkSpeed = 16
        end
    end
end

local function toggleInfiniteJump()
    ScriptState.infiniteJump = not ScriptState.infiniteJump
    
    if ScriptState.infiniteJump then
        connections.jump = UserInputService.JumpRequest:Connect(function()
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if connections.jump then
            connections.jump:Disconnect()
        end
    end
end

local function teleportToCamp()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local campfire = findCampfire()
    if campfire then
        if typeof(campfire) == "Vector3" then
            character.HumanoidRootPart.CFrame = CFrame.new(campfire)
        else
            character.HumanoidRootPart.CFrame = campfire.CFrame + Vector3.new(0, 5, 0)
        end
    end
end

local function instaOpenChests()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local parent = obj.Parent
            if parent and parent.Name:lower():find("chest") then
                obj.HoldDuration = 0
                obj.MaxActivationDistance = 50
                fireproximityprompt(obj)
            end
        end
    end
end

-- Crear GUI
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "H2K_99Nights"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = PlayerGui
    
    -- Frame principal (minimizable)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 320, 0, 420)
    mainFrame.Position = UDim2.new(0.5, -160, 0.5, -210)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = mainFrame
    
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(0, 200, 255)
    mainStroke.Thickness = 2
    mainStroke.Parent = mainFrame
    
    -- Header con logo H2K
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 12)
    headerCorner.Parent = header
    
    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(0, 60, 0, 35)
    logo.Position = UDim2.new(0, 10, 0, 7)
    logo.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    logo.Text = "H2K"
    logo.TextColor3 = Color3.fromRGB(0, 200, 255)
    logo.TextScaled = true
    logo.Font = Enum.Font.GothamBold
    logo.Parent = header
    
    local logoCorner = Instance.new("UICorner")
    logoCorner.CornerRadius = UDim.new(0, 8)
    logoCorner.Parent = logo
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -140, 1, 0)
    title.Position = UDim2.new(0, 80, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "99 NIGHTS FOREST"
    title.TextColor3 = Color3.fromRGB(0, 0, 0)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = header
    
    -- Botón minimizar
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    minimizeBtn.Position = UDim2.new(1, -40, 0, 10)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    minimizeBtn.Text = "-"
    minimizeBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    minimizeBtn.TextScaled = true
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.Parent = header
    
    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 15)
    minimizeCorner.Parent = minimizeBtn
    
    -- Contenido
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -20, 1, -70)
    content.Position = UDim2.new(0, 10, 0, 60)
    content.BackgroundTransparency = 1
    content.Parent = mainFrame
    
    -- Función para crear botones
    local function createButton(text, pos, size, color, parent)
        local btn = Instance.new("TextButton")
        btn.Size = size
        btn.Position = pos
        btn.BackgroundColor3 = color
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextScaled = true
        btn.Font = Enum.Font.Gotham
        btn.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = btn
        
        return btn
    end
    
    -- Botones principales
    local speedBtn = createButton("SPEED: OFF", UDim2.new(0, 10, 0, 20), UDim2.new(0, 135, 0, 40), Color3.fromRGB(50, 150, 50), content)
    local jumpBtn = createButton("INF JUMP: OFF", UDim2.new(0, 155, 0, 20), UDim2.new(0, 135, 0, 40), Color3.fromRGB(100, 50, 150), content)
    
    local killAuraBtn = createButton("KILL AURA: OFF", UDim2.new(0, 10, 0, 80), UDim2.new(0, 200, 0, 40), Color3.fromRGB(200, 50, 50), content)
    
    -- Control de rango
    local rangeLabel = Instance.new("TextLabel")
    rangeLabel.Size = UDim2.new(0, 80, 0, 30)
    rangeLabel.Position = UDim2.new(0, 220, 0, 85)
    rangeLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    rangeLabel.Text = "Range: 80"
    rangeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    rangeLabel.TextScaled = true
    rangeLabel.Font = Enum.Font.Gotham
    rangeLabel.Parent = content
    
    local rangeLabelCorner = Instance.new("UICorner")
    rangeLabelCorner.CornerRadius = UDim.new(0, 6)
    rangeLabelCorner.Parent = rangeLabel
    
    -- Botones de utilidades
    local tpCampBtn = createButton("TP TO CAMP", UDim2.new(0, 10, 0, 140), UDim2.new(0, 135, 0, 40), Color3.fromRGB(255, 140, 0), content)
    local openChestBtn = createButton("INSTA CHESTS", UDim2.new(0, 155, 0, 140), UDim2.new(0, 135, 0, 40), Color3.fromRGB(150, 100, 200), content)
    
    -- Info de targets
    local targetInfo = Instance.new("TextLabel")
    targetInfo.Size = UDim2.new(1, -20, 0, 30)
    targetInfo.Position = UDim2.new(0, 10, 0, 200)
    targetInfo.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    targetInfo.Text = "Targets in range: 0 | Animals & Cultists"
    targetInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
    targetInfo.TextSize = 12
    targetInfo.Font = Enum.Font.Gotham
    targetInfo.Parent = content
    
    local targetCorner = Instance.new("UICorner")
    targetCorner.CornerRadius = UDim.new(0, 6)
    targetCorner.Parent = targetInfo
    
    -- Credits
    local credits = Instance.new("TextLabel")
    credits.Size = UDim2.new(1, -20, 0, 40)
    credits.Position = UDim2.new(0, 10, 0, 300)
    credits.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    credits.Text = "BY H2K\nAndroid KRNL Optimized"
    credits.TextColor3 = Color3.fromRGB(0, 200, 255)
    credits.TextSize = 14
    credits.Font = Enum.Font.GothamBold
    credits.Parent = content
    
    local creditsCorner = Instance.new("UICorner")
    creditsCorner.CornerRadius = UDim.new(0, 8)
    creditsCorner.Parent = credits
    
    -- Ícono minimizado
    local miniIcon = Instance.new("Frame")
    miniIcon.Name = "MiniIcon"
    miniIcon.Size = UDim2.new(0, 60, 0, 60)
    miniIcon.Position = UDim2.new(0, 30, 0, 100)
    miniIcon.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    miniIcon.BorderSizePixel = 0
    miniIcon.Active = true
    miniIcon.Draggable = true
    miniIcon.Visible = false
    miniIcon.Parent = screenGui
    
    local miniCorner = Instance.new("UICorner")
    miniCorner.CornerRadius = UDim.new(0, 30)
    miniCorner.Parent = miniIcon
    
    local miniText = Instance.new("TextLabel")
    miniText.Size = UDim2.new(1, 0, 1, 0)
    miniText.BackgroundTransparency = 1
    miniText.Text = "H2K"
    miniText.TextColor3 = Color3.fromRGB(0, 0, 0)
    miniText.TextScaled = true
    miniText.Font = Enum.Font.GothamBold
    miniText.Parent = miniIcon
    
    local miniButton = Instance.new("TextButton")
    miniButton.Size = UDim2.new(1, 0, 1, 0)
    miniButton.BackgroundTransparency = 1
    miniButton.Text = ""
    miniButton.Parent = miniIcon
    
    -- EVENTOS
    minimizeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        miniIcon.Visible = true
        ScriptState.isOpen = false
    end)
    
    miniButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = true
        miniIcon.Visible = false
        ScriptState.isOpen = true
    end)
    
    speedBtn.MouseButton1Click:Connect(function()
        toggleSpeed()
        speedBtn.Text = "SPEED: " .. (ScriptState.speed and "ON" or "OFF")
        speedBtn.BackgroundColor3 = ScriptState.speed and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(50, 150, 50)
    end)
    
    jumpBtn.MouseButton1Click:Connect(function()
        toggleInfiniteJump()
        jumpBtn.Text = "INF JUMP: " .. (ScriptState.infiniteJump and "ON" or "OFF")
        jumpBtn.BackgroundColor3 = ScriptState.infiniteJump and Color3.fromRGB(150, 0, 200) or Color3.fromRGB(100, 50, 150)
    end)
    
    killAuraBtn.MouseButton1Click:Connect(function()
        ScriptState.killAura = not ScriptState.killAura
        killAuraBtn.Text = "KILL AURA: " .. (ScriptState.killAura and "ON" or "OFF")
        killAuraBtn.BackgroundColor3 = ScriptState.killAura and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(200, 50, 50)
    end)
    
    tpCampBtn.MouseButton1Click:Connect(function()
        teleportToCamp()
    end)
    
    openChestBtn.MouseButton1Click:Connect(function()
        instaOpenChests()
    end)
    
    -- Loop para contar targets
    spawn(function()
        while screenGui.Parent do
            if ScriptState.killAura and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local count = 0
                local rootPart = LocalPlayer.Character.HumanoidRootPart
                
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if isAnimalOrCultist(obj) then
                        local targetRoot = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChildOfClass("Part")
                        if targetRoot then
                            local distance = (rootPart.Position - targetRoot.Position).Magnitude
                            if distance <= ScriptState.killAuraRange then
                                count = count + 1
                            end
                        end
                    end
                end
                
                targetInfo.Text = "Targets in range: " .. count .. " | Animals & Cultists"
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

-- Controles táctiles para Android
UserInputService.TouchTapInWorld:Connect(function(position, processedByUI)
    if not processedByUI then
        local currentTime = tick()
        if currentTime - (lastTapTime or 0) < 0.5 then -- Doble tap
            if PlayerGui:FindFirstChild("H2K_99Nights") then
                local gui = PlayerGui.H2K_99Nights
                if gui.MiniIcon.Visible then
                    gui.MainFrame.Visible = true
                    gui.MiniIcon.Visible = false
                    ScriptState.isOpen = true
                else
                    gui.MainFrame.Visible = false
                    gui.MiniIcon.Visible = true
                    ScriptState.isOpen = false
                end
            end
        end
        lastTapTime = currentTime
    end
end)

-- Hotkeys adicionales
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.RightControl then
        if PlayerGui:FindFirstChild("H2K_99Nights") then
            local gui = PlayerGui.H2K_99Nights
            if gui.MiniIcon.Visible then
                gui.MainFrame.Visible = true
                gui.MiniIcon.Visible = false
                ScriptState.isOpen = true
            else
                gui.MainFrame.Visible = false
                gui.MiniIcon.Visible = true
                ScriptState.isOpen = false
            end
        end
    elseif input.KeyCode == Enum.KeyCode.LeftShift then
        toggleSpeed()
    elseif input.KeyCode == Enum.KeyCode.Space and ScriptState.infiniteJump then
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

print("H2K 99 Nights Forest Script loaded!")
print("Doble tap pantalla o Right Ctrl para abrir/cerrar")
print("Funciones: Speed, Infinite Jump, Kill Aura (80 range), TP Camp, Insta Chests")