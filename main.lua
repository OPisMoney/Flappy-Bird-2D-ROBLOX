--[[
	FlappyBirdRBX
	A port of Flappy Bird to Roblox.
	Created by Letho
--]]

local sgui = game:GetService("StarterGui")
local players = game:GetService("Players")
local plr = players.LocalPlayer
local pgui = plr.PlayerGui
local jumping = false
local falling = false
local gravity = 60
local failed = false
local count = 0
local safe = true
local started = false
local collided = false

local function createObject(arg1,arg2,arg3)
	local inst = Instance.new(arg1)
	if arg2 then
		inst.Parent = arg2
	end
	if arg3 then
		inst.Name = arg3
	end
	return inst
end

local function createSound(arg1,arg2,arg3,arg4)
	if arg1 and arg2 and arg3 and arg4 then
		local sound = Instance.new("Sound", arg1)
		sound.Name = arg2
		sound.Volume = arg3
		sound.SoundId = arg4
	else
		return
	end
end

local function find(arg1,arg2)
	if arg1 and arg2 then
		local descendants = arg2:GetDescendants()
		
		for index, descendant in pairs(descendants) do
			if descendant.Name == arg1 then
				return descendant
			end
		end
	else
		return
	end
end

function collides(gui1, gui2)
	local g1p, g1s = gui1.AbsolutePosition, gui1.AbsoluteSize;
	local g2p, g2s = gui2.AbsolutePosition, gui2.AbsoluteSize;
	return ((g1p.x < g2p.x + g2s.x and g1p.x + g1s.x > g2p.x) and (g1p.y < g2p.y + g2s.y and g1p.y + g1s.y > g2p.y));
end;

local function createGui()
	local ui = createObject("ScreenGui", pgui, "UI")
	local frame = createObject("Frame", ui, "Main")
	local flappygame = createObject("Frame", frame, "Game")
	local hideframe = createObject("Frame", ui, "HideFrame")
	local background = createObject("ImageLabel", flappygame, "Background")
	local pipes = createObject("Frame", flappygame, "Pipes")
	local flappy = createObject("ImageLabel", flappygame, "Flappy")
	local ground = createObject("ImageLabel", flappygame, "Ground")
	local counttext = createObject("TextLabel", flappygame, "Count")
	counttext.Text = "0"
	counttext.BackgroundTransparency = 1
	counttext.Position = UDim2.new(0.5, -100, 0, 0)
	counttext.Size = UDim2.new(0, 200, 0, 50)
	counttext.Font = Enum.Font.Arcade
	counttext.TextSize = 50
	counttext.TextColor3 = Color3.fromRGB(255,255,255)
	counttext.TextStrokeTransparency = 0
	pipes.Size = UDim2.new(1, 0, 1, 0)
	pipes.BackgroundTransparency = 1
	flappygame.ClipsDescendants = true
	ground.Size = UDim2.new(2, 0, 0, 128)
	ground.Position = UDim2.new(0, 0, 1, -68)
	ground.BorderSizePixel = 0
	ground.BackgroundColor3 = Color3.fromRGB(255,255,255)
	ground.Image = "rbxassetid://2901127087"
	ground.ScaleType = Enum.ScaleType.Tile
	ground.TileSize = UDim2.new(0, 37, 0, 128)
	createSound(ui,"Fail",1,"rbxassetid://144686858")
	createSound(ui,"Flap",1,"rbxassetid://147832032")
	createSound(ui,"Success",3,"rbxassetid://144686873")
	flappy.BackgroundTransparency = 1
	flappy.Size = UDim2.new(0, 50, 0, 40)
	flappy.Position = UDim2.new(0.5, -25, 0.5, -20)
	flappy.Image = "rbxassetid://148036904"
	background.Size = UDim2.new(1, 0, 1, -68)
	background.BackgroundColor3 = Color3.fromRGB(255,255,255)
	background.BorderSizePixel = 0
	background.Image = "rbxassetid://149868773"
	flappygame.Size = UDim2.new(0, 500, 0, 500)
	flappygame.BackgroundTransparency = 1
	flappygame.Position = UDim2.new(0.5,-250,0.5,-250)
	hideframe.Position = UDim2.new(0, 0, 0, -50)
	hideframe.Size = UDim2.new(1, 0, 0, 50)
	hideframe.BackgroundColor3 = Color3.fromRGB(0,0,0)
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
end

local function killBird()
	local ui = find("UI", pgui)
	local flappy = find("Flappy",ui)
	local flappygame = find("Background",ui)
	local flappyground = find("Ground",ui)
	local fail = find("Fail",ui)
	fail:Play()
	gravity = 60
	failed = true
	flappy:TweenPosition(UDim2.new(0.5, -25, 0.5, 150),nil,nil,0.5,true)
end

local function tweenPipe(obj)
	obj:TweenPosition(UDim2.new(-0.2, 0, 0.5, obj.Position.Y.Offset),"Out","Linear",4,false)
end

local function createPipe()
	local ui = find("UI", pgui)
	local pipes = find("Pipes",ui)
	local flappy = find("Flappy",ui)
	local success = find("Success",ui)
	local pipe = createObject("ImageLabel", pipes, "Pipe")
	pipe.BackgroundTransparency = 1
	pipe.BorderSizePixel = 0
	pipe.Position = UDim2.new(1, 0, 0.5, -math.random(400,600))
	pipe.Size = UDim2.new(0, 100, 2, 0)
	pipe.Image = "rbxassetid://2901432990"
	local df = createObject("Frame", pipe, "DeadFrame")
	df.BackgroundTransparency = 1
	df.Position = UDim2.new(0, 0, 0.5, -65)
	df.Size = UDim2.new(0, 100, 0, 125)
	spawn(function() -- pipe move stuff
		while true do
			wait(0.01)
			tweenPipe(pipe)
			if failed == true then
				break
			end
			if pipe.Position.X.Scale <= -0.2 then
				pipe:Destroy()
				break
			end
			if pipe.Position.X.Scale <= 0.51 then
				local doesCollide = collides(flappy, df);
				if doesCollide == true then
					safe = true
					count = count + 1
					success:Play()
					print(count)
					break
				else
					safe = false
					failed = true
					killBird()
				end
			end
		end
	end)
end

function startCreatingPipes()
	spawn(function()
		while true do
			if failed == true then
				print 'user failed'
				break
			end
			createPipe()
			print 'Created a pipe.'
			wait(2)
		end
	end)
end

local function fall()
	wait(0.15)
	falling = true
	local ui = find("UI", pgui)
	local flappy = find("Flappy",ui)
	local flappygame = find("Background",ui)
	local flappyground = find("Ground",ui)
	local fail = find("Fail",ui)
	local min = -15
	local max = 90
	while true do
		if jumping == true then
			gravity = 60
			print("Reset gravity")
			falling = false
			
			break
		end
		if flappy.Position.Y.Offset >= 150 then
			started = false
			safe = false
			fail:Play()
			failed = true
			flappy.Position = UDim2.new(0.5, -25, 0.5, 150)
			gravity = 60
			flappy:TweenPosition(UDim2.new(0.5, -25, 0.5, 150),nil,nil,0.5,true)
			break
		end
		gravity = gravity + 2
		print(gravity)
		flappy:TweenPosition(flappy.Position + UDim2.new(0, 0, 0, gravity),nil,nil,0.5,true)
		spawn(function()
			for i = flappy.Rotation, max do 
				if jumping == true then
					flappy.Rotation = min
					break
				elseif failed == true then
					flappy.Rotation = i + 20
					break
				else
					flappy.Rotation = i + 20
					wait()
				end
			end
		end)
		wait(0.05)
	end
end

function onKeyPress(actionName, userInputState, inputObject)
	if userInputState == Enum.UserInputState.Begin then
		local ui = find("UI", pgui)
		local flappy = find("Flappy",ui)
		local flap = find("Flap",ui)
		local pipes = find("Pipes",ui)
		if failed == true then
			started = true
			count = 0
			safe = true
			pipes:ClearAllChildren()
			flappy.Position = UDim2.new(0.5, -25, 0.5, -20)
			failed = false
			wait(0.05)
			startCreatingPipes()
		end
		if started == false then
			started = true
			count = 0
			safe = true
			pipes:ClearAllChildren()
			startCreatingPipes()
		end
		if safe == false then
			safe = true
			count = 0
			started = true
			flappy.Position = UDim2.new(0.5, -25, 0.5, -20)
			pipes:ClearAllChildren()
			startCreatingPipes()
		end
		flappy.Rotation = -15
		jumping = true
		flappy:TweenPosition(flappy.Position - UDim2.new(0, 0, 0, 75),nil,nil,0.5,true)
		flap:Play()
		wait(0.5)
		jumping = false
		fall()
	end
end
 
game.ContextActionService:BindAction("keyPress", onKeyPress, false, Enum.KeyCode.Space)



createGui()

spawn(function()
	local ui = find("UI", pgui)
	local ground = find("Ground",ui)
	local counttext = find("Count",ui)
	while true do
		wait(0.01)
		counttext.Text = count
		if ground.Position.X.Scale <= -0.73 then
			ground.Position = UDim2.new(-0.65, -3, 1, -68)
		end
		ground.Position = ground.Position - UDim2.new(0.01)
	end
end)
