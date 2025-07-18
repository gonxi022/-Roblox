-- Ultra OP Gem Farmer sin cooldown para Legends of Speed
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local tpEnabled = false

local function getAllGems()
    local gems = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("gem") then
            table.insert(gems, obj)
        end
    end
    return gems
end

local function doTeleports()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local gems = getAllGems()
    for _, gem in ipairs(gems) do
        hrp.CFrame = CFrame.new(gem.Position + Vector3.new(0, 2.5, 0))
        -- Pequeña pausa para evitar saturar demasiado (ajusta si quieres)
        task.wait(0.01)
    end
end

RunService.Stepped:Connect(function()
    if tpEnabled then
        pcall(doTeleports)
    end
end)

local function createUI()
    local oldGui = PlayerGui:FindFirstChild("LegendGemUI")
    if oldGui then oldGui:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "LegendGemUI"
    gui.ResetOnSpawn = false
    gui.Parent = PlayerGui

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 240, 0, 60)
    btn.Position = UDim2.new(0.03, 0, 0.78, 0)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextScaled = true
    btn.BorderSizePixel = 0
    btn.BackgroundTransparency = 0.15
    btn.Text = "🔁 GEM FARM OFF"
    btn.Parent = gui

    btn.MouseButton1Click:Connect(function()
        tpEnabled = not tpEnabled
        btn.Text = tpEnabled and "🔁 GEM FARM ON" or "🔁 GEM FARM OFF"
    end)
    btn.TouchTap:Connect(btn.MouseButton1Click)

    Players.LocalPlayer.CharacterAdded:Connect(function()
        wait(1)
        createUI()
    end)
end

createUI()
