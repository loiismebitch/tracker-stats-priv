-- Services
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Biến lưu
local WEBHOOK_URL = nil
local TRACKER_INTERVAL = 15 -- mặc định 15s
local tracking = false

-- Hàm gửi Embed
local function sendEmbed(title, description, color)
    if not WEBHOOK_URL then return end
    local data = {
        embeds = {{
            title = title,
            description = description,
            color = color or 3447003,
            footer = { text = "Grow a Garden Tracker" },
            timestamp = DateTime.now():ToIsoDate()
        }}
    }
    request({
        Url = WEBHOOK_URL,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode(data)
    })
end

-- Giả sử Inventory / Egg info
local function getBestItems()
    -- TODO: thay bằng path inventory thực
    return "Golden Seed", "Golden Sprinkler"
end

-- GUI
local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.Name = "TrackerGUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 350, 0, 200)
frame.Position = UDim2.new(0.5, -175, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.Text = "Tracker Config"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1

-- TextBox Webhook
local webhookBox = Instance.new("TextBox", frame)
webhookBox.Size = UDim2.new(1,-20,0,30)
webhookBox.Position = UDim2.new(0,10,0,40)
webhookBox.PlaceholderText = "Paste your webhook URL..."
webhookBox.Text = ""
webhookBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
webhookBox.TextColor3 = Color3.new(1,1,1)

-- TextBox Interval
local intervalBox = Instance.new("TextBox", frame)
intervalBox.Size = UDim2.new(1,-20,0,30)
intervalBox.Position = UDim2.new(0,10,0,80)
intervalBox.PlaceholderText = "Interval (seconds)"
intervalBox.Text = tostring(TRACKER_INTERVAL)
intervalBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
intervalBox.TextColor3 = Color3.new(1,1,1)

-- Nút Save
local saveBtn = Instance.new("TextButton", frame)
saveBtn.Size = UDim2.new(0.5,-15,0,30)
saveBtn.Position = UDim2.new(0,10,0,130)
saveBtn.Text = "Save & Start"
saveBtn.BackgroundColor3 = Color3.fromRGB(0,170,0)
saveBtn.TextColor3 = Color3.new(1,1,1)

-- Nút Close
local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(0.5,-15,0,30)
closeBtn.Position = UDim2.new(0.5,5,0,130)
closeBtn.Text = "Close"
closeBtn.BackgroundColor3 = Color3.fromRGB(170,0,0)
closeBtn.TextColor3 = Color3.new(1,1,1)

-- Hàm tracker loop
local function startTracking()
    if tracking then return end
    tracking = true
    task.spawn(function()
        while tracking do
            local seed, sprinkler = getBestItems()
            sendEmbed("📦 Tracker Report",
                "Best Seed: **"..seed.."**\nBest Sprinkler: **"..sprinkler.."**",
                65280
            )
            task.wait(TRACKER_INTERVAL)
        end
    end)
end

-- Nút Save click
saveBtn.MouseButton1Click:Connect(function()
    if webhookBox.Text ~= "" then
        WEBHOOK_URL = webhookBox.Text
    end
    local interval = tonumber(intervalBox.Text)
    if interval and interval > 0 then
        TRACKER_INTERVAL = interval
    end
    sendEmbed("✅ Webhook Connected", "Tracker started! Interval: "..TRACKER_INTERVAL.."s", 3066993)
    startTracking()
end)

-- Nút Close click
closeBtn.MouseButton1Click:Connect(function()
    tracking = false
    gui:Destroy()
end)
