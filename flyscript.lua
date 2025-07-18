local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local enabled = false
local lastValidPos = HumanoidRootPart.Position

-- Detecta si el jugador está tocando el suelo con raycast
local function isOnGround()
    local origin = HumanoidRootPart.Position
    local direction = Vector3.new(0, -5, 0)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {Character}
    params.FilterType = Enum.RaycastFilterType.Blacklist

    local result = workspace:Raycast(origin, direction, params)
    if result and result.Normal.Y > 0.7 then
        return true
    end
    return false
end

-- Mantiene colisión normal para pies y torso
local function maintainCollision()
    local onGround = isOnGround()
    for _, part in Character:GetDescendants() do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            if onGround and (part.Name == "LeftFoot" or part.Name == "RightFoot" or part.Name == "LowerTorso" or part.Name == "UpperTorso") then
                part.CanCollide = true
            else
                part.CanCollide = false
            end
        end
    end
end

-- Mueve suavemente el HumanoidRootPart hacia adelante atravesando paredes
local function teleportForward(step)
    local lookVector = HumanoidRootPart.CFrame.LookVector
    local newPos = HumanoidRootPart.Position + (lookVector * step)

    -- Opcional: puedes hacer un raycast para detectar obstáculos y saltar solo si hay pared
    -- Para simplificar, lo movemos siempre

    HumanoidRootPart.CFrame = HumanoidRootPart.CFrame:Lerp(CFrame.new(newPos, newPos + lookVector), 0.5)
end

-- Control principal para evitar pushback
local function onStepped()
    pcall(function()
        maintainCollision()

        local currentPos = HumanoidRootPart.Position
        local dist = (currentPos - lastValidPos).Magnitude

        if dist > 3 then
            -- Si nos empujaron para atrás, corregimos suavemente
            HumanoidRootPart.CFrame = HumanoidRootPart.CFrame:Lerp(CFrame.new(lastValidPos), 0.5)
        else
            lastValidPos = currentPos
            -- Avanzamos en micro saltos solo si está en el suelo
            if isOnGround() then
                teleportForward(0.5)
            end
        end
    end)
end

-- Botón para activar/desactivar
local button
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local function toggle()
    enabled = not enabled
    if enabled then
        Humanoid.PlatformStand = true
        Humanoid:ChangeState(Enum.HumanoidStateType.Physics)

        button.Text = "❌ Atravesar OFF"
        connection = RunService.Stepped:Connect(onStepped)
    else
        if connection then
            connection:Disconnect()
            connection = nil
        end
        Humanoid.PlatformStand = false
        Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)

        for _, part in Character:GetDescendants() do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end

        button.Text = "🧱 Atravesar ON"
    end
end

local function createButton()
    local gui = PlayerGui:FindFirstChild("BypassGui")
    if gui then gui:Destroy() end

    gui = Instance.new("ScreenGui")
    gui.Name = "BypassGui"
    gui.ResetOnSpawn = false
    gui.Parent = PlayerGui

    button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 180, 0, 50)
    button.Position = UDim2.new(0.05, 0, 0.8, 0)
    button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    button.TextColor3 = Color3.new(1,1,1)
    button.TextScaled = true
    button.BorderSizePixel = 0
    button.BackgroundTransparency = 0.2
    button.Text = "🧱 Atravesar ON"
    button.Parent = gui

    button.TouchTap:Connect(toggle)
    button.MouseButton1Click:Connect(toggle)
end

-- Respawn support
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    wait(1)
    if enabled then
        toggle()
        toggle()
    end
    createButton()
end)

createButton()
