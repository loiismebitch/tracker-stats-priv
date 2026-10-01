-- Studio-safe runtime shim for recovered Luraph/Luau code.

local Runtime = {}

Runtime.game = game
Runtime.workspace = workspace
Runtime.Instance = Instance
Runtime.Random = Random
Runtime.Vector2 = Vector2
Runtime.Vector3 = Vector3
Runtime.CFrame = CFrame
Runtime.UDim = UDim
Runtime.UDim2 = UDim2
Runtime.Enum = Enum
Runtime.task = task
Runtime.coroutine = coroutine
Runtime.string = string
Runtime.table = table
Runtime.math = math
Runtime.utf8 = utf8
Runtime.bit32 = bit32

function Runtime.GetService(name)
    return game:GetService(name)
end

local function blocked(name)
    return function()
        error(("Unsupported executor/protector primitive in Studio-safe build: %s"):format(name), 2)
    end
end

Runtime.loadstring = blocked("loadstring")
Runtime.identifyexecutor = blocked("identifyexecutor")
Runtime.islclosure = blocked("islclosure")
Runtime.iscclosure = blocked("iscclosure")
Runtime.getfenv = blocked("getfenv")
Runtime.setfenv = blocked("setfenv")

function Runtime.GetHttpService()
    return game:GetService("HttpService")
end

function Runtime.BlockNetworkCall(method)
    error(("Recovered code attempted network method %s. Review the call site before enabling it."):format(tostring(method)), 2)
end

return Runtime
