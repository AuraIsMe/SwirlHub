local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local backpack = player:WaitForChild("Backpack")

local Options = {}

local isLooping = false

local function notify(title, content, subContent, duration)
    Fluent:Notify({
        Title = title,
        Content = content,
        SubContent = subContent or "",
        Duration = duration or 5
    })
end

local function equipAllTools()
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            tool.Parent = character
        end
    end
    notify("Tools Equipped", "All tools in your backpack have been equipped.")
end

local function unequipAllTools()
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            tool.Parent = backpack
        end
    end
    notify("Tools Unequipped", "All tools have been unequipped back to your backpack.")
end

local function equipAndUnequipTools()
    while isLooping do
        equipAllTools()
        task.wait(0.1)
        unequipAllTools()
        task.wait(0.1)
    end
end

local function notify(title, content, subContent, duration)
    Fluent:Notify({
        Title = title,
        Content = content,
        SubContent = subContent or "",
        Duration = duration or 5 
    })
end

local function handleKill(targetPlayer)
    if not firetouchinterest then
        notify('Incompatible Exploit', 'Your exploit does not support this command (missing firetouchinterest)')
        return
    end

    local equippedTool = player.Character and player.Character:FindFirstChildWhichIsA("Tool")
    local handle = equippedTool and equippedTool:FindFirstChild("Handle")

    if not equippedTool or not handle then
        notify("Handle Kill", "You need to hold a \"Tool\" that does damage on touch. For example the default \"Sword\" tool.")
        return
    end

    task.spawn(function()
        while equippedTool and player.Character and targetPlayer.Character and equippedTool.Parent == player.Character do
            local humanoid = targetPlayer.Character:FindFirstChildWhichIsA("Humanoid")
            if not humanoid or humanoid.Health <= 0 then
                break
            end
            for _, part in ipairs(targetPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    firetouchinterest(handle, part, 1)
                    RunService.RenderStepped:Wait()
                    firetouchinterest(handle, part, 0)
                end
            end
        end
        notify("Handle Kill Stopped!", targetPlayer.Name .. " died/left or you unequipped the tool!")
    end)
end

local function updatePlayerProperty(property, value)
    if property == "WalkSpeed" or property == "JumpPower" or property == "Health" then
        if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if property == "WalkSpeed" then
                humanoid.WalkSpeed = value
            elseif property == "JumpPower" then
                humanoid.JumpPower = value
            elseif property == "Health" then
                humanoid.Health = value
            end
        end
    elseif property == "Gravity" then
        Workspace.Gravity = value
    elseif property == "FOV" then
        Workspace.CurrentCamera.FieldOfView = value
    end
end

local function createPlayerESP(player)
    if player.Character then
        local highlight = Instance.new("Highlight")
        highlight.Name = "PlayerESP"
        highlight.Parent = player.Character
        highlight.Adornee = player.Character
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0.5

        player.CharacterAdded:Connect(function(character)
            highlight.Parent = character
            highlight.Adornee = character
        end)
    end
end

local function removePlayerESP(player)
    if player.Character and player.Character:FindFirstChild("PlayerESP") then
        player.Character.PlayerESP:Destroy()
    end
end

local playerBoxes = {}

local function createBoxESP(player)
    if not playerBoxes[player] then
        local box = Drawing.new("Square")
        box.Thickness = 2
        box.Color = Color3.fromRGB(0, 255, 0)
        box.Transparency = 1
        box.Filled = false

        playerBoxes[player] = box

        RunService.RenderStepped:Connect(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local rootPart = player.Character.HumanoidRootPart
                local rootPosition, onScreen = Workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position)

                if onScreen then
                    local head = player.Character:FindFirstChild("Head")
                    local headPosition = Workspace.CurrentCamera:WorldToViewportPoint(head.Position)
                    local legPosition = Workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))

                    box.Size = Vector2.new(1000 / rootPosition.Z, headPosition.Y - legPosition.Y)
                    box.Position = Vector2.new(rootPosition.X - box.Size.X / 2, rootPosition.Y - box.Size.Y / 2)
                    box.Visible = true
                else
                    box.Visible = false
                end
            else
                box.Visible = false
            end
        end)
    end
end

local function removeBoxESP(player)
    if playerBoxes[player] then
        playerBoxes[player]:Remove()
        playerBoxes[player] = nil
    end
end

local playerTracers = {}

local function createTracerESP(player)
    if not playerTracers[player] then
        local tracer = Drawing.new("Line")
        tracer.Thickness = 2
        tracer.Color = Color3.fromRGB(255, 0, 0)
        tracer.Transparency = 1

        playerTracers[player] = tracer

        RunService.RenderStepped:Connect(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local rootPart = player.Character.HumanoidRootPart
                local rootPosition, onScreen = Workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position)

                if onScreen then
                    tracer.From = Vector2.new(Workspace.CurrentCamera.ViewportSize.X / 2, Workspace.CurrentCamera.ViewportSize.Y)
                    tracer.To = Vector2.new(rootPosition.X, rootPosition.Y)
                    tracer.Visible = true
                else
                    tracer.Visible = false
                end
            else
                tracer.Visible = false
            end
        end)
    end
end

local function removeTracerESP(player)
    if playerTracers[player] then
        playerTracers[player]:Remove()
        playerTracers[player] = nil
    end
end

local function createNameESP(player)
    if player.Character then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "NameESP"
        billboard.Parent = player.Character:FindFirstChild("Head")
        billboard.Adornee = player.Character:FindFirstChild("Head")
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 2, 0)
        billboard.AlwaysOnTop = true

        local textLabel = Instance.new("TextLabel")
        textLabel.Parent = billboard
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        textLabel.TextScaled = true
        textLabel.Text = player.Name
    end
end


local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "LuckyBlock - SharkBite 2 " .. Fluent.Version,
    SubTitle = "by Auraジ",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Blocks", Icon = "toy-brick" }),
    Player = Window:AddTab({ Title = "LocalPlayer", Icon = "user" }),
    ESP = Window:AddTab({ Title = "ESP", Icon = "eye" }),
    Blatant = Window:AddTab({ Title = "Blatent", Icon = "sword" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local events = {
    {event = ReplicatedStorage:WaitForChild("SpawnSuperBlock"), name = "SuperBlock"},
    {event = ReplicatedStorage:WaitForChild("SpawnDiamondBlock"), name = "DiamondBlock"},
    {event = ReplicatedStorage:WaitForChild("SpawnGalaxyBlock"), name = "GalaxyBlock"},
    {event = ReplicatedStorage:WaitForChild("SpawnLuckyBlock"), name = "LuckyBlock"},
    {event = ReplicatedStorage:WaitForChild("SpawnRainbowBlock"), name = "RainbowBlock"}
}

local function fireEvent(event)
    event:FireServer()
end

local toggleStates = {}
local Options = {}

for _, entry in ipairs(events) do
    local toggle = Tabs.Main:AddToggle(entry.name .. "Toggle", {Title = "Loop Open " .. entry.name, Default = false })
    Options[entry.name .. "Toggle"] = toggle

    toggleStates[entry.name] = false

    toggle:OnChanged(function()
        toggleStates[entry.name] = toggle.Value
        print(entry.name .. " Toggle changed:", toggleStates[entry.name])
    end)
end

local loopDelay = 0.1
local DelaySlider = Tabs.Main:AddSlider("DelaySlider", {
    Title = "Loop Delay",
    Description = "Set the delay between each block opening",
    Default = 0.1,
    Min = 0.1,
    Max = 5,
    Rounding = 1,
    Callback = function(Value)
        loopDelay = Value
    end
})
Options["DelaySlider"] = DelaySlider

local masterToggleState = false
local MasterToggle = Tabs.Main:AddToggle("MasterToggle", {Title = "Toggle All Blocks", Default = false })
Options["MasterToggle"] = MasterToggle

MasterToggle:OnChanged(function()
    masterToggleState = MasterToggle.Value
    for _, entry in ipairs(events) do
        toggleStates[entry.name] = masterToggleState
        if Options[entry.name .. "Toggle"] then
            Options[entry.name .. "Toggle"]:SetValue(masterToggleState)
        end
    end
end)

local Keybind = Tabs.Main:AddKeybind("MasterKeybind", {
    Title = "Master Toggle Keybind",
    Mode = "Toggle",
    Default = "LeftControl",
    Callback = function(Value)
        masterToggleState = not masterToggleState
        MasterToggle:SetValue(masterToggleState)
        for _, entry in ipairs(events) do
            toggleStates[entry.name] = masterToggleState
            if Options[entry.name .. "Toggle"] then
                Options[entry.name .. "Toggle"]:SetValue(masterToggleState)
            end
        end
    end,
    ChangedCallback = function(New)
        print("Master Keybind changed to:", New)
    end
})

Keybind:OnChanged(function()
    print("Keybind changed:", Keybind.Value)
end)

-- Input for custom commands
local Input = Tabs.Main:AddInput("CustomCommandInput", {
    Title = "Custom Command",
    Default = "",
    Placeholder = "Enter command...",
    Numeric = false, -- Only allows numbers
    Finished = false, -- Only calls callback when you press enter
    Callback = function(Value)
        print("Input changed:", Value)
        -- Implement custom command handling here
    end
})

Input:OnChanged(function()
    print("Input updated:", Input.Value)
end)

-- Continuously check and fire events
spawn(function()
    local openCounts = {SuperBlock = 0, DiamondBlock = 0, GalaxyBlock = 0, LuckyBlock = 0, RainbowBlock = 0}
    while true do
        for _, entry in ipairs(events) do
            if toggleStates[entry.name] then
                fireEvent(entry.event)
                openCounts[entry.name] = openCounts[entry.name] + 1
                -- Update status (if status display method available)
            end
        end
        wait(loopDelay) -- Use the adjustable delay
    end
end)

-- Ensure all toggles are initially off
for _, entry in ipairs(events) do
    local toggle = Options[entry.name .. "Toggle"]
    if toggle then
        toggle:SetValue(false)
    end
end


-- Walkspeed Slider
local WalkSpeedSlider = Tabs.Player:AddSlider("WalkSpeedSlider", {
    Title = "Walkspeed",
    Description = "Change your player walkspeed",
    Default = 16,
    Min = 0,
    Max = 500,
    Rounding = 1,
    Callback = function(Value)
        updatePlayerProperty("WalkSpeed", Value)
    end
})

-- Jump Power Slider
local JumpPowerSlider = Tabs.Player:AddSlider("JumpPowerSlider", {
    Title = "Jump Power",
    Description = "Change your player jump power",
    Default = 50,
    Min = 0,
    Max = 500,
    Rounding = 1,
    Callback = function(Value)
        updatePlayerProperty("JumpPower", Value)
    end
})

-- Gravity Slider
local GravitySlider = Tabs.Player:AddSlider("GravitySlider", {
    Title = "Gravity",
    Description = "Change game gravity",
    Default = Workspace.Gravity,
    Min = 0,
    Max = 196.2,
    Rounding = 1,
    Callback = function(Value)
        updatePlayerProperty("Gravity", Value)
    end
})

-- Health Slider
local HealthSlider = Tabs.Player:AddSlider("HealthSlider", {
    Title = "Health",
    Description = "Change your player health",
    Default = 100,
    Min = 0,
    Max = 1000,
    Rounding = 1,
    Callback = function(Value)
        updatePlayerProperty("Health", Value)
    end
})

-- FOV Slider
local FOVSlider = Tabs.Player:AddSlider("FOVSlider", {
    Title = "Field of View",
    Description = "Change your field of view",
    Default = Workspace.CurrentCamera.FieldOfView,
    Min = 70,
    Max = 120,
    Rounding = 1,
    Callback = function(Value)
        updatePlayerProperty("FOV", Value)
    end
})

-- Fly toggle
local flying = false
local function setFly(state)
    flying = state
    if flying then
        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.Parent = player.Character.HumanoidRootPart
        bodyGyro.P = 9e4
        bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bodyGyro.CFrame = player.Character.HumanoidRootPart.CFrame

        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Parent = player.Character.HumanoidRootPart
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)

        RunService.RenderStepped:Connect(function()
            if flying then
                bodyGyro.CFrame = Workspace.CurrentCamera.CFrame
                bodyVelocity.Velocity = Workspace.CurrentCamera.CFrame.LookVector * 50
            else
                bodyGyro:Destroy()
                bodyVelocity:Destroy()
            end
        end)
    end
end

Options.FlyToggle = Tabs.Player:AddToggle("FlyToggle", {
    Title = "Fly",
    Default = false,
    Callback = function(Value)
        setFly(Value)
    end
})

-- Noclip toggle
local noclip = false
local function setNoclip(state)
    noclip = state
    RunService.Stepped:Connect(function()
        if noclip then
            for _, v in pairs(player.Character:GetDescendants()) do
                if v:IsA("BasePart") and v.CanCollide then
                    v.CanCollide = false
                end
            end
        end
    end)
end

Options.NoclipToggle = Tabs.Player:AddToggle("NoclipToggle", {
    Title = "Noclip",
    Default = false,
    Callback = function(Value)
        setNoclip(Value)
    end
})

-- Teleport function
local function teleportTo(location)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = location
    end
end

local locations = {
    {name = "Base", position = CFrame.new(-1039.5282, -128.299408, 85.450943)},
    {name = "Middle", position = CFrame.new(-1041.23193, 190.831711, 90.9453735)},
    {name = "Pink Bridge", position = CFrame.new(-868.601929, 194.367462, 211.650894)},
    {name = "Purple Bridge", position = CFrame.new(-933.63385, 194.367462, 263.423431)},
    {name = "Red Bridge", position = CFrame.new(-1161.80469, 194.367447, 263.3815)},
    {name = "Blue Bridge", position = CFrame.new(-1215.68848, 194.367355, 198.300949)},
    {name = "Cyan Bridge", position = CFrame.new(-1215.79639, 194.367447, -30.0486374)},
    {name = "Green Bridge", position = CFrame.new(-1148.33435, 194.367462, -83.3314285)},
    {name = "Yellow Bridge", position = CFrame.new(-920.233826, 194.367462, -83.3137131)},
    {name = "Orange Bridge", position = CFrame.new(-868.59314, 194.367462, -16.6490135)},
}

-- Create a table for dropdown values
local locationNames = {}
for _, location in ipairs(locations) do
    table.insert(locationNames, location.name)
end

-- Ensure the dropdown is added to an existing tab (Player in this case)
if Tabs and Tabs.Player then
    -- Add Dropdown for teleport locations
    Options.TeleportDropdown = Tabs.Player:AddDropdown("TeleportDropdown", {
        Title = "Teleport",
        Values = locationNames,
        Multi = false,
        Default = 1,
    })

    Options.TeleportDropdown:SetValue(locationNames[1])

    Options.TeleportDropdown:OnChanged(function(Value)
        for _, location in ipairs(locations) do
            if location.name == Value then
                teleportTo(location.position)
                break
            end
        end
    end)
else
    warn("Tabs.Player does not exist. Ensure the tab is correctly created.")
end

-- ESP Tab
local ESP_Tab = Tabs.ESP

-- Player ESP Toggle
local playerESPEnabled = false
Options.PlayerESPToggle = ESP_Tab:AddToggle("PlayerESPToggle", {Title = "Player ESP", Default = false })

Options.PlayerESPToggle:OnChanged(function()
    playerESPEnabled = Options.PlayerESPToggle.Value
    if playerESPEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer then
                createPlayerESP(player)
            end
        end
    else
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer then
                removePlayerESP(player)
            end
        end
    end
end)

Options.PlayerESPToggle:SetValue(false)

-- Update ESP for new players joining the game
Players.PlayerAdded:Connect(function(player)
    if playerESPEnabled then
        createPlayerESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removePlayerESP(player)
end)

-- Health ESP Toggle
local healthESPEnabled = false
Options.HealthESPToggle = ESP_Tab:AddToggle("HealthESPToggle", {Title = "Health ESP", Default = false })

Options.HealthESPToggle:OnChanged(function()
    healthESPEnabled = Options.HealthESPToggle.Value
    if healthESPEnabled then
        RunService.RenderStepped:Connect(function()
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= Players.LocalPlayer and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
                    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                    local head = player.Character:FindFirstChild("Head")
                    if head then
                        if not head:FindFirstChild("HealthBillboard") then
                            local billboard = Instance.new("BillboardGui")
                            billboard.Name = "HealthBillboard"
                            billboard.Parent = head
                            billboard.Adornee = head
                            billboard.Size = UDim2.new(1, 0, 1, 0)
                            billboard.StudsOffset = Vector3.new(0, 2, 0)
                            billboard.AlwaysOnTop = true

                            local frame = Instance.new("Frame")
                            frame.Parent = billboard
                            frame.Size = UDim2.new(1, 0, 0.1, 0)
                            frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)

                            local healthBar = Instance.new("Frame")
                            healthBar.Parent = frame
                            healthBar.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 1, 0)
                            healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                            humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                                healthBar.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 1, 0)
                            end)
                        end
                    end
                end
            end
        end)
    else
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("Head") and player.Character.Head:FindFirstChild("HealthBillboard") then
                player.Character.Head.HealthBillboard:Destroy()
            end
        end
    end
end)

Options.HealthESPToggle:SetValue(false)

-- Distance ESP Toggle
local distanceESPEnabled = false
Options.DistanceESPToggle = ESP_Tab:AddToggle("DistanceESPToggle", {Title = "Distance ESP", Default = false })

Options.DistanceESPToggle:OnChanged(function()
    distanceESPEnabled = Options.DistanceESPToggle.Value
    if distanceESPEnabled then
        RunService.RenderStepped:Connect(function()
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= Players.LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                    local head = player.Character:FindFirstChild("Head")
                    if head then
                        if not head:FindFirstChild("DistanceBillboard") then
                            local billboard = Instance.new("BillboardGui")
                            billboard.Name = "DistanceBillboard"
                            billboard.Parent = head
                            billboard.Adornee = head
                            billboard.Size = UDim2.new(1, 0, 1, 0)
                            billboard.StudsOffset = Vector3.new(0, 3, 0)
                            billboard.AlwaysOnTop = true

                            local textLabel = Instance.new("TextLabel")
                            textLabel.Parent = billboard
                            textLabel.Size = UDim2.new(1, 0, 1, 0)
                            textLabel.BackgroundTransparency = 1
                            textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                            textLabel.TextScaled = true
                            textLabel.Text = tostring(math.floor((player.Character.HumanoidRootPart.Position - Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)) .. " studs"

                            RunService.RenderStepped:Connect(function()
                                textLabel.Text = tostring(math.floor((player.Character.HumanoidRootPart.Position - Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)) .. " studs"
                            end)
                        end
                    end
                end
            end
        end)
    else
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("Head") and player.Character.Head:FindFirstChild("DistanceBillboard") then
                player.Character.Head.DistanceBillboard:Destroy()
            end
        end
    end
end)

Options.DistanceESPToggle:SetValue(false)

-- Box ESP Toggle
local boxESPEnabled = false
Options.BoxESPToggle = ESP_Tab:AddToggle("BoxESPToggle", {Title = "Box ESP", Default = false })

Options.BoxESPToggle:OnChanged(function()
    boxESPEnabled = Options.BoxESPToggle.Value
    if boxESPEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer then
                createBoxESP(player)
            end
        end
    else
        for _, player in ipairs(Players:GetPlayers()) do
            removeBoxESP(player)
        end
    end
end)

Options.BoxESPToggle:SetValue(false)

-- Update Box ESP for new players joining the game
Players.PlayerAdded:Connect(function(player)
    if boxESPEnabled then
        createBoxESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removeBoxESP(player)
end)

-- Tracer ESP Toggle
local tracerESPEnabled = false
Options.TracerESPToggle = ESP_Tab:AddToggle("TracerESPToggle", {Title = "Tracer ESP", Default = false })

Options.TracerESPToggle:OnChanged(function()
    tracerESPEnabled = Options.TracerESPToggle.Value
    if tracerESPEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer then
                createTracerESP(player)
            end
        end
    else
        for _, player in ipairs(Players:GetPlayers()) do
            removeTracerESP(player)
        end
    end
end)

Options.TracerESPToggle:SetValue(false)

-- Update Tracer ESP for new players joining the game
Players.PlayerAdded:Connect(function(player)
    if tracerESPEnabled then
        createTracerESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removeTracerESP(player)
end)

-- Name ESP Toggle
local nameESPEnabled = false
Options.NameESPToggle = ESP_Tab:AddToggle("NameESPToggle", {Title = "Name ESP", Default = false })

Options.NameESPToggle:OnChanged(function()
    nameESPEnabled = Options.NameESPToggle.Value
    if nameESPEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer then
                createNameESP(player)
            end
        end
    else
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("Head") and player.Character.Head:FindFirstChild("NameESP") then
                player.Character.Head.NameESP:Destroy()
            end
        end
    end
end)

Options.NameESPToggle:SetValue(false)

-- Update Name ESP for new players joining the game
Players.PlayerAdded:Connect(function(player)
    if nameESPEnabled then
        createNameESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    -- Remove Name ESP
    if player.Character and player.Character:FindFirstChild("Head") and player.Character.Head:FindFirstChild("NameESP") then
        player.Character.Head.NameESP:Destroy()
    end
end)


-- Adjust ESP properties as needed using sliders
Options.ESPFillTransparency = ESP_Tab:AddSlider("ESPFillTransparency", {
    Title = "ESP Fill Transparency",
    Description = "Adjust the transparency of the ESP fill.",
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(Value)
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("PlayerESP") then
                player.Character.PlayerESP.FillTransparency = Value
            end
        end
    end
})

Options.ESPOutlineTransparency = ESP_Tab:AddSlider("ESPOutlineTransparency", {
    Title = "ESP Outline Transparency",
    Description = "Adjust the transparency of the ESP outline.",
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(Value)
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("PlayerESP") then
                player.Character.PlayerESP.OutlineTransparency = Value
            end
        end
    end
})

-- Create a multi-dropdown to select multiple players
local playerNames = {}
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= player then
        table.insert(playerNames, p.Name)
    end
end

local selectedPlayers = {}

local MultiDropdown = Tabs.Blatant:AddDropdown("PlayerMultiDropdown", {
    Title = "Select Players",
    Description = "You can select multiple players.",
    Values = playerNames,
    Multi = true,
    Default = {},
})

MultiDropdown:OnChanged(function(Value)
    selectedPlayers = {}
    for playerName, isSelected in pairs(Value) do
        if isSelected then
            table.insert(selectedPlayers, Players:FindFirstChild(playerName))
        end
    end
    print("Selected players: ", table.concat(playerNames, ", "))
end)

-- Button to perform handle kill on all selected players
local HandleKillButton = Tabs.Blatant:AddButton({
    Title = "Handle Kill",
    Callback = function()
        for _, targetPlayer in ipairs(selectedPlayers) do
            if targetPlayer then
                handleKill(targetPlayer)
            else
                print("No player selected.")
            end
        end
    end
})

-- Update player list when players join or leave
Players.PlayerAdded:Connect(function(newPlayer)
    table.insert(playerNames, newPlayer.Name)
    MultiDropdown:UpdateValues(playerNames)
end)

Players.PlayerRemoving:Connect(function(leavingPlayer)
    for i, playerName in ipairs(playerNames) do
        if playerName == leavingPlayer.Name then
            table.remove(playerNames, i)
            break
        end
    end
    MultiDropdown:UpdateValues(playerNames)
end)

-- Reinitialize tool and handle on respawn
player.CharacterAdded:Connect(function(newCharacter)
    player.Character = newCharacter
    for _, targetPlayer in ipairs(selectedPlayers) do
        handleKill(targetPlayer)
    end
end)

-- Toggle to start/stop the equip and unequip loop
local EquipUnequipToggle = Tabs.Blatant:AddToggle("EquipUnequipToggle", {
    Title = "Equip/Unequip Loop",
    Default = false,
    Callback = function(Value)
        isLooping = Value
        if isLooping then
            task.spawn(equipAndUnequipTools)
        end
    end
})

-- Reinitialize on respawn
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
end)


-- Notify function using Fluent
local function notify(title, content, subContent, duration)
    Fluent:Notify({
        Title = title,
        Content = content,
        SubContent = subContent or "",
        Duration = duration or 5 -- Set to nil to make the notification not disappear
    })
end

-- Function to teleport a player to the "F22 Bombing Jet" Torso
local function teleportToJet(targetPlayer)
    local jet = Workspace:FindFirstChild("F22 Bombing Jet")
    if jet and jet:FindFirstChild("Torso") then
        local jetCFrame = jet.Torso.CFrame
        if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            targetPlayer.Character.HumanoidRootPart.CFrame = jetCFrame
            notify("Teleport Success", targetPlayer.Name .. " has been teleported to the F22 Bombing Jet.")
        else
            notify("Teleport Failed", targetPlayer.Name .. " does not have a valid HumanoidRootPart.")
        end
    else
        notify("Teleport Failed", "F22 Bombing Jet not found or does not have a Torso part.")
    end
end

-- Function to update the player list in the dropdown
local function updatePlayerList()
    local playerNames = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            table.insert(playerNames, p.Name)
        end
    end
    return playerNames
end

-- Create a dropdown to select a player
local selectedPlayer = nil

local PlayerDropdown = Tabs.Blatant:AddDropdown("PlayerDropdown", {
    Title = "Select Player",
    Description = "Select a player to teleport to the F22 Bombing Jet.",
    Values = updatePlayerList(),
    Multi = false,
    Default = nil,
    Callback = function(Value)
        selectedPlayer = Players:FindFirstChild(Value)
        if selectedPlayer then
            teleportToJet(selectedPlayer)
        else
            notify("Teleport Failed", "Player not found.")
        end
    end
})

-- Update player list when players join or leave
Players.PlayerAdded:Connect(function(newPlayer)
    PlayerDropdown:UpdateValues(updatePlayerList())
end)

Players.PlayerRemoving:Connect(function(leavingPlayer)
    PlayerDropdown:UpdateValues(updatePlayerList())
end)

-- Reinitialize on respawn
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
end)


SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()

SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("SwirlHub")
SaveManager:SetFolder("SwirlHub/Lucky")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "SwirlHub",
    Content = "The script has been loaded.",
    Duration = 8
})

SaveManager:LoadAutoloadConfig()
