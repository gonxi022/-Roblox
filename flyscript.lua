-- Cargador interactivo para gefreira de gemas Legends of Speed
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local function startGemCollector()
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local HRP = Character:WaitForChild("HumanoidRootPart")
    local tpEnabled, magnetEnabled = false, false
    local lastTP = 0
    local TP_COOLDOWN = 0.8
    local MAGNET_SPEED = 100
    local COLLECTION_RADIUS = 40

    local function getGems()
        local gems = {}
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name:match("[Gg]em") then
                table.insert(gems, obj)
            end
        end
        return gems
    end

    local function doTeleport()
        local gems = getGems()
        local closest, dmin = nil, math.huge
        for _, gem in ipairs(gems) do
            local d = (gem.Position - HRP.Position).Magnitude
            if d < dmin then
                closest, dmin = gem, d
            end
        end
        if closest and tick() - lastTP >= TP_COOLDOWN then
            HRP.CFrame = CFrame.new(closest.Position + Vector3.new(0,3,0))
            lastTP = tick()
        end
    end

    local function doMagnet(dt)
        for _, gem in ipairs(getGems()) do
            local dir = (HRP.Position - gem.Position)
            if dir.Magnitude <= COLLECTION_RADIUS then
                gem.Velocity = dir.Unit * MAGNET_SPEED * dt
            end
        end
    end

    local function onStep(_, dt)
        if tpEnabled then doTeleport() end
        if magnetEnabled then doMagnet(dt) end
    end

    local connection = RunService.Stepped:Connect(onStep)

    -- UI
    local gui = Instance.new("ScreenGui", PlayerGui)
    gui.Name = "LegendGemUI"
    gui.ResetOnSpawn = false

    local function addButton(y, text, toggleFlag)
        local btn = Instance.new("TextButton", gui)
        btn.Size = UDim2.new(0,200,0,50)
        btn.Position = UDim2.new(0.05,0,y,0)
        btn.BackgroundColor3 = Color3.fromRGB(35,35,35)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Text = text.." OFF"
        btn.TextScaled = true
        btn.BorderSizePixel = 0
        btn.BackgroundTransparency = 0.1
        btn.MouseButton1Click:Connect(function()
            if toggleFlag == "tp" then
                tpEnabled = not tpEnabled
                btn.Text = "🔁 TP GEM "..(tpEnabled and "ON" or "OFF")
            else
                magnetEnabled = not magnetEnabled
                btn.Text = "🧲 MAGNET "..(magnetEnabled and "ON" or "OFF")
            end
        end)
        btn.TouchTap:Connect(btn.MouseButton1Click)
    end

    addButton(0.7, "🔁 TP GEM", "tp")
    addButton(0.8, "🧲 MAGNET", "mag")

    Players.LocalPlayer.CharacterAdded:Connect(function(newChar)
        Character = newChar
        HRP = Character:WaitForChild("HumanoidRootPart")
    end)
end

startGemCollector()
