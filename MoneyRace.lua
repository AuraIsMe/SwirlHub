local Players = game:GetService("Players")
local player = Players.LocalPlayer

local vehicles = {
    "Golden Car", "Fighter Jet", "Forklift", "Golf Cart", "Ice Cream Truck",
    "Police Car", "Car", "Army Truck", "Motorcycle", "Pastry Kitty",
    "Cloud", "Rocket"
}

local trails = {
    "White", "Rainbow", "Blue", "Yellow", "Green",
    "Orange", "Red", "Pink", "Purple"
}

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Money Race - SwirlHub " .. Fluent.Version,
    SubTitle = "by aura",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportEnabled = false
local teleportConnection

if not _G.Options then
    _G.Options = {}
end

local Options = _G.Options

local Toggle = Tabs.Main:AddToggle("AutoCollectOrbs", {Title = "Auto-Collect Orbs", Default = false })
Options.AutoCollectOrbs = Toggle

Toggle:OnChanged(function()
    TeleportEnabled = Options.AutoCollectOrbs.Value
    if TeleportEnabled then
        startTeleporting()
    else
        if teleportConnection then
            teleportConnection:Disconnect()
            teleportConnection = nil
        end
    end
end)

Options.AutoCollectOrbs:SetValue(false)

function teleportParts()
    local player = Players.LocalPlayer
    if not player then
        warn("LocalPlayer not found")
        return
    end

    local character = player.Character
    if not character then
        warn("Character not found")
        return
    end

    local targetPosition = character:FindFirstChild("HumanoidRootPart")
    if not targetPosition then
        warn("HumanoidRootPart not found")
        return
    end

    targetPosition = targetPosition.Position

    local orbsFolder = workspace.Camera:FindFirstChild("Orbs")
    if not orbsFolder then
        warn("Orbs folder not found in workspace.Camera")
        return
    end
    
    for _, part in pairs(orbsFolder:GetChildren()) do
        if part:IsA("Part") then
            part.CanCollide = false
            part.CFrame = CFrame.new(targetPosition)
        end
    end
end

function startTeleporting()
    teleportConnection = RunService.RenderStepped:Connect(function()
        if TeleportEnabled then
            teleportParts()
        end
    end)
end

Players.LocalPlayer.CharacterAdded:Connect(function(character)
    character:WaitForChild("HumanoidRootPart")
    if TeleportEnabled then
        startTeleporting()
    end
end)

local Dropdown = Tabs.Main:AddDropdown("VehicleDropdown", {
    Title = "Select Vehicle",
    Values = vehicles,
    Multi = false,
    Default = 1,
})

Dropdown:SetValue(vehicles[1])

Dropdown:OnChanged(function(Value)
    print("Dropdown changed:", Value)
    
    local vehiclesData = player:FindFirstChild("VehiclesData")
    if vehiclesData then
        local equipped = vehiclesData:FindFirstChild("Equipped")
        if equipped and equipped:IsA("StringValue") then
            equipped.Value = Value
            print("Equipped vehicle changed to:", Value)
        else
            warn("Equipped StringValue not found")
        end
    else
        warn("VehiclesData folder not found")
    end
end)

local TrailDropdown = Tabs.Main:AddDropdown("TrailDropdown", {
    Title = "Select Trail",
    Values = trails,
    Multi = false,
    Default = 1,
})

TrailDropdown:SetValue(trails[1])

TrailDropdown:OnChanged(function(Value)
    print("Trail dropdown changed:", Value)
    
    local trailsData = player:FindFirstChild("TrailsData")
    if trailsData then
        local equipped = trailsData:FindFirstChild("Equipped")
        if equipped and equipped:IsA("StringValue") then
            equipped.Value = Value
            print("Equipped trail changed to:", Value)
        else
            warn("Equipped StringValue not found")
        end
    else
        warn("TrailsData folder not found")
    end
end)


SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()

SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("SwirlHub")
SaveManager:SetFolder("SwirlHub/MoneyRace")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "SwirlHub",
    Content = "The script has been loaded.",
    Duration = 8
})

SaveManager:LoadAutoloadConfig()