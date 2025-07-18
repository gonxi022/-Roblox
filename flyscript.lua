--[[
    Legends of Speed - Gem Farmer OP
    🧲 Sin magnetismo - Full TP rápido
    📱 Interfaz táctil + mouse
    ⚙️ Funciona en TODOS los mundos
    👨‍💻 Por: ChatGPT para Charito
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local tpEnabled = false
local TP_COOLDOWN = 0.3  -- Más rápido = más OP
local lastTP = 0

-- 🔍 Buscar todas las gemas visibles del juego
local function getAllGems()
    local gems = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("gem") then
            table.insert(gems, obj)
        end
    end
    return gems
end

-- ⚡ TP automático hacia varias gemas ordenadas por cercanía
local function doTeleports()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local gems = getAllGems()
    table.sort(gems, function(a, b)
        return (a.Position - hrp.Position).Magnitude < (b.Position - hrp.Position).Magnitude
    end)

    for i = 1, math.min(#gems, 5) do
        local gem = gems[i]
        if tick() - lastTP >= TP_COOLDOWN then
            hrp.CFrame = CFrame.new(gem.Position + Vector3.new(0, 2.5, 0))
            lastTP = tick()
        end
    end
end

-- 🔁 Loop de farmeo de gemas
RunService.Stepped:Connect(function()
    if tpEnabled then
        pcall(doTeleports)
    end
end)

-- 🧱 Crear botón táctil/mouse
local function createUI()
    local gui = PlayerGui:FindFirstChild("LegendGemUI")
    if gui then gui:Destroy() end

    gui = Instance.new("ScreenGui")
    gui.Name = "LegendGemUI"
    gui.ResetOnSpawn = false
    gui.Parent = PlayerGui

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 240, 0, 60)
    btn.Position = UDim2.new(0.03, 0, 0.78, 0)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.BorderSizePixel = 0
    btn.BackgroundTransparency = 0.15
    btn.Text = "🔁 GEM OP OFF"
    btn.Parent = gui

    local function toggleTP()
        tpEnabled = not tpEnabled
        btn.Text = tpEnabled and "🔁 GEM OP ON" or "🔁 GEM OP OFF"
    end

    btn.MouseButton1Click:Connect(toggleTP)
    btn.TouchTap:Connect(toggleTP)

    Players.LocalPlayer.CharacterAdded:Connect(function()
        wait(1)
        createUI()
    end)
end

-- ▶️ Iniciar interfaz al cargar
createUI()
