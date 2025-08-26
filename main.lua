-- 🌱 Tracker GUI Rewrite by Loi
-- Một file duy nhất - chỉ cần loadstring từ GitHub

--// Services
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

--// Tracker Module
local Tracker = {
    Webhook = "",
    Interval = 15,
    Running = false,
    Thread = nil
}

function Tracker.SendStats()
    if Tracker.Webhook == "" then return end
    -- TODO: ở đây mày add code lấy stats thực tế trong game
    local stats = {
        seed = math.random(1,100),
        sprinkler = math.random(1,5),
        lastEgg = os.date("%X")
    }
    local body = {
        content = string.format("🌱 **Tracker Stats**\nSeed: %s\nSprinkler: %s\nLast Egg: %s", stats.seed, stats.sprinkler, stats.lastEgg)
    }
    syn.request({
        Url = Tracker.Webhook,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode(body)
    })
end

function Tracker.Start()
    if Tracker.Running then return end
    Tracker.Running = true
    Tracker.Thread = task.spawn(function()
        while Tracker.Running do
            Tracker.SendStats()
            task.wait(Tracker.Interval)
        end
    end)
end

function Tracker.Stop()
    Tracker.Running = false
    if Tracker.Thread then
        task.cancel(Tracker.Thread)
        Tracker.Thread = nil
    end
end

--// GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TrackerUI"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Toggle Button
local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.new(0, 120, 0, 40)
Toggle.Position = UDim2.new(0, 20, 0.5, -20)
Toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Toggle.TextColor3 = Color3.fromRGB(255,255,255)
Toggle.Text = "🌱 Tracker"
Toggle.Parent = ScreenGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 250)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 8)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -10, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "🌱 Tracker Control"
Title.TextColor3 = Color3.fromRGB(0, 255, 128)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

-- Webhook box
local WebhookBox = Instance.new("TextBox")
WebhookBox.Size = UDim2.new(0.9, 0, 0, 35)
WebhookBox.PlaceholderText = "Enter Discord Webhook..."
WebhookBox.TextColor3 = Color3.fromRGB(255,255,255)
WebhookBox.BackgroundColor3 = Color3.fromRGB(45,45,45)
WebhookBox.ClearTextOnFocus = false
WebhookBox.Parent = MainFrame

-- Interval box
local IntervalBox = Instance.new("TextBox")
IntervalBox.Size = UDim2.new(0.9, 0, 0, 35)
IntervalBox.PlaceholderText = "Interval (seconds)"
IntervalBox.TextColor3 = Color3.fromRGB(255,255,255)
IntervalBox.BackgroundColor3 = Color3.fromRGB(45,45,45)
IntervalBox.ClearTextOnFocus = false
IntervalBox.Parent = MainFrame

-- Buttons row
local ButtonRow = Instance.new("Frame")
ButtonRow.Size = UDim2.new(0.9, 0, 0, 40)
ButtonRow.BackgroundTransparency = 1
ButtonRow.Parent = MainFrame

local UIList2 = Instance.new("UIListLayout")
UIList2.FillDirection = Enum.FillDirection.Horizontal
UIList2.Padding = UDim.new(0, 10)
UIList2.Parent = ButtonRow

-- Start Button
local StartBtn = Instance.new("TextButton")
StartBtn.Size = UDim2.new(0.5, -5, 1, 0)
StartBtn.BackgroundColor3 = Color3.fromRGB(0,170,85)
StartBtn.Text = "▶ Start"
StartBtn.TextColor3 = Color3.fromRGB(255,255,255)
StartBtn.Parent = ButtonRow

-- Stop Button
local StopBtn = Instance.new("TextButton")
StopBtn.Size = UDim2.new(0.5, -5, 1, 0)
StopBtn.BackgroundColor3 = Color3.fromRGB(170,0,0)
StopBtn.Text = "⏹ Stop"
StopBtn.TextColor3 = Color3.fromRGB(255,255,255)
StopBtn.Parent = ButtonRow

-- Status
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(0.9, 0, 0, 30)
Status.Text = "Status: Idle"
Status.TextColor3 = Color3.fromRGB(200,200,200)
Status.BackgroundTransparency = 1
Status.Parent = MainFrame

--// Logic
Toggle.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

StartBtn.MouseButton1Click:Connect(function()
    Tracker.Webhook = WebhookBox.Text
    Tracker.Interval = tonumber(IntervalBox.Text) or 15
    Tracker.Start()
    Status.Text = "Status: Running"
    Status.TextColor3 = Color3.fromRGB(0,255,0)
end)

StopBtn.MouseButton1Click:Connect(function()
    Tracker.Stop()
    Status.Text = "Status: Stopped"
    Status.TextColor3 = Color3.fromRGB(255,0,0)
end)
