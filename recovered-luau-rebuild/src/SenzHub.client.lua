--!strict
-- Senz Hub - Studio-safe rebuild
-- Reconstructed from recovered Luraph/Luau artifacts.
-- This build intentionally excludes executor-only primitives and remote code execution.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
if not player then
	warn("Senz Hub must run as a LocalScript")
	return
end

local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("SenzHub")
if oldGui then
	oldGui:Destroy()
end

local COLORS = {
	Background = Color3.fromRGB(11, 20, 26),
	Panel = Color3.fromRGB(17, 31, 39),
	Panel2 = Color3.fromRGB(22, 41, 50),
	Sidebar = Color3.fromRGB(13, 27, 34),
	Accent = Color3.fromRGB(66, 190, 210),
	AccentDark = Color3.fromRGB(36, 122, 140),
	Text = Color3.fromRGB(232, 244, 247),
	Muted = Color3.fromRGB(140, 174, 184),
	Success = Color3.fromRGB(104, 214, 142),
	Warning = Color3.fromRGB(244, 192, 88),
	Danger = Color3.fromRGB(235, 99, 99),
	Stroke = Color3.fromRGB(47, 76, 86),
}

local function new(className: string, properties: {[string]: any}?, parent: Instance?): Instance
	local object = Instance.new(className)
	if properties then
		for key, value in pairs(properties) do
			(object :: any)[key] = value
		end
	end
	if parent then
		object.Parent = parent
	end
	return object
end

local function corner(parent: Instance, radius: number)
	new("UICorner", {CornerRadius = UDim.new(0, radius)}, parent)
end

local function stroke(parent: Instance, color: Color3?, thickness: number?)
	new("UIStroke", {
		Color = color or COLORS.Stroke,
		Thickness = thickness or 1,
		Transparency = 0.15,
	}, parent)
end

local screenGui = new("ScreenGui", {
	Name = "SenzHub",
	ResetOnSpawn = false,
	IgnoreGuiInset = false,
	DisplayOrder = 50,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui) :: ScreenGui

local shadow = new("Frame", {
	Name = "Shadow",
	Size = UDim2.fromOffset(656, 426),
	Position = UDim2.new(0.5, -328 + 7, 0.5, -213 + 9),
	BackgroundColor3 = Color3.new(0, 0, 0),
	BackgroundTransparency = 0.55,
	BorderSizePixel = 0,
	ZIndex = 0,
}, screenGui) :: Frame
corner(shadow, 14)

local main = new("Frame", {
	Name = "Main",
	Size = UDim2.fromOffset(656, 426),
	Position = UDim2.new(0.5, -328, 0.5, -213),
	BackgroundColor3 = COLORS.Background,
	BorderSizePixel = 0,
	ClipsDescendants = true,
	Active = true,
}, screenGui) :: Frame
corner(main, 14)
stroke(main, COLORS.Stroke, 1)

local topbar = new("Frame", {
	Name = "Topbar",
	Size = UDim2.new(1, 0, 0, 58),
	BackgroundColor3 = COLORS.Panel,
	BorderSizePixel = 0,
	Active = true,
}, main) :: Frame

local logo = new("Frame", {
	Size = UDim2.fromOffset(34, 34),
	Position = UDim2.fromOffset(15, 12),
	BackgroundColor3 = COLORS.Accent,
	BorderSizePixel = 0,
}, topbar) :: Frame
corner(logo, 9)
new("TextLabel", {
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	Text = "S",
	TextColor3 = Color3.fromRGB(7, 31, 37),
	Font = Enum.Font.GothamBold,
	TextSize = 20,
}, logo)

new("TextLabel", {
	Size = UDim2.fromOffset(230, 24),
	Position = UDim2.fromOffset(60, 9),
	BackgroundTransparency = 1,
	Text = "Senz Hub",
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = COLORS.Text,
	Font = Enum.Font.GothamBold,
	TextSize = 18,
}, topbar)

new("TextLabel", {
	Size = UDim2.fromOffset(280, 18),
	Position = UDim2.fromOffset(60, 31),
	BackgroundTransparency = 1,
	Text = "Recovered • Studio-safe build",
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = COLORS.Muted,
	Font = Enum.Font.Gotham,
	TextSize = 11,
}, topbar)

local function topButton(text: string, xOffset: number, hoverColor: Color3): TextButton
	local button = new("TextButton", {
		Size = UDim2.fromOffset(34, 34),
		Position = UDim2.new(1, xOffset, 0, 12),
		BackgroundColor3 = COLORS.Panel2,
		BorderSizePixel = 0,
		Text = text,
		TextColor3 = COLORS.Muted,
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		AutoButtonColor = false,
	}, topbar) :: TextButton
	corner(button, 8)
	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.12), {BackgroundColor3 = hoverColor, TextColor3 = COLORS.Text}):Play()
	end)
	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.12), {BackgroundColor3 = COLORS.Panel2, TextColor3 = COLORS.Muted}):Play()
	end)
	return button
end

local minimizeButton = topButton("—", -82, COLORS.AccentDark)
local closeButton = topButton("×", -42, COLORS.Danger)

local sidebar = new("Frame", {
	Name = "Sidebar",
	Size = UDim2.new(0, 156, 1, -58),
	Position = UDim2.fromOffset(0, 58),
	BackgroundColor3 = COLORS.Sidebar,
	BorderSizePixel = 0,
}, main) :: Frame

local content = new("Frame", {
	Name = "Content",
	Size = UDim2.new(1, -156, 1, -58),
	Position = UDim2.fromOffset(156, 58),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
}, main) :: Frame

local tabHolder = new("Frame", {
	Size = UDim2.new(1, -20, 1, -24),
	Position = UDim2.fromOffset(10, 14),
	BackgroundTransparency = 1,
}, sidebar) :: Frame
new("UIListLayout", {
	Padding = UDim.new(0, 7),
	SortOrder = Enum.SortOrder.LayoutOrder,
}, tabHolder)

local pages: {[string]: Frame} = {}
local tabButtons: {[string]: TextButton} = {}

local function makePage(name: string): Frame
	local page = new("Frame", {
		Name = name .. "Page",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = false,
	}, content) :: Frame
	pages[name] = page
	return page
end

local function selectTab(name: string)
	for pageName, page in pairs(pages) do
		page.Visible = pageName == name
	end
	for buttonName, button in pairs(tabButtons) do
		local selected = buttonName == name
		TweenService:Create(button, TweenInfo.new(0.14), {
			BackgroundColor3 = selected and COLORS.AccentDark or COLORS.Sidebar,
			TextColor3 = selected and COLORS.Text or COLORS.Muted,
		}):Play()
	end
end

local function makeTab(name: string, order: number): TextButton
	local button = new("TextButton", {
		Name = name,
		Size = UDim2.new(1, 0, 0, 38),
		BackgroundColor3 = COLORS.Sidebar,
		BorderSizePixel = 0,
		Text = "  " .. name,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = COLORS.Muted,
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		AutoButtonColor = false,
		LayoutOrder = order,
	}, tabHolder) :: TextButton
	corner(button, 8)
	tabButtons[name] = button
	button.Activated:Connect(function()
		selectTab(name)
	end)
	return button
end

local function pageTitle(page: Frame, title: string, subtitle: string)
	new("TextLabel", {
		Size = UDim2.new(1, -36, 0, 26),
		Position = UDim2.fromOffset(20, 17),
		BackgroundTransparency = 1,
		Text = title,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = COLORS.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 20,
	}, page)
	new("TextLabel", {
		Size = UDim2.new(1, -36, 0, 20),
		Position = UDim2.fromOffset(20, 44),
		BackgroundTransparency = 1,
		Text = subtitle,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = COLORS.Muted,
		Font = Enum.Font.Gotham,
		TextSize = 11,
	}, page)
end

local function makeCard(parent: Instance, position: UDim2, size: UDim2, title: string, value: string, valueColor: Color3?): Frame
	local card = new("Frame", {
		Position = position,
		Size = size,
		BackgroundColor3 = COLORS.Panel,
		BorderSizePixel = 0,
	}, parent) :: Frame
	corner(card, 10)
	stroke(card, COLORS.Stroke, 1)
	new("TextLabel", {
		Size = UDim2.new(1, -22, 0, 18),
		Position = UDim2.fromOffset(11, 10),
		BackgroundTransparency = 1,
		Text = title,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = COLORS.Muted,
		Font = Enum.Font.GothamMedium,
		TextSize = 11,
	}, card)
	new("TextLabel", {
		Name = "Value",
		Size = UDim2.new(1, -22, 0, 28),
		Position = UDim2.fromOffset(11, 28),
		BackgroundTransparency = 1,
		Text = value,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = valueColor or COLORS.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 17,
	}, card)
	return card
end

local function actionButton(parent: Instance, text: string, position: UDim2, size: UDim2): TextButton
	local button = new("TextButton", {
		Position = position,
		Size = size,
		BackgroundColor3 = COLORS.Panel2,
		BorderSizePixel = 0,
		Text = text,
		TextColor3 = COLORS.Text,
		Font = Enum.Font.GothamMedium,
		TextSize = 12,
		AutoButtonColor = false,
	}, parent) :: TextButton
	corner(button, 8)
	stroke(button, COLORS.Stroke, 1)
	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.12), {BackgroundColor3 = COLORS.AccentDark}):Play()
	end)
	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.12), {BackgroundColor3 = COLORS.Panel2}):Play()
	end)
	return button
end

local home = makePage("Home")
pageTitle(home, "Dashboard", "Senz Hub runtime and reconstruction status")

makeCard(home, UDim2.fromOffset(20, 82), UDim2.fromOffset(144, 72), "Environment", RunService:IsStudio() and "Studio" or "Client", COLORS.Success)
makeCard(home, UDim2.fromOffset(174, 82), UDim2.fromOffset(144, 72), "Recovered", "55 prototypes", COLORS.Accent)
makeCard(home, UDim2.fromOffset(328, 82), UDim2.fromOffset(144, 72), "VM instructions", "10,413", COLORS.Accent)

local summary = new("Frame", {
	Position = UDim2.fromOffset(20, 169),
	Size = UDim2.new(1, -40, 0, 156),
	BackgroundColor3 = COLORS.Panel,
	BorderSizePixel = 0,
}, home) :: Frame
corner(summary, 10)
stroke(summary, COLORS.Stroke, 1)
new("TextLabel", {
	Size = UDim2.new(1, -24, 0, 22),
	Position = UDim2.fromOffset(12, 11),
	BackgroundTransparency = 1,
	Text = "Build status",
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = COLORS.Text,
	Font = Enum.Font.GothamBold,
	TextSize = 14,
}, summary)
new("TextLabel", {
	Size = UDim2.new(1, -24, 1, -44),
	Position = UDim2.fromOffset(12, 38),
	BackgroundTransparency = 1,
	TextWrapped = true,
	TextYAlignment = Enum.TextYAlignment.Top,
	TextXAlignment = Enum.TextXAlignment.Left,
	Text = "Studio-safe menu build is active. Executor-only primitives and remote code execution are not included. Recovered Path2D APIs are exposed in the Path2D tab.",
	TextColor3 = COLORS.Muted,
	Font = Enum.Font.Gotham,
	TextSize = 12,
}, summary)

local pathPage = makePage("Path2D")
pageTitle(pathPage, "Path2D", "Recovered path APIs rebuilt with normal Roblox objects")

local preview = new("Frame", {
	Position = UDim2.fromOffset(20, 78),
	Size = UDim2.new(1, -40, 0, 184),
	BackgroundColor3 = Color3.fromRGB(8, 17, 22),
	BorderSizePixel = 0,
	ClipsDescendants = true,
}, pathPage) :: Frame
corner(preview, 10)
stroke(preview, COLORS.Stroke, 1)

for i = 1, 6 do
	new("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, i / 7, 0),
		BackgroundColor3 = Color3.fromRGB(28, 48, 56),
		BackgroundTransparency = 0.55,
		BorderSizePixel = 0,
	}, preview)
end

local pathStatus = new("TextLabel", {
	Size = UDim2.new(1, -24, 0, 24),
	Position = UDim2.fromOffset(12, 8),
	BackgroundTransparency = 1,
	Text = "Initializing Path2D…",
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = COLORS.Muted,
	Font = Enum.Font.Gotham,
	TextSize = 11,
	ZIndex = 4,
}, preview) :: TextLabel

local dot = new("Frame", {
	Name = "PathMarker",
	Size = UDim2.fromOffset(13, 13),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = COLORS.Accent,
	BorderSizePixel = 0,
	ZIndex = 5,
}, preview) :: Frame
corner(dot, 99)
stroke(dot, Color3.fromRGB(186, 247, 255), 1)

local path: any = nil
local pathReady = false
local defaultPoints: {any} = {}

local function makePoint(xScale: number, yScale: number): any
	return Path2DControlPoint.new(UDim2.fromScale(xScale, yScale))
end

local pathOk, pathError = pcall(function()
	path = Instance.new("Path2D")
	path.Name = "RecoveredPath2D"
	path.Color3 = COLORS.Accent
	path.Thickness = 3
	path.Visible = true
	path.ZIndex = 2
	path.Parent = preview

	defaultPoints = {
		makePoint(0.08, 0.72),
		makePoint(0.30, 0.24),
		makePoint(0.56, 0.72),
		makePoint(0.78, 0.30),
		makePoint(0.93, 0.61),
	}
	path:SetControlPoints(defaultPoints)
	pathReady = true
	pathStatus.Text = string.format("Path2D ready • %.1f px", path:GetLength())
	pathStatus.TextColor3 = COLORS.Success
end)

if not pathOk then
	pathStatus.Text = "Path2D unavailable: " .. tostring(pathError)
	pathStatus.TextColor3 = COLORS.Warning
	dot.Visible = false
end

local animationEnabled = true
local pathT = 0
local pathSpeed = 0.18

local toggleButton = actionButton(pathPage, "Animation: ON", UDim2.fromOffset(20, 278), UDim2.fromOffset(136, 38))
local randomButton = actionButton(pathPage, "Randomize", UDim2.fromOffset(166, 278), UDim2.fromOffset(108, 38))
local resetButton = actionButton(pathPage, "Reset path", UDim2.fromOffset(284, 278), UDim2.fromOffset(104, 38))
local slowerButton = actionButton(pathPage, "− Speed", UDim2.fromOffset(398, 278), UDim2.fromOffset(80, 38))
local fasterButton = actionButton(pathPage, "+ Speed", UDim2.fromOffset(398, 324), UDim2.fromOffset(80, 38))

local speedLabel = new("TextLabel", {
	Position = UDim2.fromOffset(20, 327),
	Size = UDim2.fromOffset(355, 30),
	BackgroundTransparency = 1,
	Text = string.format("Animation speed: %.2f", pathSpeed),
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = COLORS.Muted,
	Font = Enum.Font.Gotham,
	TextSize = 12,
}, pathPage) :: TextLabel

toggleButton.Activated:Connect(function()
	animationEnabled = not animationEnabled
	toggleButton.Text = animationEnabled and "Animation: ON" or "Animation: OFF"
	toggleButton.BackgroundColor3 = animationEnabled and COLORS.AccentDark or COLORS.Panel2
end)

randomButton.Activated:Connect(function()
	if not pathReady then
		return
	end
	local rng = Random.new()
	local points = {
		makePoint(0.06, rng:NextNumber(0.25, 0.78)),
		makePoint(0.27, rng:NextNumber(0.15, 0.83)),
		makePoint(0.50, rng:NextNumber(0.15, 0.83)),
		makePoint(0.73, rng:NextNumber(0.15, 0.83)),
		makePoint(0.94, rng:NextNumber(0.25, 0.78)),
	}
	path:SetControlPoints(points)
	pathStatus.Text = string.format("Randomized • %.1f px", path:GetLength())
end)

resetButton.Activated:Connect(function()
	if pathReady then
		path:SetControlPoints(defaultPoints)
		pathT = 0
		pathStatus.Text = string.format("Reset • %.1f px", path:GetLength())
	end
end)

slowerButton.Activated:Connect(function()
	pathSpeed = math.max(0.04, pathSpeed - 0.04)
	speedLabel.Text = string.format("Animation speed: %.2f", pathSpeed)
end)

fasterButton.Activated:Connect(function()
	pathSpeed = math.min(1, pathSpeed + 0.04)
	speedLabel.Text = string.format("Animation speed: %.2f", pathSpeed)
end)

local runtimePage = makePage("Runtime")
pageTitle(runtimePage, "Runtime", "Confirmed globals and protected-environment compatibility")

local runtimeBox = new("Frame", {
	Position = UDim2.fromOffset(20, 78),
	Size = UDim2.new(1, -40, 0, 236),
	BackgroundColor3 = COLORS.Panel,
	BorderSizePixel = 0,
}, runtimePage) :: Frame
corner(runtimeBox, 10)
stroke(runtimeBox, COLORS.Stroke, 1)

new("TextLabel", {
	Size = UDim2.new(1, -24, 1, -24),
	Position = UDim2.fromOffset(12, 12),
	BackgroundTransparency = 1,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
	TextWrapped = true,
	Text = "AVAILABLE IN THIS BUILD\n  game, workspace, Instance, Random, Vector2, Vector3, CFrame, UDim, UDim2, Enum, task, coroutine, string, table, math, utf8, bit32\n\nRECOVERED ROBLOX SERVICES/APIS\n  RunService, HttpService, StarterPlayer, Path2D, Path2DControlPoint\n  GetLength, GetPositionOnCurve, GetPositionOnCurveArcLength, GetTangentOnCurve, SetControlPoints\n\nNOT RECREATED\n  identifyexecutor, islclosure, iscclosure, loadstring, getfenv, setfenv",
	TextColor3 = COLORS.Muted,
	Font = Enum.Font.Code,
	TextSize = 11,
	LineHeight = 1.25,
}, runtimeBox)

local aboutPage = makePage("About")
pageTitle(aboutPage, "About", "What was actually recoverable from the protected source")

local aboutCard = new("Frame", {
	Position = UDim2.fromOffset(20, 78),
	Size = UDim2.new(1, -40, 0, 230),
	BackgroundColor3 = COLORS.Panel,
	BorderSizePixel = 0,
}, aboutPage) :: Frame
corner(aboutCard, 10)
stroke(aboutCard, COLORS.Stroke, 1)
new("TextLabel", {
	Size = UDim2.new(1, -28, 1, -28),
	Position = UDim2.fromOffset(14, 14),
	BackgroundTransparency = 1,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
	TextWrapped = true,
	Text = "Senz Hub is a clean rebuild around the behavior that can be verified from the recovered artifacts.\n\nThe virtualized file yielded 55 prototypes and 10,413 VM instructions. Names/comments from the original source were not preserved by virtualization, so the exact pre-obfuscation file cannot be recreated byte-for-byte.\n\nThis menu replaces the unusable VM/executor wrapper with normal Roblox UI and API calls.\n\nRightShift toggles the menu.",
	TextColor3 = COLORS.Muted,
	Font = Enum.Font.Gotham,
	TextSize = 12,
	LineHeight = 1.35,
}, aboutCard)

makeTab("Home", 1)
makeTab("Path2D", 2)
makeTab("Runtime", 3)
makeTab("About", 4)
selectTab("Home")

local dragging = false
local dragStart = Vector2.zero
local startPosition = main.Position

local function syncShadow()
	shadow.Position = UDim2.new(
		main.Position.X.Scale,
		main.Position.X.Offset + 7,
		main.Position.Y.Scale,
		main.Position.Y.Offset + 9
	)
end

topbar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = Vector2.new(input.Position.X, input.Position.Y)
		startPosition = main.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local currentPosition = Vector2.new(input.Position.X, input.Position.Y)
		local delta = currentPosition - dragStart
		main.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
		syncShadow()
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

local minimized = false
local fullSize = main.Size
minimizeButton.Activated:Connect(function()
	minimized = not minimized
	if minimized then
		sidebar.Visible = false
		content.Visible = false
		TweenService:Create(main, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Size = UDim2.fromOffset(656, 58)}):Play()
		TweenService:Create(shadow, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Size = UDim2.fromOffset(656, 58)}):Play()
	else
		TweenService:Create(main, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Size = fullSize}):Play()
		TweenService:Create(shadow, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Size = fullSize}):Play()
		task.delay(0.16, function()
			if main.Parent and not minimized then
				sidebar.Visible = true
				content.Visible = true
			end
		end)
	end
end)

closeButton.Activated:Connect(function()
	screenGui:Destroy()
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end
	if input.KeyCode == Enum.KeyCode.RightShift then
		screenGui.Enabled = not screenGui.Enabled
	end
end)

local heartbeatConnection: RBXScriptConnection? = nil
heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
	if not screenGui.Parent then
		if heartbeatConnection then
			heartbeatConnection:Disconnect()
		end
		return
	end
	if pathReady and animationEnabled then
		pathT = (pathT + dt * pathSpeed) % 1
		local ok, position = pcall(function()
			return path:GetPositionOnCurveArcLength(pathT)
		end)
		if ok then
			dot.Position = position
		end
	end
end)

print("[Senz Hub] Studio-safe menu loaded")
