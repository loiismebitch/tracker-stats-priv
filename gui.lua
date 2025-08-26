-- gui.lua
local Tracker = require(game.ReplicatedStorage:WaitForChild("tracker")) -- hoặc nơi mày để tracker.lua

-- GUI cơ bản
local ScreenGui = Instance.new("ScreenGui", game.Players.LocalPlayer:WaitForChild("PlayerGui"))
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 250, 0, 150)
Frame.Position = UDim2.new(0.5, -125, 0.5, -75)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

local WebhookBox = Instance.new("TextBox", Frame)
WebhookBox.PlaceholderText = "Dán Webhook vào đây"
WebhookBox.Size = UDim2.new(1, -20, 0, 30)
WebhookBox.Position = UDim2.new(0, 10, 0, 10)

local IntervalBox = Instance.new("TextBox", Frame)
IntervalBox.PlaceholderText = "Thời gian (s)"
IntervalBox.Size = UDim2.new(1, -20, 0, 30)
IntervalBox.Position = UDim2.new(0, 10, 0, 50)

local ToggleBtn = Instance.new("TextButton", Frame)
ToggleBtn.Text = "Bật Tracker"
ToggleBtn.Size = UDim2.new(1, -20, 0, 40)
ToggleBtn.Position = UDim2.new(0, 10, 0, 90)

-- Event
ToggleBtn.MouseButton1Click:Connect(function()
    Tracker.Webhook = WebhookBox.Text
    Tracker.Interval = tonumber(IntervalBox.Text) or 15
    Tracker.Enabled = not Tracker.Enabled
    ToggleBtn.Text = Tracker.Enabled and "Tắt Tracker" or "Bật Tracker"
end)
