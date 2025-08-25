-- Services
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Biến webhook (mặc định rỗng, user nhập vào)
local WEBHOOK_URL = nil

-- Hàm gửi Embed
local function sendEmbed(title, description, color)
    if not WEBHOOK_URL then return end -- chưa nhập thì bỏ qua
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

-- GUI
local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.Name = "TrackerGUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 150)
frame.Position = UDim2.new(0.5, -150, 0.5, -75)
frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.Text = "Tracker Webhook Config"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1

local textbox = Instance.new("TextBox", frame)
textbox.Size = UDim2.new(1,-20,0,30)
textbox.Position = UDim2.new(0,10,0,50)
textbox.PlaceholderText = "Paste your webhook URL..."
textbox.Text = ""
textbox.BackgroundColor3 = Color3.fromRGB(60,60,60)
textbox.TextColor3 = Color3.new(1,1,1)

local button = Instance.new("TextButton", frame)
button.Size = UDim2.new(0.5,-15,0,30)
button.Position = UDim2.new(0,10,0,100)
button.Text = "Save"
button.BackgroundColor3 = Color3.fromRGB(0,170,0)
button.TextColor3 = Color3.new(1,1,1)

local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(0.5,-15,0,30)
closeBtn.Position = UDim2.new(0.5,5,0,100)
closeBtn.Text = "Close"
closeBtn.BackgroundColor3 = Color3.fromRGB(170,0,0)
closeBtn.TextColor3 = Color3.new(1,1,1)

-- Nút Save
button.MouseButton1Click:Connect(function()
    if textbox.Text ~= "" then
        WEBHOOK_URL = textbox.Text
        sendEmbed("✅ Webhook Connected", "Tracker đã kết nối tới webhook của bạn!", 65280)
    end
end)

-- Nút Close
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Ví dụ: sau khi save thì gửi test info
Players.PlayerAdded:Connect(function(plr)
    sendEmbed("👤 Player Joined", plr.Name .. " vừa vào server!", 16776960)
end)

