local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Fluent " .. Fluent.Version,
    SubTitle = "by dawid",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl -- Used when theres no MinimizeKeybind
})

local Tabs = {
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
    Autofarm = Window:AddTab({ Title = "Autofarm", Icon = "tractor" }),
    LocalPlayer = Window:AddTab({ Title = "LocalPlayer", Icon = "user" }),
    Fun = Window:AddTab({ Title = "Fun", Icon = "smile" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Creating the ESP toggles section for the Visuals tab
local ESPSection = Tabs.Visuals:AddSection("ESP Toggles")
local AllESP = ESPSection:AddToggle("AllESP", {Title = "All ESP", Default = false })
local SheriffESP = ESPSection:AddToggle("SheriffESP", {Title = "Sheriff ESP", Default = false })
local MurdererESP = ESPSection:AddToggle("MurdererESP", {Title = "Murderer ESP", Default = false })

-- Creating the Tracer toggles section for the Visuals tab
local TracerSection = Tabs.Visuals:AddSection("Tracer Toggles")
local InnocentTracer = TracerSection:AddToggle("InnocentTracer", {Title = "Innocent Tracer", Default = false })
local SheriffTracer = TracerSection:AddToggle("SheriffTracer", {Title = "Sheriff Tracer", Default = false })
local MurdererTracer = TracerSection:AddToggle("MurdererTracer", {Title = "Murderer Tracer", Default = false })

-- Creating the Box ESP section for the Visuals tab
local BoxESPSection = Tabs.Visuals:AddSection("Box ESP")
local InnocentBoxESP = BoxESPSection:AddToggle("InnocentBoxESP", {Title = "Innocent Box ESP", Default = false })
local SheriffBoxESP = BoxESPSection:AddToggle("SheriffBoxESP", {Title = "Sheriff Box ESP", Default = false })
local MurdererBoxESP = BoxESPSection:AddToggle("MurdererBoxESP", {Title = "Murderer Box ESP", Default = false })

-- Adding a new section for Other ESP features
local OtherESPSection = Tabs.Visuals:AddSection("Other")
local NotifyMurderer = OtherESPSection:AddToggle("NotifyMurderer", {Title = "Notify Murderer", Default = false })
local NotifySheriff = OtherESPSection:AddToggle("NotifySheriff", {Title = "Notify Sheriff", Default = false })
local DistanceESP = OtherESPSection:AddToggle("DistanceESP", {Title = "Distance ESP", Default = false })
local HealthBarESP = OtherESPSection:AddToggle("HealthBarESP", {Title = "Health Bar ESP", Default = false })

local tracers = {}
local highlights = {}
local boxes = {}
local notifications = {}
local distances = {}
local healthBars = {}

local function removeHighlights(player)
    if highlights[player] then
        highlights[player]:Destroy()
        highlights[player] = nil
    end
end

local function removeTracers(player)
    if tracers[player] then
        tracers[player].Visible = false
        tracers[player]:Remove()
        tracers[player] = nil
    end
end

local function removeBoxes(player)
    if boxes[player] then
        for _, box in pairs(boxes[player]) do
            box.Visible = false
            box:Remove()
        end
        boxes[player] = nil
    end
end

local function removeAllHighlightsTracersAndBoxes()
    for player, _ in pairs(highlights) do
        removeHighlights(player)
    end
    for player, _ in pairs(tracers) do
        removeTracers(player)
    end
    for player, _ in pairs(boxes) do
        removeBoxes(player)
    end
end

local function highlightPlayer(player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local backpack = player:FindFirstChild("Backpack")
        local character = player.Character
        local color = nil

        local function hasTool(toolName)
            return (backpack and backpack:FindFirstChild(toolName)) or (character:FindFirstChild(toolName))
        end

        if MurdererESP.Value and hasTool("Knife") then
            color = Color3.new(1, 0, 0) -- Red for Murderer
        elseif SheriffESP.Value and hasTool("Gun") then
            color = Color3.new(0, 0, 1) -- Blue for Sheriff
        elseif AllESP.Value then
            color = Color3.new(0, 1, 0) -- Green for Innocent
        else
            color = nil -- If the toggle is not enabled, do not highlight
        end

        removeHighlights(player)

        if color then
            -- Create a highlight (ESP)
            local highlight = Instance.new("Highlight")
            highlight.Adornee = player.Character
            highlight.FillColor = color
            highlight.OutlineColor = color
            highlight.Parent = player.Character.HumanoidRootPart
            highlights[player] = highlight
        end
    end
end

local function tracePlayer(player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local backpack = player:FindFirstChild("Backpack")
        local character = player.Character
        local color = nil

        local function hasTool(toolName)
            return (backpack and backpack:FindFirstChild(toolName)) or (character:FindFirstChild(toolName))
        end

        if MurdererTracer.Value and hasTool("Knife") then
            color = Color3.fromRGB(255, 0, 0) -- Red for Murderer
        elseif SheriffTracer.Value and hasTool("Gun") then
            color = Color3.fromRGB(0, 0, 255) -- Blue for Sheriff
        elseif InnocentTracer.Value then
            color = Color3.fromRGB(0, 255, 0) -- Green for Innocent
        else
            color = nil -- If the toggle is not enabled, do not trace
        end

        removeTracers(player)

        if color then
            -- Create a tracer (Drawing)
            local tracer = Drawing.new("Line")
            tracer.Color = color
            tracer.Thickness = 2
            tracer.Transparency = 1
            tracer.Visible = true
            tracers[player] = tracer
        end
    end
end

local function updateTracers()
    for player, tracer in pairs(tracers) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local rootPosition = hrp.Position
            local screenPosition, onScreen = workspace.CurrentCamera:WorldToViewportPoint(rootPosition)

            if onScreen then
                tracer.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)
                tracer.To = Vector2.new(screenPosition.X, screenPosition.Y)
                tracer.Visible = true
            else
                tracer.Visible = false
            end
        else
            tracer.Visible = false
        end
    end
end

local function boxPlayer(player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local backpack = player:FindFirstChild("Backpack")
        local character = player.Character
        local color = nil

        local function hasTool(toolName)
            return (backpack and backpack:FindFirstChild(toolName)) or (character:FindFirstChild(toolName))
        end

        if MurdererBoxESP.Value and hasTool("Knife") then
            color = Color3.fromRGB(255, 0, 0) -- Red for Murderer
        elseif SheriffBoxESP.Value and hasTool("Gun") then
            color = Color3.fromRGB(0, 0, 255) -- Blue for Sheriff
        elseif InnocentBoxESP.Value then
            color = Color3.fromRGB(0, 255, 0) -- Green for Innocent
        else
            color = nil -- If the toggle is not enabled, do not draw box
        end

        removeBoxes(player)

        if color then
            local box = {
                TopLeft = Drawing.new("Line"),
                TopRight = Drawing.new("Line"),
                BottomLeft = Drawing.new("Line"),
                BottomRight = Drawing.new("Line")
            }

            for _, line in pairs(box) do
                line.Color = color
                line.Thickness = 2
                line.Transparency = 1
                line.Visible = true
            end

            boxes[player] = box
        end
    end
end

local function updateBoxes()
    for player, box in pairs(boxes) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local rootPosition = hrp.Position
            local headPosition = player.Character.Head.Position
            local footPosition = hrp.Position - Vector3.new(0, 3, 0)

            local screenTop, onScreenTop = workspace.CurrentCamera:WorldToViewportPoint(headPosition)
            local screenBottom, onScreenBottom = workspace.CurrentCamera:WorldToViewportPoint(footPosition)

            if onScreenTop and onScreenBottom then
                local topLeft = Vector2.new(screenTop.X - 50, screenTop.Y)
                local topRight = Vector2.new(screenTop.X + 50, screenTop.Y)
                local bottomLeft = Vector2.new(screenBottom.X - 50, screenBottom.Y)
                local bottomRight = Vector2.new(screenBottom.X + 50, screenBottom.Y)

                box.TopLeft.From = topLeft
                box.TopLeft.To = topRight
                box.TopRight.From = topRight
                box.TopRight.To = bottomRight
                box.BottomLeft.From = bottomLeft
                box.BottomLeft.To = topLeft
                box.BottomRight.From = bottomLeft
                box.BottomRight.To = bottomRight

                for _, line in pairs(box) do
                    line.Visible = true
                end
            else
                for _, line in pairs(box) do
                    line.Visible = false
                end
            end
        else
            for _, line in pairs(box) do
                line.Visible = false
            end
        end
    end
end

local function highlightPlayers()
    removeAllHighlightsTracersAndBoxes()
    for _, player in pairs(game.Players:GetPlayers()) do
        highlightPlayer(player)
        tracePlayer(player)
        boxPlayer(player)
    end
end

local function tracePlayers()
    removeAllHighlightsTracersAndBoxes()
    for _, player in pairs(game.Players:GetPlayers()) do
        tracePlayer(player)
        boxPlayer(player)
    end
end

-- Function to notify murderer and sheriff
local function notifyRole(player, role)
    if role == "Murderer" and NotifyMurderer.Value then
        game.StarterGui:SetCore("SendNotification", {
            Title = "Role Notification",
            Text = player.Name .. " is the Murderer!",
            Duration = 5
        })
    elseif role == "Sheriff" and NotifySheriff.Value then
        game.StarterGui:SetCore("SendNotification", {
            Title = "Role Notification",
            Text = player.Name .. " is the Sheriff!",
            Duration = 5
        })
    end
end

local function removeHealthBars(player)
    if healthBars[player] then
        healthBars[player].Visible = false
        healthBars[player]:Remove()
        healthBars[player] = nil
    end
end

local function removeDistances(player)
    if distances[player] then
        distances[player].Visible = false
        distances[player]:Remove()
        distances[player] = nil
    end
end

local function updateHealthBars()
    for player, healthBar in pairs(healthBars) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            local hrp = player.Character.HumanoidRootPart
            local screenPosition, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0))

            if onScreen then
                healthBar.Position = Vector2.new(screenPosition.X, screenPosition.Y)
                healthBar.Text = tostring(player.Character.Humanoid.Health)
                healthBar.Visible = true
            else
                healthBar.Visible = false
            end
        else
            healthBar.Visible = false
        end
    end
end

local function updateDistances()
    for player, distanceLabel in pairs(distances) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local localPlayer = game.Players.LocalPlayer
            if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local distance = (localPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                local screenPosition, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)

                if onScreen then
                    distanceLabel.Position = Vector2.new(screenPosition.X, screenPosition.Y)
                    distanceLabel.Text = string.format("%.0f", distance) .. " studs"
                    distanceLabel.Visible = true
                else
                    distanceLabel.Visible = false
                end
            end
        else
            distanceLabel.Visible = false
        end
    end
end

local function healthBarPlayer(player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        removeHealthBars(player)

        if HealthBarESP.Value then
            local healthBar = Drawing.new("Text")
            healthBar.Text = tostring(player.Character.Humanoid.Health)
            healthBar.Color = Color3.new(1, 1, 1)
            healthBar.Size = 20
            healthBar.Visible = true
            healthBars[player] = healthBar
        end
    end
end

local function distancePlayer(player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        removeDistances(player)

        if DistanceESP.Value then
            local distanceLabel = Drawing.new("Text")
            distanceLabel.Text = ""
            distanceLabel.Color = Color3.new(1, 1, 1)
            distanceLabel.Size = 20
            distanceLabel.Visible = true
            distances[player] = distanceLabel
        end
    end
end

-- Connect the Other ESP toggles to their respective functions
HealthBarESP:OnChanged(function()
    for _, player in pairs(game.Players:GetPlayers()) do
        healthBarPlayer(player)
    end
end)

DistanceESP:OnChanged(function()
    for _, player in pairs(game.Players:GetPlayers()) do
        distancePlayer(player)
    end
end)

-- Function to monitor tool changes and notify roles
local function monitorPlayerTools(player)
    local function updatePlayer()
        if NotifyMurderer.Value or NotifySheriff.Value then
            local backpack = player:FindFirstChild("Backpack")
            local character = player.Character
            if (backpack and backpack:FindFirstChild("Knife")) or (character and character:FindFirstChild("Knife")) then
                notifyRole(player, "Murderer")
            elseif (backpack and backpack:FindFirstChild("Gun")) or (character and character:FindFirstChild("Gun")) then
                notifyRole(player, "Sheriff")
            end
        end
        healthBarPlayer(player)
        distancePlayer(player)
    end

    local backpack = player:WaitForChild("Backpack", 5)
    if backpack then
        backpack.ChildAdded:Connect(updatePlayer)
        backpack.ChildRemoved:Connect(updatePlayer)
    end

    player.CharacterAdded:Connect(function(character)
        updatePlayer()
        character.ChildAdded:Connect(updatePlayer)
        character.ChildRemoved:Connect(updatePlayer)
    end)
end

-- Add options to the LocalPlayer tab
local LocalPlayer = Tabs.LocalPlayer

-- WalkSpeed slider
local WalkSpeedSlider = LocalPlayer:AddSlider("WalkSpeed", {
    Title = "WalkSpeed",
    Description = "Adjust your walk speed",
    Default = 16,
    Min = 0,
    Max = 100,
    Rounding = 1,
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
    end
})

WalkSpeedSlider:OnChanged(function(Value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
end)

WalkSpeedSlider:SetValue(16)

-- JumpPower slider
local JumpPowerSlider = LocalPlayer:AddSlider("JumpPower", {
    Title = "JumpPower",
    Description = "Adjust your jump power",
    Default = 50,
    Min = 0,
    Max = 200,
    Rounding = 1,
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
    end
})

JumpPowerSlider:OnChanged(function(Value)
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
end)

JumpPowerSlider:SetValue(50)

-- Gravity slider
local GravitySlider = LocalPlayer:AddSlider("Gravity", {
    Title = "Gravity",
    Description = "Adjust the gravity",
    Default = 196.2,
    Min = 0,
    Max = 500,
    Rounding = 1,
    Callback = function(Value)
        workspace.Gravity = Value
    end
})

GravitySlider:OnChanged(function(Value)
    workspace.Gravity = Value
end)

GravitySlider:SetValue(196.2)

-- NoClip toggle
local NoClipToggle = LocalPlayer:AddToggle("NoClip", {Title = "NoClip", Default = false })

NoClipToggle:OnChanged(function(Value)
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    
    if Value then
        _G.noclip = game:GetService("RunService").Stepped:Connect(function()
            for _, v in pairs(character:GetDescendants()) do
                if v:IsA("BasePart") and v.CanCollide then
                    v.CanCollide = false
                end
            end
        end)
    else
        if _G.noclip then
            _G.noclip:Disconnect()
        end
    end
end)

-- Infinite Jump toggle
local InfJumpToggle = LocalPlayer:AddToggle("InfJump", {Title = "Infinite Jump", Default = false })

InfJumpToggle:OnChanged(function(Value)
    if Value then
        _G.infJump = game:GetService("UserInputService").JumpRequest:Connect(function()
            game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end)
    else
        if _G.infJump then
            _G.infJump:Disconnect()
        end
    end
end)


-- Connect the ESP toggles to the highlight function
AllESP:OnChanged(highlightPlayers)
SheriffESP:OnChanged(highlightPlayers)
MurdererESP:OnChanged(highlightPlayers)

-- Connect the Tracer toggles to the trace function
InnocentTracer:OnChanged(tracePlayers)
SheriffTracer:OnChanged(tracePlayers)
MurdererTracer:OnChanged(tracePlayers)

-- Connect the Box ESP toggles to the box function
InnocentBoxESP:OnChanged(tracePlayers)
SheriffBoxESP:OnChanged(tracePlayers)
MurdererBoxESP:OnChanged(tracePlayers)

-- Function to monitor tool changes
local function monitorPlayerTools(player)
    local function updatePlayer()
        highlightPlayer(player)
        tracePlayer(player)
        boxPlayer(player)
    end

    local backpack = player:WaitForChild("Backpack", 5)
    if backpack then
        backpack.ChildAdded:Connect(updatePlayer)
        backpack.ChildRemoved:Connect(updatePlayer)
    end

    player.CharacterAdded:Connect(function(character)
        updatePlayer()
        character.ChildAdded:Connect(updatePlayer)
        character.ChildRemoved:Connect(updatePlayer)
    end)
end

-- Monitor existing players
for _, player in pairs(game.Players:GetPlayers()) do
    monitorPlayerTools(player)
end

-- Monitor new players
game.Players.PlayerAdded:Connect(function(player)
    monitorPlayerTools(player)
    player.CharacterAdded:Connect(function()
        highlightPlayer(player)
        tracePlayer(player)
        boxPlayer(player)
    end)
end)

-- Clean up when players leave
game.Players.PlayerRemoving:Connect(function(player)
    removeHighlights(player)
    removeTracers(player)
    removeBoxes(player)
end)

-- Update tracers and boxes regularly
game:GetService("RunService").RenderStepped:Connect(function()
    updateTracers()
    updateBoxes()
end)

-- Monitor existing players
for _, player in pairs(game.Players:GetPlayers()) do
    monitorPlayerTools(player)
end

-- Monitor new players
game.Players.PlayerAdded:Connect(function(player)
    monitorPlayerTools(player)
    player.CharacterAdded:Connect(function()
        healthBarPlayer(player)
        distancePlayer(player)
    end)
end)

-- Clean up when players leave
game.Players.PlayerRemoving:Connect(function(player)
    removeHealthBars(player)
    removeDistances(player)
end)

-- Update health bars and distances regularly
game:GetService("RunService").RenderStepped:Connect(function()
    updateHealthBars()
    updateDistances()
end)