local FarmManager = {}

local farmPlots = {} -- [userId] = {plotParts = {...}, states = {[BasePart] = PlotState}}

local GROWTH_STAGES = {
    {
        name = "Seed",
        duration = 6,
        parts = {
            {
                name = "Seed",
                shape = Enum.PartType.Ball,
                size = Vector3.new(1.2, 1.2, 1.2),
                color = Color3.fromRGB(255, 170, 200),
                material = Enum.Material.SmoothPlastic,
                offset = Vector3.new(0, 0.9, 0),
            },
        },
    },
    {
        name = "Sprout",
        duration = 9,
        parts = {
            {
                name = "Stem",
                shape = Enum.PartType.Cylinder,
                size = Vector3.new(0.6, 3.4, 0.6),
                color = Color3.fromRGB(180, 255, 215),
                material = Enum.Material.Neon,
                offset = Vector3.new(0, 1.8, 0),
            },
            {
                name = "Leaves",
                shape = Enum.PartType.Ball,
                size = Vector3.new(1.6, 1.2, 1.6),
                color = Color3.fromRGB(255, 210, 235),
                material = Enum.Material.SmoothPlastic,
                offset = Vector3.new(0, 3.0, 0),
            },
        },
    },
    {
        name = "Bloom",
        duration = 0,
        parts = {
            {
                name = "Stem",
                shape = Enum.PartType.Cylinder,
                size = Vector3.new(0.6, 4.0, 0.6),
                color = Color3.fromRGB(180, 255, 215),
                material = Enum.Material.Neon,
                offset = Vector3.new(0, 2.0, 0),
            },
            {
                name = "FlowerCore",
                shape = Enum.PartType.Ball,
                size = Vector3.new(0.9, 0.9, 0.9),
                color = Color3.fromRGB(255, 255, 210),
                material = Enum.Material.SmoothPlastic,
                offset = Vector3.new(0, 4.2, 0),
            },
        },
        onCreated = function(model, plot)
            local base = plot.Position + Vector3.new(0, plot.Size.Y / 2 + 4, 0)
            for index = 1, 4 do
                local angle = (index - 1) * (math.pi / 2)
                local offset = Vector3.new(math.cos(angle) * 1.25, 0, math.sin(angle) * 1.25)

                local petal = Instance.new("Part")
                petal.Name = "Petal" .. index
                petal.Shape = Enum.PartType.Ball
                petal.Size = Vector3.new(1.5, 0.6, 1.5)
                petal.Color = Color3.fromRGB(255, 185, 230)
                petal.Material = Enum.Material.SmoothPlastic
                petal.CanCollide = false
                petal.Anchored = true
                petal.CFrame = CFrame.new(base + offset)
                petal.Parent = model
            end

            local flowerCore = model:FindFirstChild("FlowerCore")
            if flowerCore then
                local sparkle = Instance.new("ParticleEmitter")
                sparkle.Name = "BloomSparkles"
                sparkle.Texture = "rbxassetid://1290405163"
                sparkle.Rate = 8
                sparkle.Lifetime = NumberRange.new(1.2, 1.8)
                sparkle.Speed = NumberRange.new(0.4, 0.8)
                sparkle.Color = ColorSequence.new(
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 240)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
                )
                sparkle.LightEmission = 0.6
                sparkle.SpreadAngle = Vector2.new(15, 15)
                sparkle.Parent = flowerCore
            end
        end,
    },
}

FarmManager.PLANT_COST = 1
FarmManager.HARVEST_REWARD = 8

export type PlotState = {
    planted: boolean,
    stageIndex: number,
    model: Instance?,
    growthCancelled: boolean,
}

local function getPlayerPlots(player)
    return farmPlots[player.UserId]
end

local function setPlotAttributes(plot, planted, stageIndex)
    plot:SetAttribute("Planted", planted)
    plot:SetAttribute("StageIndex", stageIndex)
    local stageName = GROWTH_STAGES[stageIndex] and GROWTH_STAGES[stageIndex].name or ""
    plot:SetAttribute("StageName", stageName)
    plot:SetAttribute("ReadyToHarvest", stageIndex == #GROWTH_STAGES)
end

local function clearModel(plot, state)
    if state.model and state.model.Parent then
        state.model:Destroy()
    end
    state.model = nil
    for _, child in plot:GetChildren() do
        if child:IsA("Model") and child.Name == "CutePlant" then
            child:Destroy()
        end
    end
end

local function buildPlantModel(plot, stage)
    local model = Instance.new("Model")
    model.Name = "CutePlant"
    model.Parent = plot

    local basePosition = plot.Position + Vector3.new(0, plot.Size.Y / 2, 0)
    for _, partDef in stage.parts do
        local part = Instance.new("Part")
        part.Name = partDef.name
        part.Shape = partDef.shape or Enum.PartType.Block
        part.Size = partDef.size
        part.Color = partDef.color
        part.Material = partDef.material or Enum.Material.SmoothPlastic
        part.Transparency = partDef.transparency or 0
        part.CanCollide = false
        part.Anchored = true

        local partCFrame = CFrame.new(basePosition + partDef.offset)
        if partDef.orientation then
            local orientation = partDef.orientation
            partCFrame = partCFrame * CFrame.Angles(
                math.rad(orientation.X),
                math.rad(orientation.Y),
                math.rad(orientation.Z)
            )
        end

        part.CFrame = partCFrame
        part.Parent = model
    end

    if stage.onCreated then
        stage.onCreated(model, plot)
    end

    return model
end

local function applyStage(plot, state, stageIndex)
    local stage = GROWTH_STAGES[stageIndex]
    if not stage then
        return
    end

    clearModel(plot, state)
    state.model = buildPlantModel(plot, stage)
    state.stageIndex = stageIndex
    setPlotAttributes(plot, true, stageIndex)
end

local function runGrowth(player, plot, state)
    state.growthCancelled = false
    for stageIndex = 2, #GROWTH_STAGES do
        local stage = GROWTH_STAGES[stageIndex]
        if stage.duration and stage.duration > 0 then
            local elapsed = 0
            while elapsed < stage.duration do
                if state.growthCancelled or not state.planted then
                    return
                end
                local step = math.min(0.5, stage.duration - elapsed)
                task.wait(step)
                elapsed += step
            end
        end

        if state.growthCancelled or not state.planted then
            return
        end
        applyStage(plot, state, stageIndex)
    end
end

function FarmManager:CreateFarm(player)
    local workspaceService = game:GetService("Workspace")
    local farmsFolder = workspaceService:FindFirstChild("Farms")
    if not farmsFolder then
        farmsFolder = Instance.new("Folder")
        farmsFolder.Name = "Farms"
        farmsFolder.Parent = workspaceService
    end

    local farmName = player.Name .. "_Farm"
    local existingFarm = farmsFolder:FindFirstChild(farmName)
    if existingFarm then
        existingFarm:Destroy()
    end

    local plotFolder = Instance.new("Folder")
    plotFolder.Name = farmName
    plotFolder.Parent = farmsFolder

    local plots = {}
    local plotStates = {}
    local basePos = Vector3.new(math.random(-20, 20), 0.6, math.random(-20, 20))

    for row = 1, 3 do
        for column = 1, 3 do
            local plot = Instance.new("Part")
            plot.Name = "Plot"
            plot.Size = Vector3.new(4, 0.2, 4)
            plot.Position = basePos + Vector3.new(row * 5, 0, column * 5)
            plot.Anchored = true
            plot.Color = Color3.fromRGB(255, 220, 240)
            plot.Material = Enum.Material.SmoothPlastic
            plot:SetAttribute("Planted", false)
            plot:SetAttribute("StageIndex", 0)
            plot:SetAttribute("StageName", "")
            plot:SetAttribute("ReadyToHarvest", false)
            plot.Parent = plotFolder

            plots[#plots + 1] = plot
            plotStates[plot] = {
                planted = false,
                stageIndex = 0,
                model = nil,
                growthCancelled = false,
            }
        end
    end

    farmPlots[player.UserId] = {plotParts = plots, states = plotStates}
end

function FarmManager:GetPlots(player)
    local record = getPlayerPlots(player)
    if record then
        return record.plotParts
    end
    return {}
end

local function getPlotState(player, plot)
    local record = getPlayerPlots(player)
    if not record then
        return nil
    end
    return record.states[plot]
end

function FarmManager:PlantSeed(player, plot)
    local state = getPlotState(player, plot)
    if not state or state.planted then
        return false
    end

    state.planted = true
    state.stageIndex = 1
    applyStage(plot, state, 1)

    task.spawn(function()
        runGrowth(player, plot, state)
    end)

    return true
end

function FarmManager:HarvestPlant(player, plot)
    local state = getPlotState(player, plot)
    if not state or not state.planted then
        return 0
    end

    if state.stageIndex < #GROWTH_STAGES then
        return 0
    end

    state.planted = false
    state.growthCancelled = true
    clearModel(plot, state)
    setPlotAttributes(plot, false, 0)

    return self.HARVEST_REWARD
end

function FarmManager:RemoveFarm(player)
    local workspaceService = game:GetService("Workspace")
    local farmsFolder = workspaceService:FindFirstChild("Farms")
    if farmsFolder then
        local existingFarm = farmsFolder:FindFirstChild(player.Name .. "_Farm")
        if existingFarm then
            existingFarm:Destroy()
        end
    end

    farmPlots[player.UserId] = nil
end

function FarmManager:Reset()
    table.clear(farmPlots)
end

return FarmManager
