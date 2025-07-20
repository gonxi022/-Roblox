-- Ultra OP Farm +600 Steps - Legends of Speed (Android Ready)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local flags = { farmSteps = false }

local function getChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function tpToOrb(orb)
    local char = getChar()
    if not char then return end
    local HRP = char:FindFirstChild("HumanoidRootPart")
    if HRP and orb and orb:IsA("BasePart") then
        HRP.CFrame = orb.CFrame + Vector3.new(0, 3, 0)
    end
end

spawn(function()
    while true do
        task.wait(0.1)
        if flags.farmSteps then
            local char = getChar()
            local HRP = char:FindFirstChild("HumanoidRootPart")
            if HRP then
                for _, orb in pairs(workspace:GetDescendants()) do
                    if orb:IsA("BasePart") and orb.Name:match("%+600") then
                        tpToOrb(orb)
                        task.wait(0.12)
                    end
                end
            end
        else
            task.wait(0.5)
        end
    end
end)

-- Menú táctil simple para Android

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local gui = Instance.new("ScreenGui", PlayerGui)
gui.Name = "UltraFarmMenu"
gui.ResetOnSpawn = false

local btn = Instance.new("TextButton", gui)
btn.Size = UDim2.new(0, 100, 0, 50)
btn.Position = UDim2.new(0, 20, 0, 20)
btn.BackgroundColor3 = Color3.new(0, 0, 0)
btn.TextColor3 = Color3.new(1, 1, 1)
btn.Text = "Farm +600 OFF"
btn.TextScaled = true

btn.MouseButton1Click:Connect(function()
    flags.farmSteps = not flags.farmSteps
    btn.Text = "Farm +600 " .. (flags.farmSteps and "ON" or "OFF")
end)

print("Script ultra OP listo, toca el botón para activar el farm +600")