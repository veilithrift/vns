warn("[vns][print][init] initing vns")

local RS = game:GetService("RunService")
local CG = game:GetService("CoreGui")
local SS = game:GetService("SerializationService")
local plrs = game:GetService("Players")
local localpath = "_vns/vns.rbxm"
local branch = "main"
local url = "https://github.com/veilithrift/vns/raw/" .. branch .. "/vns.rbxm"

local req = require

local gethiddenui = gethui or get_hidden_gui or function() return CG end
local getasset = getcustomasset or getsynasset or function(p) return "rbxasset://"..p end

local isfile = isfile or function() return true end

if RS:IsClient() and not RS:IsStudio() then
	req = loadstring(game:HttpGet("https://raw.githubusercontent.com/veilithrift/vns/refs/heads/main/require.luau"))()
end

local rbxm: ModuleScript = game.ReplicatedStorage:FindFirstChild("vns") or (isfile(localpath) and game:GetObjects(getasset(localpath))[1]) or SS:DeserializeInstancesAsync(buffer.fromstring(game:HttpGet(url)))[1]
rbxm.Parent = gethiddenui()

local r = req(rbxm)
if not r then
	error("[vns][error][init] loadstring failed")
	return
end

r:Run(branch)
