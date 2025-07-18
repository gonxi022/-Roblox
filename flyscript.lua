-- Configuración
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Ajustes personalizables
local COLLECTION_RADIUS = 30     -- aumentá si hay gemas más lejos
local TP_COOLDOWN = 1           -- segundos entre teleports
local MAGNET_SPEED = 50         -- studs por segundo al atraer gemas
local lastTP = 0
local magnetEnabled = false
local tpEnabled = false

-- Detectar gemas en el workspace
local function getGems()
    local gems = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:match("Gem") then
            table.insert(gems, obj)
        end
    end
    return gems
end

-- Teletransportarse a la gema más cercana
local function doTeleport()
    local gems = getGems()
    local closest, dist = nil, math.huge
    for _, gem in ipairs(gems) do
        local d = (gem.Position - HumanoidRootPart.Position).Magnitude
        if d < dist then
            closest, dist = gem, d
        end
    end
    if closest and tick() - lastTP >= TP_COOLDOWN then
        HumanoidRootPart.CFrame = CFrame.new(closest.Position + Vector3.new(0, 2, 0))
        lastTP = tick()
    end
end

-- Magnetismo: atraer gemas cercanas
local function doMagnet(dt)
    local gems = getGems()
    for _, gem in ipairs(gems) do
        local root = HumanoidRootPart.Position
        local dir = gem.Position - root
        local dist = dir.Magnitude
        if dist <= COLLECTION_RADIUS then
            local vel = dir.Unit * MAGNET_SPEED * dt
            gem.Velocity = vel
        end
    end
end

-- Loop principal
local function onStep(dt)
    if tpEnabled then
        doTeleport()
    end
    if magnetEnabled then
        doMagnet(dt)
    end
end

-- Crear UI interactivo
local function createUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "GemCollectorUI"
    gui.ResetOnSpawn = false
    gui.Parent = PlayerGui

    local function makeButton(y, txt, callback)
        local btn = Instance.new("TextButton", gui)
        btn.Size = UDim2.new(0, 200, 0, 50)
        btn.Position = UDim2.new(0.05, 0, y, 0)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Text = txt
        btn.TextScaled = true
        btn.BorderSizePixel = 0
        btn.BackgroundTransparency = 0.2
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    local tpBtn = makeButton(0.7, "🔁 TP GEM OFF", function()
        tpEnabled = not tpEnabled
        tpBtn.Text = tpEnabled and "🔁 TP GEM ON" or "🔁 TP GEM OFF"
    end)

    local magBtn = makeButton(0.8, "🧲 MAGNET OFF", function()
        magnetEnabled = not magnetEnabled
        magBtn.Text = magnetEnabled and "🧲 MAGNET ON" or "🧲 MAGNET OFF"
    end)
end

-- Reiniciar estado tras respawn y refrescar Personaje
Players.LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    wait(1)
end)

-- Iniciar
createUI()
RunService.Stepped:Connect(onStep)
