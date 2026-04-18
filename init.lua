local RS = game:GetService("RunService")
local HS = game:GetService("HttpService")
local SS = game:GetService("SerializationService")
local IsStudio = RS:IsStudio()
local Url = "https://github.com/veilithrift/vns/raw/main/main.rbxm"

local t = os.clock()

if RS:IsClient() then
	local rbxm = game:HttpGet(Url)
	local instances = SS:DeserializeInstancesAsync(buffer.fromstring(rbxm))
	instances[1].Parent = game

	require(game.vns):Run()
else
	local rbxm = HS:GetAsync(Url)
	local instances = SS:DeserializeInstancesAsync(buffer.fromstring(rbxm))
	instances[1].Parent = game
	
	require(game.vns):Run(game.Players:GetPlayers()[1])
end

print("{os.clock()-t}s to fully load vns")
