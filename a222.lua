-- Roblox Legends of Speed - Auto Farm Orbes y Pasos (Android Ready)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local flags = { farmAll = false }

local function getChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function tpTo(obj)
    local char = getChar()
    if not char then return end
    local HRP = char:FindFirstChild("HumanoidRootPart")
    if HRP and obj and obj:IsA("BasePart") then
        HRP.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
    end
end

local function isOrbOrStep(obj)
    -- Incluye orbes y pasos de cualquier cantidad
    local orbNames = {
        "Step", "Gem", "Orb", "Crystal", "Diamond", "Reward"
    }
    for _, word in ipairs(orbNames) do
        if obj.Name:lower():find(word:lower()) then
            return true
        end
    end
    -- Detectar nombres con "+" y números (ej: "+600 Steps")
    if obj.Name:match("%+%d+") then
        return true
    end
    return false
end

spawn(function()
    while true do
        task.wait(0.1)
        if flags.farmAll then
            local char = getChar()
            local HRP = char:FindFirstChild("HumanoidRootPart")
            if HRP then
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and isOrbOrStep(obj) then
                        tpTo(obj)
                        task.wait(0.12)
                    end
                end
            end
        else
            task.wait(0.5)
        end
    end
end)

-- Menú táctil para Android
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local gui = Instance.new("ScreenGui", PlayerGui)
gui.Name = "UltraFarmMenu"
gui.ResetOnSpawn = false

local btn = Instance.new("TextButton", gui)
btn.Size = UDim2.new(0, 200, 0, 80)
btn.Position = UDim2.new(0, 30, 0, 30)
btn.BackgroundColor3 = Color3.fromRGB(0,130,255)
btn.TextColor3 = Color3.new(1, 1, 1)
btn.Text = "Auto Farm OFF"
btn.TextScaled = true
btn.Font = Enum.Font.SourceSansBold

btn.MouseButton1Click:Connect(function()
    flags.farmAll = not flags.farmAll
    btn.Text = "Auto Farm " .. (flags.farmAll and "ON" or "OFF")
end)

print("¡Script auto farm listo! Toca el botón para activar o desactivar el farm de TODOS los orbes y pasos.")