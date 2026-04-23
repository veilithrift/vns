local RS = game:GetService("RunService")
local CG = game:GetService("CoreGui")
local SS = game:GetService("SerializationService")
local plrs = game:GetService("Players")
local path = "rbxasset://_vns/vns.rbxm"
local url = "https://github.com/veilithrift/vns/raw/main/vns.rbxm"

local loadlocal = true

local req = require
local isinject = RS:IsClient() and not RS:IsStudio()

if isinject then
	req = loadstring(game:HttpGet("https://raw.githubusercontent.com/veilithrift/vns/refs/heads/main/require.luau"))()
end

if RS:IsClient() then
	local rbxm: ModuleScript = loadlocal and game:GetObjects(path)[1] or SS:DeserializeInstancesAsync(buffer.fromstring(game:HttpGet(url)))[1]
	rbxm.Parent = CG

	local r = req(rbxm)
	if not r then
		warn("[vns][error][inject] loadstring failed")
		return
	end

	r:Run(true)
end
