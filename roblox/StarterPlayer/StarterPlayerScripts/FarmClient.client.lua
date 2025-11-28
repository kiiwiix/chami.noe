local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlantEvent = ReplicatedStorage:WaitForChild("PlantEvent")
local HarvestEvent = ReplicatedStorage:WaitForChild("HarvestEvent")

local STAGE_UI_INFO = {
    [""] = {text = "Empty", color = Color3.fromRGB(255, 198, 225)},
    Seed = {text = "Seed", color = Color3.fromRGB(255, 170, 200)},
    Sprout = {text = "Sprout", color = Color3.fromRGB(200, 255, 210)},
    Bloom = {text = "Bloom", color = Color3.fromRGB(255, 210, 255)},
}

local watchedPlots = setmetatable({}, {__mode = "k"})

local function ensureClickDetector(plot)
    local detector = plot:FindFirstChildOfClass("ClickDetector")
    if not detector then
        detector = Instance.new("ClickDetector")
        detector.Parent = plot
    end
    detector.MaxActivationDistance = 20
    detector.CursorIcon = "rbxassetid://14072613574"
    return detector
end

local function ensureBillboard(plot)
    local billboard = plot:FindFirstChild("StageBillboard")
    if billboard then
        return billboard
    end

    billboard = Instance.new("BillboardGui")
    billboard.Name = "StageBillboard"
    billboard.Size = UDim2.new(0, 120, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.MaxDistance = 45
    billboard.AlwaysOnTop = false
    billboard.LightInfluence = 0
    billboard.Parent = plot

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 0.6
    frame.BackgroundColor3 = Color3.fromRGB(255, 230, 245)
    frame.BorderSizePixel = 0
    frame.Parent = billboard

    local label = Instance.new("TextLabel")
    label.Name = "Text"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamSemibold
    label.TextScaled = true
    label.TextColor3 = Color3.fromRGB(255, 145, 200)
    label.Text = ""
    label.Parent = frame

    return billboard
end

local function ensureHighlight(plot)
    local highlight = plot:FindFirstChild("HarvestHighlight")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "HarvestHighlight"
        highlight.Adornee = plot
        highlight.FillColor = Color3.fromRGB(255, 230, 255)
        highlight.FillTransparency = 0.7
        highlight.OutlineColor = Color3.fromRGB(255, 150, 220)
        highlight.OutlineTransparency = 0.2
        highlight.DepthMode = Enum.HighlightDepthMode.Occluded
        highlight.Enabled = false
        highlight.Parent = plot
    end
    return highlight
end

local function playReadySound(plot)
    local existing = plot:FindFirstChild("HarvestChime")
    if existing then
        existing:Destroy()
    end

    local sound = Instance.new("Sound")
    sound.Name = "HarvestChime"
    sound.SoundId = "rbxassetid://1843520515"
    sound.Volume = 0.8
    sound.RollOffMaxDistance = 40
    sound.Parent = plot
    sound:Play()
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
end

local function updatePlotVisuals(plot)
    local stageName = plot:GetAttribute("StageName") or ""
    local info = STAGE_UI_INFO[stageName] or STAGE_UI_INFO[""]

    local billboard = ensureBillboard(plot)
    local label = billboard:FindFirstChild("Frame") and billboard.Frame:FindFirstChild("Text")
    if label then
        label.Text = info.text
        label.TextColor3 = info.color
    end

    local highlight = ensureHighlight(plot)
    local ready = plot:GetAttribute("ReadyToHarvest") and plot:GetAttribute("Planted")
    local wasEnabled = highlight.Enabled
    highlight.Enabled = ready and true or false
    if ready and not wasEnabled then
        playReadySound(plot)
    end
end

local function onPlotClicked(plot)
    if not plot:GetAttribute("Planted") then
        PlantEvent:FireServer(plot)
        return
    end

    if plot:GetAttribute("ReadyToHarvest") then
        HarvestEvent:FireServer(plot)
    end
end

local function watchPlot(plot)
    if watchedPlots[plot] then
        return
    end
    watchedPlots[plot] = true

    ensureClickDetector(plot).MouseClick:Connect(function()
        onPlotClicked(plot)
    end)

    updatePlotVisuals(plot)

    plot:GetAttributeChangedSignal("StageName"):Connect(function()
        updatePlotVisuals(plot)
    end)

    plot:GetAttributeChangedSignal("ReadyToHarvest"):Connect(function()
        updatePlotVisuals(plot)
    end)

    local billboard = ensureBillboard(plot)
    local frame = billboard:FindFirstChild("Frame")
    if frame then
        frame.BackgroundTransparency = 0.8
        local tween = TweenService:Create(frame, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1, true), {
            BackgroundTransparency = 0.6,
        })
        tween:Play()
    end
end

local function bindPlotClicks()
    local farmFolder = workspace:FindFirstChild(LocalPlayer.Name .. "_Farm")
    if not farmFolder then
        return
    end

    for _, plot in ipairs(farmFolder:GetChildren()) do
        if plot:IsA("BasePart") then
            watchPlot(plot)
        end
    end
end

workspace.ChildAdded:Connect(function(child)
    if child.Name == LocalPlayer.Name .. "_Farm" then
        task.wait(1)
        bindPlotClicks()
    end
end)

bindPlotClicks()
