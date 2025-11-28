local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KawaiiHUD"
screenGui.ResetOnSpawn = false
screenGui.Parent = script.Parent

local bg = Instance.new("Frame")
bg.Size = UDim2.new(0.6, 0, 0.12, 0)
bg.Position = UDim2.new(0.2, 0, 0.88, 0)
bg.BackgroundColor3 = Color3.fromRGB(255, 230, 250)
bg.BorderSizePixel = 0
bg.BackgroundTransparency = 0.1
bg.Parent = screenGui
bg.AnchorPoint = Vector2.new(0, 1)

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new(
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 210, 235)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(210, 240, 255))
)
gradient.Rotation = 15
gradient.Parent = bg

gradient.Enabled = true

local coinsLabel = Instance.new("TextLabel")
coinsLabel.Size = UDim2.new(0.3, 0, 1, 0)
coinsLabel.Position = UDim2.new(0, 10, 0, 0)
coinsLabel.BackgroundTransparency = 1
coinsLabel.Text = "Coins: 20"
coinsLabel.Font = Enum.Font.GothamSemibold
coinsLabel.TextColor3 = Color3.fromRGB(255, 105, 180)
coinsLabel.TextScaled = true
coinsLabel.Parent = bg

local levelLabel = Instance.new("TextLabel")
levelLabel.Size = UDim2.new(0.3, 0, 1, 0)
levelLabel.Position = UDim2.new(0.35, 0, 0, 0)
levelLabel.BackgroundTransparency = 1
levelLabel.Text = "Level: 1"
levelLabel.Font = Enum.Font.GothamSemibold
levelLabel.TextColor3 = Color3.fromRGB(170, 220, 255)
levelLabel.TextScaled = true
levelLabel.Parent = bg

local harvestHint = Instance.new("TextLabel")
harvestHint.Size = UDim2.new(0.3, 0, 1, 0)
harvestHint.Position = UDim2.new(0.68, 0, 0, 0)
harvestHint.BackgroundTransparency = 1
harvestHint.Text = "Bloom plants to earn SanrioCoins!"
harvestHint.Font = Enum.Font.GothamMedium
harvestHint.TextColor3 = Color3.fromRGB(255, 180, 220)
harvestHint.TextScaled = true
harvestHint.Parent = bg

local function updateStats()
    local statsFolder = ReplicatedStorage:FindFirstChild("PlayerData")
    if not statsFolder then
        return
    end

    local myStats = statsFolder:FindFirstChild(LocalPlayer.Name)
    if not myStats then
        return
    end

    local coins = myStats:FindFirstChild("Coins")
    if coins then
        coinsLabel.Text = string.format("Coins: %d", coins.Value)
    end

    local level = myStats:FindFirstChild("Level")
    if level then
        levelLabel.Text = string.format("Level: %d", level.Value)
    end
end

local function watchStat(stat)
    if not stat then
        return
    end

    stat:GetPropertyChangedSignal("Value"):Connect(updateStats)
end

task.spawn(function()
    while true do
        updateStats()
        local statsFolder = ReplicatedStorage:FindFirstChild("PlayerData")
        if statsFolder then
            local myStats = statsFolder:FindFirstChild(LocalPlayer.Name)
            if myStats then
                watchStat(myStats:FindFirstChild("Coins"))
                watchStat(myStats:FindFirstChild("Level"))
            end
        end
        task.wait(1)
    end
end)
