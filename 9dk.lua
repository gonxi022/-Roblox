-- H2K BLOX FRUITS MOD MENU COMPLETO
-- Kill Aura, Auto Farm, Speed, Infinite Jump
-- Compatible Android Krnl - By H2K

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Fast Attack System del script original
local CombatFramework = require(LocalPlayer.PlayerScripts:WaitForChild("CombatFramework"))
local CombatFrameworkR = getupvalues(CombatFramework)[2]

-- Estados del mod
local ModState = {
    killAura = false,
    autoFarm = false,
    speed = false,
    infiniteJump = false,
    fastAttack = true,
    isOpen = false,
    speedValue = 100
}

local Connections = {}
local originalWalkSpeed = Humanoid.WalkSpeed

-- Limpiar GUI anterior
pcall(function()
    if LocalPlayer.PlayerGui:FindFirstChild("H2KBloxFruits") then
        LocalPlayer.PlayerGui:FindFirstChild("H2KBloxFruits"):Destroy()
    end
end)

-- Fast Attack Functions del script original
local function getAllBladeHits(size)
    local hits = {}
    local enemies = Workspace.Enemies:GetChildren()
    for i = 1, #enemies do
        local enemy = enemies[i]
        local humanoid = enemy:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.RootPart and humanoid.Health > 0 then
            local distance = (RootPart.Position - humanoid.RootPart.Position).Magnitude
            if distance < size + 5 then
                table.insert(hits, humanoid.RootPart)
            end
        end
    end
    return hits
end

local function getCurrentWeapon()
    local ac = CombatFrameworkR.activeController
    local ret = ac.blades[1]
    if not ret then
        return LocalPlayer.Character:FindFirstChildOfClass("Tool").Name
    end
    pcall(function()
        while ret.Parent ~= LocalPlayer.Character do
            ret = ret.Parent
        end
    end)
    if not ret then
        return LocalPlayer.Character:FindFirstChildOfClass("Tool").Name
    end
    return ret
end

local function attackFunction()
    local ac = CombatFrameworkR.activeController
    if ac and ac.equipped then
        local bladeHits = getAllBladeHits(60)
        if #bladeHits > 0 then
            local attack8 = debug.getupvalue(ac.attack, 5)
            local attack9 = debug.getupvalue(ac.attack, 6)
            local attack7 = debug.getupvalue(ac.attack, 4)
            local attack10 = debug.getupvalue(ac.attack, 7)
            local number12 = (attack8 * 798405 + attack7 * 727595) % attack9
            local number13 = attack7 * 798405
            
            number12 = (number12 * attack9 + number13) % 1099511627776
            attack8 = math.floor(number12 / attack9)
            attack7 = number12 - attack8 * attack9
            attack10 = attack10 + 1
            
            debug.setupvalue(ac.attack, 5, attack8)
            debug.setupvalue(ac.attack, 6, attack9)
            debug.setupvalue(ac.attack, 4, attack7)
            debug.setupvalue(ac.attack, 7, attack10)
            
            for k, v in pairs(ac.animator.anims.basic) do
                v:Play(0.01, 0.01, 0.01)
            end
            
            if LocalPlayer.Character:FindFirstChildOfClass("Tool") and ac.blades and ac.blades[1] then
                ReplicatedStorage.RigControllerEvent:FireServer("weaponChange", tostring(getCurrentWeapon()))
                ReplicatedStorage.Remotes.Validator:FireServer(math.floor(number12 / 1099511627776 * 16777215), attack10)
                ReplicatedStorage.RigControllerEvent:FireServer("hit", bladeHits, 2, "")
            end
        end
    end
end

-- Auto equipar mejor arma
local function equipBestWeapon()
    local bestWeapon = nil
    for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") and (tool.ToolTip == "Sword" or tool.ToolTip == "Melee" or tool.ToolTip == "Blox Fruit") then
            bestWeapon = tool
            break
        end
    end
    if bestWeapon and not LocalPlayer.Character:FindFirstChild(bestWeapon.Name) then
        Humanoid:EquipTool(bestWeapon)
    end
end

-- Kill Aura Function
local function toggleKillAura()
    ModState.killAura = not ModState.killAura
    
    if ModState.killAura then
        Connections.killAuraConnection = RunService.Heartbeat:Connect(function()
            if ModState.killAura then
                equipBestWeapon()
                attackFunction()
            end
        end)
    else
        if Connections.killAuraConnection then
            Connections.killAuraConnection:Disconnect()
            Connections.killAuraConnection = nil
        end
    end
end

-- Speed Function
local function toggleSpeed()
    ModState.speed = not ModState.speed
    
    if ModState.speed then
        Humanoid.WalkSpeed = ModState.speedValue
        Connections.speedConnection = Humanoid.Changed:Connect(function(property)
            if property == "WalkSpeed" and ModState.speed then
                Humanoid.WalkSpeed = ModState.speedValue
            end
        end)
    else
        if Connections.speedConnection then
            Connections.speedConnection:Disconnect()
            Connections.speedConnection = nil
        end
        Humanoid.WalkSpeed = originalWalkSpeed
    end
end

-- Infinite Jump Function
local function toggleInfiniteJump()
    ModState.infiniteJump = not ModState.infiniteJump
    
    if ModState.infiniteJump then
        Connections.jumpConnection = UserInputService.JumpRequest:Connect(function()
            if ModState.infiniteJump and Humanoid then
                Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if Connections.jumpConnection then
            Connections.jumpConnection:Disconnect()
            Connections.jumpConnection = nil
        end
    end
end

-- Auto Farm Function
local function toggleAutoFarm()
    ModState.autoFarm = not ModState.autoFarm
    
    if ModState.autoFarm then
        Connections.autoFarmConnection = RunService.Heartbeat:Connect(function()
            if ModState.autoFarm then
                -- Auto Haki
                if not LocalPlayer.Character:FindFirstChild("HasBuso") then
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso")
                end
                
                equipBestWeapon()
                
                -- Bring enemies closer
                for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                    if enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") then
                        if enemy.Humanoid.Health > 0 then
                            local distance = (RootPart.Position - enemy.HumanoidRootPart.Position).Magnitude
                            if distance <= 300 then
                                -- Bring mob
                                enemy.HumanoidRootPart.CFrame = RootPart.CFrame + Vector3.new(0, 0, -10)
                                enemy.Humanoid.WalkSpeed = 0
                                enemy.HumanoidRootPart.CanCollide = false
                                enemy.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                enemy.HumanoidRootPart.Transparency = 1
                                if enemy.Humanoid:FindFirstChild("Animator") then
                                    enemy.Humanoid.Animator:Destroy()
                                end
                            end
                        end
                    end
                end
                
                attackFunction()
            end
        end)
    else
        if Connections.autoFarmConnection then
            Connections.autoFarmConnection:Disconnect()
            Connections.autoFarmConnection = nil
        end
    end
end

-- Crear icono flotante H2K
local function createFloatingIcon()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "H2KIcon"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer.PlayerGui
    
    local iconFrame = Instance.new("Frame")
    iconFrame.Size = UDim2.new(0, 60, 0, 60)
    iconFrame.Position = UDim2.new(1, -80, 0, 20)
    iconFrame.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
    iconFrame.BorderSizePixel = 0
    iconFrame.Parent = screenGui
    
    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(1, 0)
    iconCorner.Parent = iconFrame
    
    local iconGradient = Instance.new("UIGradient")
    iconGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 140, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 100, 0))
    }
    iconGradient.Rotation = 45
    iconGradient.Parent = iconFrame
    
    local iconShadow = Instance.new("Frame")
    iconShadow.Size = UDim2.new(1, 8, 1, 8)
    iconShadow.Position = UDim2.new(0, -4, 0, -4)
    iconShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    iconShadow.BackgroundTransparency = 0.7
    iconShadow.ZIndex = iconFrame.ZIndex - 1
    iconShadow.Parent = iconFrame
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(1, 0)
    shadowCorner.Parent = iconShadow
    
    local iconText = Instance.new("TextLabel")
    iconText.Size = UDim2.new(1, 0, 1, 0)
    iconText.BackgroundTransparency = 1
    iconText.Text = "H2K"
    iconText.TextColor3 = Color3.fromRGB(255, 255, 255)
    iconText.TextSize = 18
    iconText.Font = Enum.Font.GothamBold
    iconText.TextStrokeTransparency = 0
    iconText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    iconText.Parent = iconFrame
    
    local iconButton = Instance.new("TextButton")
    iconButton.Size = UDim2.new(1, 0, 1, 0)
    iconButton.BackgroundTransparency = 1
    iconButton.Text = ""
    iconButton.Parent = iconFrame
    
    return {
        gui = screenGui,
        frame = iconFrame,
        button = iconButton
    }
end

-- Crear mod menu principal
local function createModMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "H2KBloxFruits"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer.PlayerGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 350, 0, 450)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = screenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 15)
    mainCorner.Parent = mainFrame
    
    local shadow = Instance.new("Frame")
    shadow.Size = UDim2.new(1, 12, 1, 12)
    shadow.Position = UDim2.new(0, -6, 0, -6)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.8
    shadow.ZIndex = mainFrame.ZIndex - 1
    shadow.Parent = mainFrame
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 21)
    shadowCorner.Parent = shadow
    
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 15)
    headerCorner.Parent = header
    
    local headerGradient = Instance.new("UIGradient")
    headerGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 140, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 100, 0))
    }
    headerGradient.Rotation = 45
    headerGradient.Parent = header
    
    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(0, 60, 1, 0)
    logo.Position = UDim2.new(0, 15, 0, 0)
    logo.BackgroundTransparency = 1
    logo.Text = "H2K"
    logo.TextColor3 = Color3.fromRGB(255, 255, 255)
    logo.TextSize = 22
    logo.Font = Enum.Font.GothamBold
    logo.TextStrokeTransparency = 0
    logo.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    logo.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -120, 1, 0)
    title.Position = UDim2.new(0, 80, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Blox Fruits"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    title.Font = Enum.Font.Gotham
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -45, 0, 7.5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 20
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = header
    
    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(0, 8)
    closeBtnCorner.Parent = closeBtn
    
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -20, 1, -60)
    content.Position = UDim2.new(0, 10, 0, 55)
    content.BackgroundTransparency = 1
    content.Parent = mainFrame
    
    -- Kill Aura Section
    local killAuraSection = Instance.new("Frame")
    killAuraSection.Size = UDim2.new(1, 0, 0, 60)
    killAuraSection.Position = UDim2.new(0, 0, 0, 0)
    killAuraSection.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    killAuraSection.BorderSizePixel = 0
    killAuraSection.Parent = content
    
    local killAuraCorner = Instance.new("UICorner")
    killAuraCorner.CornerRadius = UDim.new(0, 10)
    killAuraCorner.Parent = killAuraSection
    
    local killAuraLabel = Instance.new("TextLabel")
    killAuraLabel.Size = UDim2.new(1, -80, 1, 0)
    killAuraLabel.Position = UDim2.new(0, 15, 0, 0)
    killAuraLabel.BackgroundTransparency = 1
    killAuraLabel.Text = "Kill Aura\nAtaca todos los enemigos"
    killAuraLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    killAuraLabel.TextSize = 14
    killAuraLabel.Font = Enum.Font.Gotham
    killAuraLabel.TextXAlignment = Enum.TextXAlignment.Left
    killAuraLabel.Parent = killAuraSection
    
    local killAuraToggle = Instance.new("TextButton")
    killAuraToggle.Size = UDim2.new(0, 60, 0, 30)
    killAuraToggle.Position = UDim2.new(1, -70, 0.5, -15)
    killAuraToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    killAuraToggle.Text = "OFF"
    killAuraToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    killAuraToggle.TextSize = 12
    killAuraToggle.Font = Enum.Font.GothamBold
    killAuraToggle.Parent = killAuraSection
    
    local killAuraToggleCorner = Instance.new("UICorner")
    killAuraToggleCorner.CornerRadius = UDim.new(0, 8)
    killAuraToggleCorner.Parent = killAuraToggle
    
    -- Auto Farm Section
    local autoFarmSection = Instance.new("Frame")
    autoFarmSection.Size = UDim2.new(1, 0, 0, 60)
    autoFarmSection.Position = UDim2.new(0, 0, 0, 70)
    autoFarmSection.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    autoFarmSection.BorderSizePixel = 0
    autoFarmSection.Parent = content
    
    local autoFarmCorner = Instance.new("UICorner")
    autoFarmCorner.CornerRadius = UDim.new(0, 10)
    autoFarmCorner.Parent = autoFarmSection
    
    local autoFarmLabel = Instance.new("TextLabel")
    autoFarmLabel.Size = UDim2.new(1, -80, 1, 0)
    autoFarmLabel.Position = UDim2.new(0, 15, 0, 0)
    autoFarmLabel.BackgroundTransparency = 1
    autoFarmLabel.Text = "Auto Farm\nFarm automatico con haki"
    autoFarmLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    autoFarmLabel.TextSize = 14
    autoFarmLabel.Font = Enum.Font.Gotham
    autoFarmLabel.TextXAlignment = Enum.TextXAlignment.Left
    autoFarmLabel.Parent = autoFarmSection
    
    local autoFarmToggle = Instance.new("TextButton")
    autoFarmToggle.Size = UDim2.new(0, 60, 0, 30)
    autoFarmToggle.Position = UDim2.new(1, -70, 0.5, -15)
    autoFarmToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    autoFarmToggle.Text = "OFF"
    autoFarmToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    autoFarmToggle.TextSize = 12
    autoFarmToggle.Font = Enum.Font.GothamBold
    autoFarmToggle.Parent = autoFarmSection
    
    local autoFarmToggleCorner = Instance.new("UICorner")
    autoFarmToggleCorner.CornerRadius = UDim.new(0, 8)
    autoFarmToggleCorner.Parent = autoFarmToggle
    
    -- Speed Section
    local speedSection = Instance.new("Frame")
    speedSection.Size = UDim2.new(1, 0, 0, 100)
    speedSection.Position = UDim2.new(0, 0, 0, 140)
    speedSection.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    speedSection.BorderSizePixel = 0
    speedSection.Parent = content
    
    local speedCorner = Instance.new("UICorner")
    speedCorner.CornerRadius = UDim.new(0, 10)
    speedCorner.Parent = speedSection
    
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(1, -80, 0, 30)
    speedLabel.Position = UDim2.new(0, 15, 0, 5)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Speed Hack"
    speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedLabel.TextSize = 14
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Parent = speedSection
    
    local speedToggle = Instance.new("TextButton")
    speedToggle.Size = UDim2.new(0, 60, 0, 25)
    speedToggle.Position = UDim2.new(1, -70, 0, 7.5)
    speedToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    speedToggle.Text = "OFF"
    speedToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedToggle.TextSize = 12
    speedToggle.Font = Enum.Font.GothamBold
    speedToggle.Parent = speedSection
    
    local speedToggleCorner = Instance.new("UICorner")
    speedToggleCorner.CornerRadius = UDim.new(0, 6)
    speedToggleCorner.Parent = speedToggle
    
    -- Speed Slider
    local speedSliderFrame = Instance.new("Frame")
    speedSliderFrame.Size = UDim2.new(1, -30, 0, 35)
    speedSliderFrame.Position = UDim2.new(0, 15, 0, 40)
    speedSliderFrame.BackgroundTransparency = 1
    speedSliderFrame.Parent = speedSection
    
    local speedValueLabel = Instance.new("TextLabel")
    speedValueLabel.Size = UDim2.new(1, 0, 0, 15)
    speedValueLabel.BackgroundTransparency = 1
    speedValueLabel.Text = "Velocidad: 100"
    speedValueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    speedValueLabel.TextSize = 12
    speedValueLabel.Font = Enum.Font.Gotham
    speedValueLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedValueLabel.Parent = speedSliderFrame
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, 0, 0, 8)
    sliderBg.Position = UDim2.new(0, 0, 1, -8)
    sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = speedSliderFrame
    
    local sliderBgCorner = Instance.new("UICorner")
    sliderBgCorner.CornerRadius = UDim.new(0, 4)
    sliderBgCorner.Parent = sliderBg
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(0.33, 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBg
    
    local sliderFillCorner = Instance.new("UICorner")
    sliderFillCorner.CornerRadius = UDim.new(0, 4)
    sliderFillCorner.Parent = sliderFill
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(0, 16, 0, 16)
    sliderButton.Position = UDim2.new(0.33, -8, 0.5, -8)
    sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderButton.Text = ""
    sliderButton.Parent = sliderBg
    
    local sliderButtonCorner = Instance.new("UICorner")
    sliderButtonCorner.CornerRadius = UDim.new(1, 0)
    sliderButtonCorner.Parent = sliderButton
    
    -- Quick Speed Buttons
    local speedButtonsFrame = Instance.new("Frame")
    speedButtonsFrame.Size = UDim2.new(1, -30, 0, 20)
    speedButtonsFrame.Position = UDim2.new(0, 15, 0, 75)
    speedButtonsFrame.BackgroundTransparency = 1
    speedButtonsFrame.Parent = speedSection
    
    local speedButtons = {
        {text = "50", value = 50},
        {text = "100", value = 100},
        {text = "200", value = 200},
        {text = "300", value = 300}
    }
    
    for i, btnData in ipairs(speedButtons) do
        local speedBtn = Instance.new("TextButton")
        speedBtn.Size = UDim2.new(0.23, 0, 1, 0)
        speedBtn.Position = UDim2.new((i-1) * 0.25 + 0.01, 0, 0, 0)
        speedBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
        speedBtn.Text = btnData.text
        speedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        speedBtn.TextSize = 10
        speedBtn.Font = Enum.Font.GothamBold
        speedBtn.Parent = speedButtonsFrame
        
        local speedBtnCorner = Instance.new("UICorner")
        speedBtnCorner.CornerRadius = UDim.new(0, 4)
        speedBtnCorner.Parent = speedBtn
        
        speedBtn.MouseButton1Click:Connect(function()
            ModState.speedValue = btnData.value
            speedValueLabel.Text = "Velocidad: " .. btnData.value
            local percentage = btnData.value / 300
            sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
            sliderButton.Position = UDim2.new(percentage, -8, 0.5, -8)
            
            if ModState.speed then
                Humanoid.WalkSpeed = btnData.value
            end
        end)
    end
    
    -- Infinite Jump Section
    local jumpSection = Instance.new("Frame")
    jumpSection.Size = UDim2.new(1, 0, 0, 60)
    jumpSection.Position = UDim2.new(0, 0, 0, 250)
    jumpSection.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    jumpSection.BorderSizePixel = 0
    jumpSection.Parent = content
    
    local jumpCorner = Instance.new("UICorner")
    jumpCorner.CornerRadius = UDim.new(0, 10)
    jumpCorner.Parent = jumpSection
    
    local jumpLabel = Instance.new("TextLabel")
    jumpLabel.Size = UDim2.new(1, -80, 1, 0)
    jumpLabel.Position = UDim2.new(0, 15, 0, 0)
    jumpLabel.BackgroundTransparency = 1
    jumpLabel.Text = "Infinite Jump\nSalto infinito"
    jumpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    jumpLabel.TextSize = 14
    jumpLabel.Font = Enum.Font.Gotham
    jumpLabel.TextXAlignment = Enum.TextXAlignment.Left
    jumpLabel.Parent = jumpSection
    
    local jumpToggle = Instance.new("TextButton")
    jumpToggle.Size = UDim2.new(0, 60, 0, 30)
    jumpToggle.Position = UDim2.new(1, -70, 0.5, -15)
    jumpToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    jumpToggle.Text = "OFF"
    jumpToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    jumpToggle.TextSize = 12
    jumpToggle.Font = Enum.Font.GothamBold
    jumpToggle.Parent = jumpSection
    
    local jumpToggleCorner = Instance.new("UICorner")
    jumpToggleCorner.CornerRadius = UDim.new(0, 8)
    jumpToggleCorner.Parent = jumpToggle
    
    -- Info Section
    local infoSection = Instance.new("Frame")
    infoSection.Size = UDim2.new(1, 0, 0, 60)
    infoSection.Position = UDim2.new(0, 0, 0, 320)
    infoSection.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    infoSection.BorderSizePixel = 0
    infoSection.Parent = content
    
    local infoCorner = Instance.new("UICorner")
    infoCorner.CornerRadius = UDim.new(0, 10)
    infoCorner.Parent = infoSection
    
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, -20, 1, 0)
    infoLabel.Position = UDim2.new(0, 10, 0, 0)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "H2K Blox Fruits Mod Menu\nCompatible Android Krnl - Version 2.0"
    infoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    infoLabel.TextSize = 12
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextXAlignment = Enum.TextXAlignment.Center
    infoLabel.Parent = infoSection
    
    -- Speed Slider Logic
    local dragging = false
    
    sliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouse = LocalPlayer:GetMouse()
            local relativeX = mouse.X - sliderBg.AbsolutePosition.X
            local percentage = math.clamp(relativeX / sliderBg.AbsoluteSize.X, 0, 1)
            
            sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
            sliderButton.Position = UDim2.new(percentage, -8, 0.5, -8)
            
            ModState.speedValue = math.floor(percentage * 300)
            speedValueLabel.Text = "Velocidad: " .. ModState.speedValue
            
            if ModState.speed then
                Humanoid.WalkSpeed = ModState.speedValue
            end
        end
    end)
    
    -- Event Connections
    killAuraToggle.MouseButton1Click:Connect(function()
        toggleKillAura()
        if ModState.killAura then
            killAuraToggle.Text = "ON"
            killAuraToggle.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
        else
            killAuraToggle.Text = "OFF"
            killAuraToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        end
    end)
    
    autoFarmToggle.MouseButton1Click:Connect(function()
        toggleAutoFarm()
        if ModState.autoFarm then
            autoFarmToggle.Text = "ON"
            autoFarmToggle.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
        else
            autoFarmToggle.Text = "OFF"
            autoFarmToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        end
    end)
    
    speedToggle.MouseButton1Click:Connect(function()
        toggleSpeed()
        if ModState.speed then
            speedToggle.Text = "ON"
            speedToggle.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
        else
            speedToggle.Text = "OFF"
            speedToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        end
    end)
    
    jumpToggle.MouseButton1Click:Connect(function()
        toggleInfiniteJump()
        if ModState.infiniteJump then
            jumpToggle.Text = "ON"
            jumpToggle.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
        else
            jumpToggle.Text = "OFF"
            jumpToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        end
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        ModState.isOpen = false
        mainFrame.Visible = false
    end)
    
    return {
        gui = screenGui,
        frame = mainFrame,
        toggleVisibility = function()
            ModState.isOpen = not ModState.isOpen
            mainFrame.Visible = ModState.isOpen
        end
    }
end

-- Hacer el GUI draggable
local function makeDraggable(frame)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Character Respawn Handler
local function onCharacterAdded(character)
    Character = character
    Humanoid = character:WaitForChild("Humanoid")
    RootPart = character:WaitForChild("HumanoidRootPart")
    originalWalkSpeed = Humanoid.WalkSpeed
    
    -- Reactivar funciones si estaban activas
    if ModState.speed then
        wait(1)
        Humanoid.WalkSpeed = ModState.speedValue
    end
end

LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

-- Fast Attack Loop
spawn(function()
    while wait() do
        if ModState.fastAttack then
            pcall(function()
                attackFunction()
            end)
        end
    end
end)

-- Crear y configurar GUI
local floatingIcon = createFloatingIcon()
local modMenu = createModMenu()

-- Hacer draggable el header
makeDraggable(modMenu.frame:FindFirstChild("Frame"))

-- Conectar icono flotante
floatingIcon.button.MouseButton1Click:Connect(function()
    modMenu.toggleVisibility()
end)

-- Auto equipar arma al inicio
equipBestWeapon()

-- Cleanup al salir
game:GetService("Players").PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        for _, connection in pairs(Connections) do
            if connection then
                connection:Disconnect()
            end
        end
    end
end)

print("H2K Blox Fruits Mod Menu Cargado!")
print("- Kill Aura: Ataca automaticamente")
print("- Auto Farm: Farm con haki automatico")  
print("- Speed Hack: Velocidad personalizable")
print("- Infinite Jump: Salto infinito")
print("Compatible con Android Krnl")