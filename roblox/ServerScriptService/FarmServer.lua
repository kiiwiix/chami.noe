local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function ensureRemote(name)
    local remote = ReplicatedStorage:FindFirstChild(name)
    if not remote then
        remote = Instance.new("RemoteEvent")
        remote.Name = name
        remote.Parent = ReplicatedStorage
    end
    return remote
end

local FarmManager = require(ReplicatedStorage:WaitForChild("FarmManager"))
local PlantEvent = ensureRemote("PlantEvent")
local HarvestEvent = ensureRemote("HarvestEvent")

local playerData = {} -- [userId] = {coins = number, level = number}

local function updatePlayerData(player)
    local data = playerData[player.UserId]
    if not data then
        return
    end

    local folder = ReplicatedStorage:FindFirstChild("PlayerData")
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = "PlayerData"
        folder.Parent = ReplicatedStorage
    end

    local stats = folder:FindFirstChild(player.Name)
    if not stats then
        stats = Instance.new("Folder")
        stats.Name = player.Name
        stats.Parent = folder
    end

    local coins = stats:FindFirstChild("Coins")
    if not coins then
        coins = Instance.new("IntValue")
        coins.Name = "Coins"
        coins.Parent = stats
    end
    coins.Value = data.coins

    local level = stats:FindFirstChild("Level")
    if not level then
        level = Instance.new("IntValue")
        level.Name = "Level"
        level.Parent = stats
    end
    level.Value = data.level
end

local function isPlayerPlot(player, plot)
    if not plot or not plot:IsA("BasePart") then
        return false
    end

    for _, ownedPlot in ipairs(FarmManager:GetPlots(player)) do
        if ownedPlot == plot then
            return true
        end
    end
    return false
end

local function canAfford(player, cost)
    local data = playerData[player.UserId]
    return data and data.coins >= cost
end

Players.PlayerAdded:Connect(function(player)
    playerData[player.UserId] = {coins = 20, level = 1}
    FarmManager:CreateFarm(player)
    updatePlayerData(player)
end)

Players.PlayerRemoving:Connect(function(player)
    local statsFolder = ReplicatedStorage:FindFirstChild("PlayerData")
    if statsFolder then
        local stats = statsFolder:FindFirstChild(player.Name)
        if stats then
            stats:Destroy()
        end
    end
    FarmManager:RemoveFarm(player)
    playerData[player.UserId] = nil
end)

PlantEvent.OnServerEvent:Connect(function(player, plot)
    if not isPlayerPlot(player, plot) then
        return
    end

    if not canAfford(player, FarmManager.PLANT_COST) then
        return
    end

    if FarmManager:PlantSeed(player, plot) then
        playerData[player.UserId].coins -= FarmManager.PLANT_COST
        updatePlayerData(player)
    end
end)

HarvestEvent.OnServerEvent:Connect(function(player, plot)
    if not isPlayerPlot(player, plot) then
        return
    end

    local reward = FarmManager:HarvestPlant(player, plot)
    if reward > 0 then
        playerData[player.UserId].coins += reward
        updatePlayerData(player)
    end
end)
