-- Load required libraries
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Create the main window
local Window = Fluent:CreateWindow({
    Title = "SwirlHub - SharkBite 2 " .. Fluent.Version,
    SubTitle = "by Auraジ",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Define tabs
local Tabs = {
    Main = Window:AddTab({ Title = "Boat Settings", Icon = "sailboat" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" })
}

-- Define color variables
local playerESPColor = Color3.fromRGB(96, 205, 255)
local sharkESPColor = Color3.fromRGB(96, 205, 255)
local playerTracerColor = Color3.fromRGB(96, 205, 255)
local sharkTracerColor = Color3.fromRGB(96, 205, 255)

-- List of boats
local boats = {
    "DuckyBoat", "FishingBoat", "SmallWoodenSailBoat", "UnicornBoat", "BlueWoodenMotorboat", "DoubleDoughnutTubeBoat", 
    "VikingLongship", "BabyDuckTrail", "SmallDinghyMotorboat", "HoverBike", "Sloop", "TourBoat", "TugBoat", "CanopyMotorboat", 
    "SharkCageBoat", "Catamaran", "Duckmarine", "Lifeboat", "ViperSpeedBoat", "JetSki", "PartyBoat", "UFO", "Marlin", "PyroTank", 
    "CombatBoat", "MilitarySubmarine", "SeaBreacher", "Wildfire", "StealthBoat", "CruiseShip", "Titanic", "HydroTank", "MarlinGT", 
    "DucklingBoat", "RGBTurretSleigh", "MagicWandBoat", "TheGoldenDucky", "Hover-Heart", "CoffinBat", "Sleigh2022", "GingerBoatMan", 
    "GingerbreadSteamBoat", "FestiveGalleon", "HMHSBritannic"
}

-- Add dropdown for boat selection
local Dropdown = Tabs.Main:AddDropdown("Dropdown", {
    Title = "Select a Boat",
    Values = boats,
    Multi = false,
    Default = 1
})
Dropdown:SetValue(boats[Dropdown.Default])
Dropdown:OnChanged(function(Value)
    print("Dropdown changed:", Value)
    local args = { [1] = Value }
    game:GetService("ReplicatedStorage"):WaitForChild("EventsFolder"):WaitForChild("BoatSelection"):WaitForChild("UpdateHostBoat"):FireServer(unpack(args))
end)
game:GetService("ReplicatedStorage"):WaitForChild("EventsFolder"):WaitForChild("BoatSelection"):WaitForChild("UpdateHostBoat"):FireServer(boats[Dropdown.Default])

-- Functions to update boat properties
local function updateMaxSpeed(Value)
    local playerName = game.Players.LocalPlayer.Name
    for _, boat in pairs(workspace.Boats:GetChildren()) do
        local seatsFolder = boat:FindFirstChild("Seats")
        if seatsFolder then
            local vehicleSeat = seatsFolder:FindFirstChild("VehicleSeat")
            if vehicleSeat then
                local boatOwnerName = vehicleSeat:FindFirstChild("BoatOwnerName")
                if boatOwnerName and boatOwnerName.Value == playerName then
                    local configuration = boat:FindFirstChild("Configuration")
                    if configuration then
                        local engineFolder = configuration:FindFirstChild("Engine")
                        if engineFolder then
                            local maxSpeed = engineFolder:FindFirstChild("MaxSpeed")
                            if maxSpeed then
                                maxSpeed.Value = Value
                                print("MaxSpeed updated to:", Value)
                            end
                        end
                    end
                end
            end
        end
    end
end

local function updateEngineCutOutHeight(Value)
    local playerName = game.Players.LocalPlayer.Name
    for _, boat in pairs(workspace.Boats:GetChildren()) do
        local seatsFolder = boat:FindFirstChild("Seats")
        if seatsFolder then
            local vehicleSeat = seatsFolder:FindFirstChild("VehicleSeat")
            if vehicleSeat then
                local boatOwnerName = vehicleSeat:FindFirstChild("BoatOwnerName")
                if boatOwnerName and boatOwnerName.Value == playerName then
                    local configuration = boat:FindFirstChild("Configuration")
                    if configuration then
                        local engineFolder = configuration:FindFirstChild("Engine")
                        if engineFolder then
                            local engineCutOutHeight = engineFolder:FindFirstChild("EngineCutOutHeight")
                            if engineCutOutHeight then
                                if Value then
                                    engineCutOutHeight.Value = 999999
                                else
                                    engineCutOutHeight.Value = engineCutOutHeight:GetAttribute("Default")
                                end
                                print("EngineCutOutHeight updated to:", engineCutOutHeight.Value)
                            end
                        end
                    end
                end
            end
        end
    end
end

local function updateMaxRotVel(Value)
    local playerName = game.Players.LocalPlayer.Name
    for _, boat in pairs(workspace.Boats:GetChildren()) do
        local seatsFolder = boat:FindFirstChild("Seats")
        if seatsFolder then
            local vehicleSeat = seatsFolder:FindFirstChild("VehicleSeat")
            if vehicleSeat then
                local boatOwnerName = vehicleSeat:FindFirstChild("BoatOwnerName")
                if boatOwnerName and boatOwnerName.Value == playerName then
                    local configuration = boat:FindFirstChild("Configuration")
                    if configuration then
                        local engineFolder = configuration:FindFirstChild("Engine")
                        if engineFolder then
                            local maxRotVel = engineFolder:FindFirstChild("MaxRotVel")
                            if maxRotVel then
                                maxRotVel.Value = Value
                                print("MaxRotVel updated to:", Value)
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Add sliders and toggles
local MaxSpeedSlider = Tabs.Main:AddSlider("MaxSpeedSlider", {
    Title = "Max Speed",
    Description = "Adjust the maximum speed of your boat",
    Default = 130,
    Min = 0,
    Max = 1000,
    Rounding = 1,
    Callback = updateMaxSpeed
})
MaxSpeedSlider:SetValue(3)

local MaxRotVelSlider = Tabs.Main:AddSlider("MaxRotVelSlider", {
    Title = "Max Steering",
    Description = "Adjust the steering speed of your boat",
    Default = 2,
    Min = 0,
    Max = 5,
    Rounding = 1,
    Callback = updateMaxRotVel
})
MaxRotVelSlider:SetValue(3)

local EngineCutOutHeightToggle = Tabs.Main:AddToggle("EngineCutOutHeightToggle", {
    Title = "Disable EngineCutOutHeight",
    Default = false,
    Callback = updateEngineCutOutHeight
})
EngineCutOutHeightToggle:SetValue(false)

-- Functions to manage ESP and tracers
local espEnabled, tracersEnabled = false, false
local tracers, sharkTracers = {}, {}

local function manageESP(state)
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer then
            if state then
                local highlight = Instance.new("Highlight")
                highlight.Name = "ESP_Highlight"
                highlight.FillColor = playerESPColor
                highlight.OutlineColor = Color3.new(0, 0, 0)
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.Adornee = player.Character
                highlight.Parent = player.Character
                player.CharacterAdded:Connect(function(character)
                    highlight.Adornee = character
                    highlight.Parent = character
                end)
            else
                if player.Character and player.Character:FindFirstChild("ESP_Highlight") then
                    player.Character:FindFirstChild("ESP_Highlight"):Destroy()
                end
            end
        end
    end
end

local function manageSharkESP(state)
    for _, shark in pairs(workspace.Sharks:GetChildren()) do
        if state then
            local highlight = Instance.new("Highlight")
            highlight.Name = "Shark_ESP_Highlight"
            highlight.FillColor = sharkESPColor
            highlight.OutlineColor = Color3.new(0, 0, 0)
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.Adornee = shark
            highlight.Parent = shark
        else
            if shark:FindFirstChild("Shark_ESP_Highlight") then
                shark:FindFirstChild("Shark_ESP_Highlight"):Destroy()
            end
        end
    end
end

local function createTracer(player)
    local line = Drawing.new("Line")
    line.Color = playerTracerColor
    line.Thickness = 1
    line.Transparency = 1
    tracers[player] = line
end

local function removeTracer(player)
    if tracers[player] then
        tracers[player]:Remove()
        tracers[player] = nil
    end
end

local function updateTracers()
    for player, line in pairs(tracers) do
        if tracersEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position)
            if onScreen then
                line.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)
                line.To = Vector2.new(screenPos.X, screenPos.Y)
                line.Visible = true
            else
                line.Visible = false
            end
        else
            line.Visible = false
        end
    end
end
game:GetService("RunService").RenderStepped:Connect(updateTracers)

local function manageTracers(state)
    tracersEnabled = state
    if state then
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer then
                createTracer(player)
            end
        end
    else
        for player, _ in pairs(tracers) do
            removeTracer(player)
        end
    end
end

local function createSharkTracer(shark)
    local line = Drawing.new("Line")
    line.Color = sharkTracerColor
    line.Thickness = 1
    line.Transparency = 1
    sharkTracers[shark] = line
end

local function removeSharkTracer(shark)
    if sharkTracers[shark] then
        sharkTracers[shark]:Remove()
        sharkTracers[shark] = nil
    end
end

local function updateSharkTracers()
    for shark, line in pairs(sharkTracers) do
        if tracersEnabled and shark and shark.PrimaryPart then
            local rootPart = shark.PrimaryPart
            local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position)
            if onScreen then
                line.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)
                line.To = Vector2.new(screenPos.X, screenPos.Y)
                line.Visible = true
            else
                line.Visible = false
            end
        else
            line.Visible = false
        end
    end
end
game:GetService("RunService").RenderStepped:Connect(updateSharkTracers)

local function manageSharkTracers(state)
    tracersEnabled = state
    if state then
        for _, shark in pairs(workspace.Sharks:GetChildren()) do
            createSharkTracer(shark)
        end
    else
        for shark, _ in pairs(sharkTracers) do
            removeSharkTracer(shark)
        end
    end
end

-- Add ESP and Tracer toggles
local ESP_Toggle = Tabs.Visuals:AddToggle("ESP_Toggle", {Title = "Player ESP", Default = false, Callback = manageESP})
ESP_Toggle:SetValue(false)

local Tracers_Toggle = Tabs.Visuals:AddToggle("Tracers_Toggle", {Title = "Player Tracers", Default = false, Callback = manageTracers})
Tracers_Toggle:SetValue(false)

local Shark_ESP_Toggle = Tabs.Visuals:AddToggle("Shark_ESP_Toggle", {Title = "Shark ESP", Default = false, Callback = manageSharkESP})
Shark_ESP_Toggle:SetValue(false)

local Shark_Tracers_Toggle = Tabs.Visuals:AddToggle("Shark_Tracers_Toggle", {Title = "Shark Tracers", Default = false, Callback = manageSharkTracers})
Shark_Tracers_Toggle:SetValue(false)

-- Add color pickers
local PlayerESPColorpicker = Tabs.Visuals:AddColorpicker("PlayerESPColorpicker", {Title = "Player ESP Color", Default = playerESPColor})
PlayerESPColorpicker:OnChanged(function()
    playerESPColor = PlayerESPColorpicker.Value
    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("ESP_Highlight") then
            player.Character:FindFirstChild("ESP_Highlight").FillColor = playerESPColor
        end
    end
end)
PlayerESPColorpicker:SetValueRGB(Color3.fromRGB(96, 205, 255))

local SharkESPColorpicker = Tabs.Visuals:AddColorpicker("SharkESPColorpicker", {Title = "Shark ESP Color", Default = sharkESPColor})
SharkESPColorpicker:OnChanged(function()
    sharkESPColor = SharkESPColorpicker.Value
    for _, shark in pairs(workspace.Sharks:GetChildren()) do
        if shark:FindFirstChild("Shark_ESP_Highlight") then
            shark:FindFirstChild("Shark_ESP_Highlight").FillColor = sharkESPColor
        end
    end
end)
SharkESPColorpicker:SetValueRGB(Color3.fromRGB(96, 205, 255))

local PlayerTracerColorpicker = Tabs.Visuals:AddColorpicker("PlayerTracerColorpicker", {Title = "Player Tracer Color", Default = playerTracerColor})
PlayerTracerColorpicker:OnChanged(function()
    playerTracerColor = PlayerTracerColorpicker.Value
    for _, line in pairs(tracers) do
        line.Color = playerTracerColor
    end
end)
PlayerTracerColorpicker:SetValueRGB(Color3.fromRGB(96, 205, 255))
 
local SharkTracerColorpicker = Tabs.Visuals:AddColorpicker("SharkTracerColorpicker", {Title = "Shark Tracer Color", Default = sharkTracerColor})
SharkTracerColorpicker:OnChanged(function()
    sharkTracerColor = SharkTracerColorpicker.Value
    for _, line in pairs(sharkTracers) do
        line.Color = sharkTracerColor
    end
end)
SharkTracerColorpicker:SetValueRGB(Color3.fromRGB(96, 205, 255))

-- Set up save and interface managers
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("SwirlHub")
SaveManager:SetFolder("SwirlHub/SharkBite")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- Select the first tab and notify script load completion
Window:SelectTab(1)
Fluent:Notify({Title = "Fluent", Content = "The script has been loaded.", Duration = 8})
SaveManager:LoadAutoloadConfig()
