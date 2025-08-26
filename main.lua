-- tracker.lua gộp vào đây
local Tracker = {}
Tracker.Webhook = ""
Tracker.Interval = 15

function Tracker.SetWebhook(url)
    Tracker.Webhook = url
end

function Tracker.SetInterval(seconds)
    Tracker.Interval = seconds
end

function Tracker.SendStats()
    -- ở đây xử lý lấy dữ liệu seed, sprinkler, egg...
    local data = {
        content = "🌱 Stats update\nSeed: ...\nSprinkler: ...\nLast Egg: ..."
    }
    syn.request({
        Url = Tracker.Webhook,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = game:GetService("HttpService"):JSONEncode(data)
    })
end

-- gui.lua gộp vào đây
local function CreateGui()
    local ScreenGui = Instance.new("ScreenGui")
    local Frame = Instance.new("Frame")
    Frame.Parent = ScreenGui
    Frame.Size = UDim2.new(0, 250, 0, 150)
    Frame.Position = UDim2.new(0.5, -125, 0.5, -75)
    Frame.BackgroundColor3 = Color3.fromRGB(40,40,40)

    local WebhookBox = Instance.new("TextBox")
    WebhookBox.Parent = Frame
    WebhookBox.Size = UDim2.new(1, -20, 0, 30)
    WebhookBox.Position = UDim2.new(0, 10, 0, 10)
    WebhookBox.PlaceholderText = "Paste Discord Webhook"

    local IntervalBox = Instance.new("TextBox")
    IntervalBox.Parent = Frame
    IntervalBox.Size = UDim2.new(1, -20, 0, 30)
    IntervalBox.Position = UDim2.new(0, 10, 0, 50)
    IntervalBox.PlaceholderText = "Interval (seconds)"

    local Button = Instance.new("TextButton")
    Button.Parent = Frame
    Button.Size = UDim2.new(1, -20, 0, 30)
    Button.Position = UDim2.new(0, 10, 0, 90)
    Button.Text = "Start Tracker"

    Button.MouseButton1Click:Connect(function()
        Tracker.SetWebhook(WebhookBox.Text)
        Tracker.SetInterval(tonumber(IntervalBox.Text) or 15)
        print("Tracker started!")

        task.spawn(function()
            while true do
                Tracker.SendStats()
                task.wait(Tracker.Interval)
            end
        end)
    end)

    ScreenGui.Parent = game:GetService("Players").LocalPlayer.PlayerGui
end

-- main.lua init
CreateGui()
