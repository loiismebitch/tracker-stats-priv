--[[ 
  Grow a Garden – Tracker (one-file)
  by you + gpt
  Tính năng:
   - GUI đẹp, có nút mở/đóng + hotkey (RightShift)
   - Nhập webhook Discord + set interval (giây)
   - Bật/tắt từng tracker: Seeds / Sprinklers / Egg / Stats cơ bản
   - Gửi Embed về Discord
   - Lưu/khôi phục config (nếu executor hỗ trợ writefile)

  Lưu ý:
   - Các hàm lấy dữ liệu (getBestSeed/getBestSprinkler…) có sẵn stub + auto-guess path.
     Nếu game đổi path, script vẫn chạy (chỉ gửi “(unknown)” cho phần không lấy được).
]]

-----------------------
-- Services / Helpers
-----------------------
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- request compatibility
local http_request = http_request or (syn and syn.request) or (fluxus and fluxus.request) or request
local function can_request() return typeof(http_request) == "function" end

-- file IO compatibility
local CAN_SAVE = (writefile and readfile and isfile) and true or false
local CFG_PATH = "gagt_config.json"

local function safe_pcall(fn, ...)
    local ok, res = pcall(fn, ...)
    if not ok then
        warn("[Tracker] error:", res)
        return nil
    end
    return res
end

-----------------------
-- Config & State
-----------------------
local Config = {
    webhook = "",
    interval = 15,
    trackSeeds = true,
    trackSprinklers = true,
    trackEgg = true,
    trackStats = true,
}

local State = {
    running = false,
    loopThread = nil,
    lastEggOpened = nil,
}

local function load_config()
    if not CAN_SAVE or not isfile(CFG_PATH) then return end
    local raw = safe_pcall(readfile, CFG_PATH)
    if not raw then return end
    local ok, data = pcall(function() return HttpService:JSONDecode(raw) end)
    if ok and type(data) == "table" then
        for k,v in pairs(data) do
            if Config[k] ~= nil then Config[k] = v end
        end
    end
end

local function save_config()
    if not CAN_SAVE then return end
    local raw = HttpService:JSONEncode(Config)
    safe_pcall(writefile, CFG_PATH, raw)
end

load_config()

-----------------------
-- Data Grabbers (best-effort)
-----------------------
-- NOTE: Nếu mày biết path chính xác, sửa trong mấy hàm này cho “chuẩn game”.
local function getPlayerDataRoot()
    -- thử vài nơi hay thấy dùng
    local root = LocalPlayer:FindFirstChild("PlayerData") or LocalPlayer:FindFirstChild("Data") or LocalPlayer:FindFirstChild("Stats")
    return root
end

local function getBestSeed()
    -- cố gắng đọc inventory seeds của người chơi
    local root = getPlayerDataRoot()
    if not root then return "(unknown)" end

    -- ví dụ: root.Inventory.Seeds:Folder với các Instance tên seed
    local inv = root:FindFirstChild("Inventory")
    if inv and inv:FindFirstChild("Seeds") then
        local seedsFolder = inv.Seeds
        local bestName, bestScore = nil, -1

        for _, item in ipairs(seedsFolder:GetChildren()) do
            -- heuristic điểm: ưu tiên prismatic/legendary name keywords, có thể chỉnh theo wiki
            local name = item.Name
            local score = 1
            local n = name:lower()
            if n:find("romanesco") then score = score + 100 end
            if n:find("grand") or n:find("myth") or n:find("prism") then score = score + 50 end
            if n:find("gold") then score = score + 20 end
            if score > bestScore then
                bestScore = score
                bestName = name
            end
        end

        return bestName or "(unknown)"
    end

    return "(unknown)"
end

local function getBestSprinkler()
    -- tìm trong Inventory.Sprinklers (nếu có)
    local root = getPlayerDataRoot()
    if not root then return "(unknown)" end
    local inv = root:FindFirstChild("Inventory")
    if inv then
        local folders = {"Sprinklers", "Gears", "Items"}
        local best, score = nil, -1
        for _, fname in ipairs(folders) do
            local f = inv:FindFirstChild(fname)
            if f then
                for _, it in ipairs(f:GetChildren()) do
                    local n = it.Name:lower()
                    local s = 0
                    if n:find("grandmaster") then s = 100
                    elseif n:find("master") then s = 80
                    elseif n:find("godly") then s = 60
                    elseif n:find("advanced") then s = 40
                    elseif n:find("basic") then s = 20
                    end
                    if s > score then best, score = it.Name, s end
                end
            end
        end
        return best or "(unknown)"
    end
    return "(unknown)"
end

-- Hook sự kiện mở trứng nếu có Remote đặt trong ReplicatedStorage
do
    local candidates = {"EggOpened","EggOpen","OnEggOpened","Eggs","Remotes","Events"}
    for _, name in ipairs(candidates) do
        local obj = ReplicatedStorage:FindFirstChild(name, true)
        if obj and obj:IsA("RemoteEvent") then
            safe_pcall(function()
                obj.OnClientEvent:Connect(function(eggName, petName, rarity)
                    State.lastEggOpened = {
                        egg = tostring(eggName or "Unknown Egg"),
                        pet = tostring(petName or "Unknown Pet"),
                        rarity = tostring(rarity or "Unknown")
                    }
                end)
            end)
        end
    end
end

local function getLastEggInfo()
    local e = State.lastEggOpened
    if not e then return "(no egg opened yet)" end
    return string.format("Egg: %s\nPet: %s\nRarity: %s", e.egg, e.pet, e.rarity)
end

local function getBasicStats()
    local coins = 0
    local level = 0
    local root = getPlayerDataRoot()
    if root then
        local vCoins = root:FindFirstChild("Coins") or root:FindFirstChild("Money") or root:FindFirstChild("Cash")
        local vLevel = root:FindFirstChild("Level") or root:FindFirstChild("LVL")
        if vCoins and vCoins.Value then coins = vCoins.Value end
        if vLevel and vLevel.Value then level = vLevel.Value end
    end
    return string.format("Coins: %s\nLevel: %s", tostring(coins), tostring(level))
end

-----------------------
-- Discord Sender
-----------------------
local function send_embed(title, description, color)
    if not can_request() or Config.webhook == "" then return end
    local payload = {
        embeds = {{
            title = title,
            description = description,
            color = color or 3447003,
            footer = { text = "Grow a Garden Tracker" },
            timestamp = DateTime.now():ToIsoDate()
        }}
    }
    http_request({
        Url = Config.webhook,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode(payload)
    })
end

local function send_report()
    local fields = {}

    if Config.trackSeeds then
        table.insert(fields, ("**Best Seed:** `%s`"):format(getBestSeed()))
    end
    if Config.trackSprinklers then
        table.insert(fields, ("**Best Sprinkler:** `%s`"):format(getBestSprinkler()))
    end
    if Config.trackEgg then
        table.insert(fields, ("**Last Egg:**\n%s"):format(getLastEggInfo()))
    end
    if Config.trackStats then
        table.insert(fields, ("**Stats:**\n%s"):format(getBasicStats()))
    end

    local desc = ("Player: **%s**\n%s"):format(LocalPlayer.Name, table.concat(fields, "\n\n"))
    send_embed("🌱 Tracker Report", desc, 65280)
end

-----------------------
-- Loop Control
-----------------------
local function start_tracker()
    if State.running then return end
    State.running = true
    save_config()
    send_embed("✅ Tracker Started", ("Interval: %ss"):format(Config.interval), 3066993)

    State.loopThread = task.spawn(function()
        while State.running do
            safe_pcall(send_report)
            task.wait(tonumber(Config.interval) or 15)
        end
    end)
end

local function stop_tracker()
    if not State.running then return end
    State.running = false
    if State.loopThread then
        task.cancel(State.loopThread)
        State.loopThread = nil
    end
    send_embed("⏹ Tracker Stopped", "Paused by user.", 15158332)
end

-----------------------
-- GUI (modern-ish)
-----------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GAGT_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Toggle pill
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "Toggle"
ToggleBtn.Size = UDim2.new(0, 130, 0, 40)
ToggleBtn.Position = UDim2.new(0, 16, 0.5, -20)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
ToggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14
ToggleBtn.Text = "🌱 Tracker"
ToggleBtn.AutoButtonColor = true
ToggleBtn.Parent = ScreenGui
do
    local c = Instance.new("UICorner", ToggleBtn) c.CornerRadius = UDim.new(0, 10)
end

-- Main panel
local Panel = Instance.new("Frame")
Panel.Name = "Panel"
Panel.Size = UDim2.new(0, 380, 0, 330)
Panel.Position = UDim2.new(0.5, -190, 0.5, -165)
Panel.BackgroundColor3 = Color3.fromRGB(30,30,30)
Panel.Visible = false
Panel.Active = true
Panel.Draggable = true
Panel.Parent = ScreenGui
do
    local c = Instance.new("UICorner", Panel) c.CornerRadius = UDim.new(0,12)
end

-- Header
local Header = Instance.new("TextLabel")
Header.Size = UDim2.new(1, -20, 0, 40)
Header.Position = UDim2.new(0, 10, 0, 8)
Header.BackgroundTransparency = 1
Header.Text = "🌱 Grow a Garden Tracker"
Header.TextColor3 = Color3.fromRGB(0, 255, 128)
Header.Font = Enum.Font.GothamBold
Header.TextSize = 18
Header.Parent = Panel

-- Container
local Body = Instance.new("Frame")
Body.Size = UDim2.new(1, -20, 1, -60)
Body.Position = UDim2.new(0, 10, 0, 50)
Body.BackgroundTransparency = 1
Body.Parent = Panel

local List = Instance.new("UIListLayout")
List.Padding = UDim.new(0, 8)
List.SortOrder = Enum.SortOrder.LayoutOrder
List.Parent = Body

-- Webhook box
local WebhookBox = Instance.new("TextBox")
WebhookBox.Size = UDim2.new(1, 0, 0, 36)
WebhookBox.PlaceholderText = "Discord Webhook URL…"
WebhookBox.Text = Config.webhook
WebhookBox.TextColor3 = Color3.fromRGB(255,255,255)
WebhookBox.Font = Enum.Font.Gotham
WebhookBox.TextSize = 14
WebhookBox.BackgroundColor3 = Color3.fromRGB(45,45,45)
WebhookBox.ClearTextOnFocus = false
WebhookBox.Parent = Body
Instance.new("UICorner", WebhookBox).CornerRadius = UDim.new(0,8)

-- Interval box
local IntervalBox = Instance.new("TextBox")
IntervalBox.Size = UDim2.new(1, 0, 0, 36)
IntervalBox.PlaceholderText = "Interval seconds (default 15)"
IntervalBox.Text = tostring(Config.interval or 15)
IntervalBox.TextColor3 = Color3.fromRGB(255,255,255)
IntervalBox.Font = Enum.Font.Gotham
IntervalBox.TextSize = 14
IntervalBox.BackgroundColor3 = Color3.fromRGB(45,45,45)
IntervalBox.ClearTextOnFocus = false
IntervalBox.Parent = Body
Instance.new("UICorner", IntervalBox).CornerRadius = UDim.new(0,8)

-- Toggle row helper
local function makeToggle(text, defaultOn)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = defaultOn and Color3.fromRGB(0,130,70) or Color3.fromRGB(60,60,60)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Text = (defaultOn and "✅ " or "❌ ") .. text
    btn.AutoButtonColor = true
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
    btn.Parent = Body
    return btn
end

local SeedsT = makeToggle("Track Best Seed", Config.trackSeeds)
local SprinkT = makeToggle("Track Best Sprinkler", Config.trackSprinklers)
local EggT   = makeToggle("Track Last Egg Opened", Config.trackEgg)
local StatsT = makeToggle("Track Basic Stats (coins/level)", Config.trackStats)

local function toggle(btn, flagName)
    Config[flagName] = not Config[flagName]
    btn.BackgroundColor3 = Config[flagName] and Color3.fromRGB(0,130,70) or Color3.fromRGB(60,60,60)
    btn.Text = (Config[flagName] and "✅ " or "❌ ") .. btn.Text:gsub("✅ ",""):gsub("❌ ","")
    save_config()
end

SeedsT.MouseButton1Click:Connect(function() toggle(SeedsT, "trackSeeds") end)
SprinkT.MouseButton1Click:Connect(function() toggle(SprinkT, "trackSprinklers") end)
EggT.MouseButton1Click:Connect(function() toggle(EggT, "trackEgg") end)
StatsT.MouseButton1Click:Connect(function() toggle(StatsT, "trackStats") end)

-- Buttons row
local Row = Instance.new("Frame")
Row.Size = UDim2.new(1, 0, 0, 40)
Row.BackgroundTransparency = 1
Row.Parent = Body
local RowList = Instance.new("UIListLayout", Row)
RowList.FillDirection = Enum.FillDirection.Horizontal
RowList.Padding = UDim.new(0,8)

local SaveBtn = Instance.new("TextButton")
SaveBtn.Size = UDim2.new(0.5, -4, 1, 0)
SaveBtn.BackgroundColor3 = Color3.fromRGB(0,160,90)
SaveBtn.TextColor3 = Color3.fromRGB(255,255,255)
SaveBtn.Font = Enum.Font.GothamBold
SaveBtn.TextSize = 14
SaveBtn.Text = "💾 Save"
SaveBtn.Parent = Row
Instance.new("UICorner", SaveBtn).CornerRadius = UDim.new(0,8)

local TestBtn = Instance.new("TextButton")
TestBtn.Size = UDim2.new(0.5, -4, 1, 0)
TestBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
TestBtn.TextColor3 = Color3.fromRGB(255,255,255)
TestBtn.Font = Enum.Font.GothamBold
TestBtn.TextSize = 14
TestBtn.Text = "🧪 Send Test"
TestBtn.Parent = Row
Instance.new("UICorner", TestBtn).CornerRadius = UDim.new(0,8)

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 26)
Status.BackgroundTransparency = 1
Status.TextColor3 = Color3.fromRGB(200,200,200)
Status.Font = Enum.Font.Gotham
Status.TextSize = 14
Status.Text = State.running and "Status: Running" or "Status: Idle"
Status.Parent = Body

local StartBtn = Instance.new("TextButton")
StartBtn.Size = UDim2.new(1, 0, 0, 36)
StartBtn.BackgroundColor3 = Color3.fromRGB(0,170,85)
StartBtn.TextColor3 = Color3.fromRGB(255,255,255)
StartBtn.Font = Enum.Font.GothamBold
StartBtn.TextSize = 15
StartBtn.Text = "▶ Start"
StartBtn.Parent = Body
Instance.new("UICorner", StartBtn).CornerRadius = UDim.new(0,8)

local StopBtn = Instance.new("TextButton")
StopBtn.Size = UDim2.new(1, 0, 0, 36)
StopBtn.BackgroundColor3 = Color3.fromRGB(170,0,0)
StopBtn.TextColor3 = Color3.fromRGB(255,255,255)
StopBtn.Font = Enum.Font.GothamBold
StopBtn.TextSize = 15
StopBtn.Text = "⏹ Stop"
StopBtn.Parent = Body
Instance.new("UICorner", StopBtn).CornerRadius = UDim.new(0,8)

-- GUI events
ToggleBtn.MouseButton1Click:Connect(function()
    Panel.Visible = not Panel.Visible
end)

-- hotkey RightShift để mở/đóng
local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.RightShift then
        Panel.Visible = not Panel.Visible
    end
end)

SaveBtn.MouseButton1Click:Connect(function()
    Config.webhook = WebhookBox.Text or ""
    Config.interval = tonumber(IntervalBox.Text) or 15
    save_config()
    Status.Text = ("Saved. Interval: %ss"):format(Config.interval)
    Status.TextColor3 = Color3.fromRGB(0,255,170)
end)

TestBtn.MouseButton1Click:Connect(function()
    Config.webhook = WebhookBox.Text or ""
    if Config.webhook == "" then
        Status.Text = "Set webhook first!"
        Status.TextColor3 = Color3.fromRGB(255,120,120)
        return
    end
    send_embed("🧪 Test", "Webhook connected. If you see this, everything works!", 16776960)
    Status.Text = "Test sent."
    Status.TextColor3 = Color3.fromRGB(0,255,170)
end)

StartBtn.MouseButton1Click:Connect(function()
    Config.webhook = WebhookBox.Text or ""
    Config.interval = tonumber(IntervalBox.Text) or 15
    if Config.webhook == "" then
        Status.Text = "Please paste Discord Webhook."
        Status.TextColor3 = Color3.fromRGB(255,120,120)
        return
    end
    start_tracker()
    Status.Text = "Status: Running"
    Status.TextColor3 = Color3.fromRGB(0,255,0)
end)

StopBtn.MouseButton1Click:Connect(function()
    stop_tracker()
    Status.Text = "Status: Stopped"
    Status.TextColor3 = Color3.fromRGB(255,90,90)
end)

-- small hello
task.delay(0.2, function()
    if Config.webhook ~= "" then
        WebhookBox.Text = Config.webhook
    end
    IntervalBox.Text = tostring(Config.interval or 15)
end)
