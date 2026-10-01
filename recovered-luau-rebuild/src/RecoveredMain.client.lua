-- Recovered project entry point (Studio-safe scaffold)

local Runtime = require(script.Parent:WaitForChild("RuntimeSafe"))

local RunService = Runtime.GetService("RunService")
local HttpService = Runtime.GetHttpService()
local StarterPlayer = Runtime.GetService("StarterPlayer")

local function main()
    -- Deliberately no executor/protector bootstrap here.
    print("Recovered Studio-safe scaffold loaded", RunService:IsStudio())
end

main()
