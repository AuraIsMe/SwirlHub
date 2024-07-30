local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "SwirlHub - Tower Of Hell " .. Fluent.Version,
    SubTitle = "by dawid",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

local function enableGodmode()
    for i, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
        if v.ClassName == 'Part' then
            local fb = v:FindFirstChild('TouchInterest')
            if fb then
                fb:Destroy()
            end
        end
    end
    warn('godmode is ready. if u reset, dont re-execute, it will reload automatically')

    game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
        repeat wait() until game.Players.LocalPlayer.Character:FindFirstChild('HumanoidRootPart')
        for i, v in pairs(char:GetChildren()) do
            if v.ClassName == 'Part' then
                local fb = v:FindFirstChild('TouchInterest')
                if fb then
                    fb:Destroy()
                end
            end
        end
        warn('godmode is auto reloaded')
    end)
end

local function giveAllTools()
    local player = game.Players.LocalPlayer
    local gearsFolder = game.ReplicatedStorage:FindFirstChild("Gear")
    
    if gearsFolder then
        for _, tool in pairs(gearsFolder:GetChildren()) do
            if tool:IsA("Tool") then
                tool:Clone().Parent = player.Backpack
            end
        end
        warn('All tools have been added to your character.')
    else
        warn('Gear folder not found in ReplicatedStorage.')
    end
end

local function setGlobalJumps(value)
    local globalJumps = game.ReplicatedStorage:FindFirstChild("globalJumps")
    
    if globalJumps and globalJumps:IsA("IntValue") then
        globalJumps.Value = value
        warn('globalJumps value set to ' .. value)
    else
        warn('globalJumps IntValue not found in ReplicatedStorage.')
    end
end

local function setGlobalSpeed(value)
    local globalSpeed = game.ReplicatedStorage:FindFirstChild("globalSpeed")
    
    if globalSpeed and globalSpeed:IsA("NumberValue") then
        globalSpeed.Value = value
        warn('globalSpeed value set to ' .. value)
    else
        warn('globalSpeed NumberValue not found in ReplicatedStorage.')
    end
end

do

    Tabs.Main:AddButton({
        Title = "Activate Godmode",
        Description = "Enable godmode for your character",
        Callback = function()
            Window:Dialog({
                Title = "Activate Godmode",
                Content = "Are you sure you want to activate godmode?",
                Buttons = {
                    {
                        Title = "Confirm",
                        Callback = function()
                            enableGodmode()
                            print("Godmode activated.")
                        end
                    },
                    {
                        Title = "Cancel",
                        Callback = function()
                            print("Activation cancelled.")
                        end
                    }
                }
            })
        end
    })

    Tabs.Main:AddButton({
        Title = "Give All Tools",
        Description = "Give all tools from the Gear folder to your character",
        Callback = function()
            Window:Dialog({
                Title = "Give All Tools",
                Content = "Are you sure you want to give all tools to your character?",
                Buttons = {
                    {
                        Title = "Confirm",
                        Callback = function()
                            giveAllTools()
                            print("All tools given to character.")
                        end
                    },
                    {
                        Title = "Cancel",
                        Callback = function()
                            print("Tool giving cancelled.")
                        end
                    }
                }
            })
        end
    })

    local Toggle = Tabs.Main:AddToggle("GlobalJumpsToggle", {Title = "Infinite Jump", Default = false})

    Toggle:OnChanged(function()
        if Options.GlobalJumpsToggle.Value then
            setGlobalJumps(999)
        else
            setGlobalJumps(0)
        end
        print("Toggle changed:", Options.GlobalJumpsToggle.Value)
    end)

    Options.GlobalJumpsToggle:SetValue(false)

    local SpeedSlider = Tabs.Main:AddSlider("SpeedSlider", {
        Title = "Walkspeed",
        Description = "Adjust your walkspeed",
        Default = 16,
        Min = 0,
        Max = 100,
        Rounding = 0,
        Callback = function(Value)
            setGlobalSpeed(Value)
            print("Slider was changed:", Value)
        end
    })

    SpeedSlider:OnChanged(function(Value)
        setGlobalSpeed(Value)
        print("Slider changed:", Value)
    end)

    SpeedSlider:SetValue(16)

end

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()

SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("SwirlHub")
SaveManager:SetFolder("Swirlhub/TowerOfHell")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "SwirlHub",
    Content = "The script has been loaded.",
    Duration = 8
})

SaveManager:LoadAutoloadConfig()
