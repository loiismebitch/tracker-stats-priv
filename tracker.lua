-- Grow a Garden Tracker Script
-- Tác giả: Mày 😎

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local WEBHOOK_URL = "https://discord.com/api/webhooks/xxxx/xxxx"

local function sendEmbed(title, description, color)
    local data = {
        embeds = {{
            title = title,
            description = description,
            color = color or 3447003,
            footer = {
                text = "Grow a Garden Tracker"
            },
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

-- Gửi inventory
local function getBestItems()
    -- TODO: thay đúng path inventory
    return "Golden Seed", "Golden Sprinkler"
end

local seed, sprinkler = getBestItems()
sendEmbed("📦 Inventory Info", "Best Seed: **"..seed.."**\nBest Sprinkler: **"..sprinkler.."**", 65280)

-- Theo dõi mở trứng
local function setupEggTracker()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local eggEvent = ReplicatedStorage:WaitForChild("EggOpened") -- TODO: kiểm tra đúng tên event
    
    eggEvent.OnClientEvent:Connect(function(eggName, petName, rarity)
        sendEmbed("🐣 Egg Opened",
            string.format("Egg: %s\nPet: %s\nRarity: %s", eggName, petName, rarity),
            16776960
        )
    end)
end

setupEggTracker()
