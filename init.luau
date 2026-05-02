warn("[vns][print][inject] injecting vns")

local RS = game:GetService("RunService")
local CG = game:GetService("CoreGui")
local SS = game:GetService("SerializationService")
local plrs = game:GetService("Players")
local localpath = "_vns/vns.rbxm"
local branch = "main"
local url = "https://github.com/veilithrift/vns/raw/" .. branch .. "/vns.rbxm"

local req = require

local getasset = getcustomasset or getsynasset or function(p) return "rbxasset://"..p end

if RS:IsClient() and not RS:IsStudio() then
	req = loadstring(game:HttpGet("https://raw.githubusercontent.com/veilithrift/vns/refs/heads/main/require.luau"))()
end

local rbxm: ModuleScript = game.ReplicatedStorage:FindFirstChild("vns") or (isfile(localpath) and game:GetObjects(getasset(localpath))[1]) or SS:DeserializeInstancesAsync(buffer.fromstring(game:HttpGet(url)))[1]
rbxm.Parent = CG

local r = req(rbxm)
if not r then
	warn("[vns][error][inject] loadstring failed")
	return
end

r:Run(branch)
