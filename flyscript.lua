local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local button = nil
local enabled = false
local bypassConnection
local lastPos = HumanoidRootPart.Position

-- Función para detectar si el jugador está en el suelo usando raycast
local function isOnGround()
    local rayOrigin = HumanoidRootPart.Position
    local rayDirection = Vector3.new(0, -5, 0)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

    local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    if raycastResult then
        local normal = raycastResult.Normal
        if normal.Y > 0.7 then
            return true
        end
    end
    return false
end

local function setCollision(state)
    local onGround = isOnGround()
    for _, part in Character:GetDescendants() do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            if state then
                -- Si está activado atravesar paredes:
                -- dejamos colisión solo para partes que tocan piso si estamos en suelo
                if onGround and (part.Name == "LeftFoot" or part.Name == "RightFoot" or part.Name == "LowerTorso" or part.Name == "UpperTorso") then
                    part.CanCollide = true
                else
                    part.CanCollide = false
                end
            else
                part.CanCollide = true
            end
        end
    end
end

local function forcePosition(newPos)
    local currentCFrame = HumanoidRootPart.CFrame
    local targetCFrame = CFrame.new(newPos)
    -- Lerp para suavizar la corrección y evitar saltos bruscos detectables por anticheat
    HumanoidRootPart.CFrame = currentCFrame:Lerp(targetCFrame, 0.5)
end

local function toggleBypass()
    enabled = not enabled

    if enabled then
        Humanoid.PlatformStand = true
        Humanoid:ChangeState(Enum.HumanoidStateType.Physics)

        bypassConnection = RunService.Stepped:Connect(function()
            pcall(function()
                setCollision(true)

                local currentPos = HumanoidRootPart.Position
                local distanceMoved = (currentPos - lastPos).Magnitude

                if distanceMoved > 3 then
                    -- Si el servidor nos reposiciona (por ejemplo, anticheat):
                    -- corregimos suavemente la posición para evitar ser empujados hacia atrás
                    forcePosition(lastPos)
                else
                    lastPos = currentPos
                end
            end)
        end)

        if button then button.Text = "❌ Atravesar OFF" end
    else
        if bypassConnection then
            bypassConnection:Disconnect()
            bypassConnection = nil
        end

        Humanoid.PlatformStand = false
        Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        setCollision(false)

        if button then button.Text = "🧱 Atravesar ON" end
    end
end

local function createButton()
    local gui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("SafeZoneBypassUI")
    if gui then gui:Destroy() end

    gui = Instance.new("ScreenGui")
    gui.Name = "SafeZoneBypassUI"
    gui.ResetOnSpawn = false
    gui.Parent = LocalPlayer.PlayerGui

    button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 180, 0, 50)
    button.Position = UDim2.new(0.05, 0, 0.8, 0)
    button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Text = "🧱 Atravesar ON"
    button.TextScaled = true
    button.BorderSizePixel = 0
    button.BackgroundTransparency = 0.2
    button.Parent = gui

    button.TouchTap:Connect(toggleBypass)
    -- También conectamos MouseButton1Click para compatibilidad en PC
    button.MouseButton1Click:Connect(toggleBypass)
end

-- Soporte respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    wait(1)
    if enabled then
        -- Si estaba activado, reactivar bypass
        toggleBypass()
        toggleBypass()
    end
    createButton()
end)

createButton()
