local RS = game:GetService("RunService")
local HS = game:GetService("HttpService")
local SS = game:GetService("SerializationService")
local IsStudio = RS:IsStudio()
local Url = "https://github.com/veilithrift/vns/raw/main/main.rbxm"

if RS:IsClient() then
	local rbxm
	if IsStudio then
		rbxm = HS:GetAsync(Url)
	else
		rbxm = loadstring(game:HttpGet(Url))()
	end
	local instances: { Instance } = SS:DeserializeInstancesAsync(buffer.fromstring(rbxm))
	instances[1].Parent = game

	require(game.vns):Run()
end
