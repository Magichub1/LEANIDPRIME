local Players = game:GetService("Players")
local player = Players.LocalPlayer
local RunService = game:GetService("RunService")

local gui = Instance.new("ScreenGui")
gui.Name = "NovaHubFloat"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 120, 0, 100)
main.Position = UDim2.new(0, 10, 0, 10)
main.BackgroundColor3 = Color3.new(0.1, 0.05, 0.2)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0.9, 0, 0, 30)
btn.Position = UDim2.new(0.05, 0, 0.1, 0)
btn.Text = "FLY TO SPAWN"
btn.BackgroundColor3 = Color3.new(0.3, 0.15, 0.5)
btn.TextColor3 = Color3.new(1, 1, 1)
btn.Parent = main

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, 0, 0, 15)
speedLabel.Position = UDim2.new(0, 0, 0.5, 0)
speedLabel.Text = "Speed: 15"
speedLabel.TextColor3 = Color3.new(1, 1, 1)
speedLabel.BackgroundTransparency = 1
speedLabel.TextSize = 12
speedLabel.Parent = main

local speed = 15
local spawnLocation = Vector3.new(0, 10, 0)

local function findRealSpawn()
    local currentCharacter = player.Character
    if not currentCharacter then return end
    
    local humanoid = currentCharacter:FindFirstChild("Humanoid")
    local currentRoot = currentCharacter:FindFirstChild("HumanoidRootPart")
    if not humanoid or not currentRoot then return end

    local spawnFound = false
    local connection
    connection = player.CharacterAdded:Connect(function(newChar)
        if spawnFound then return end
        spawnFound = true
        wait(0.5)
        local newRoot = newChar:FindFirstChild("HumanoidRootPart")
        if newRoot then
            spawnLocation = newRoot.Position
        end
        if connection then connection:Disconnect() end
    end)
    
    humanoid.Health = 0
    wait(5)
    if not spawnFound and connection then connection:Disconnect() end
end

local floatEnabled = false
local bodyVelocity = nil

btn.MouseButton1Click:Connect(function()
    floatEnabled = not floatEnabled
    
    if floatEnabled then
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.MaxForce = Vector3.new(0, 2000, 0)
            bodyVelocity.Parent = character.HumanoidRootPart
        end
        
        local connection
        connection = RunService.Heartbeat:Connect(function()
            if not floatEnabled or not player.Character then 
                if connection then connection:Disconnect() end
                return 
            end
            
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root and spawnLocation and (root.Position - spawnLocation).Magnitude > 8 then
                local dir = (spawnLocation - root.Position).Unit
                root.Velocity = dir * speed
            else
                if bodyVelocity then bodyVelocity:Destroy() end
                floatEnabled = false
                if connection then connection:Disconnect() end
            end
        end)
    else
        if bodyVelocity then bodyVelocity:Destroy() end
    end
end)

local speedUp = Instance.new("TextButton")
speedUp.Size = UDim2.new(0.4, 0, 0, 20)
speedUp.Position = UDim2.new(0.55, 0, 0.7, 0)
speedUp.Text = "+"
speedUp.BackgroundColor3 = Color3.new(0.2, 0.4, 0.2)
speedUp.TextColor3 = Color3.new(1, 1, 1)
speedUp.Parent = main

local speedDown = Instance.new("TextButton")
speedDown.Size = UDim2.new(0.4, 0, 0, 20)
speedDown.Position = UDim2.new(0.05, 0, 0.7, 0)
speedDown.Text = "-"
speedDown.BackgroundColor3 = Color3.new(0.4, 0.2, 0.2)
speedDown.TextColor3 = Color3.new(1, 1, 1)
speedDown.Parent = main

speedUp.MouseButton1Click:Connect(function()
    speed = math.min(speed + 5, 50)
    speedLabel.Text = "Speed: " .. speed
end)

speedDown.MouseButton1Click:Connect(function()
    speed = math.max(speed - 5, 5)
speedLabel.Text = "Speed: " .. speed
end)

findRealSpawn()
