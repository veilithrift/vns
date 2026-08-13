warn("[vns][print][init] initing vns")

local RS = game:GetService("RunService")
local CG = game:GetService("CoreGui")
local SS = game:GetService("SerializationService")
local plrs = game:GetService("Players")
local localpath = "_vns/vns.rbxm"
local branch = "test"
local url = `https://github.com/veilithrift/vns/raw/{branch}/vns.rbxm`

local req = require

local gethiddenui = gethui or get_hidden_gui or function() return CG end
local getasset = getcustomasset or getsynasset or function(p) return "rbxasset://"..p end
local http = httpget

local isfile = isfile or function() return true end

if RS:IsClient() and not RS:IsStudio() then
	req = loadstring(game:HttpGet(`https://raw.githubusercontent.com/veilithrift/vns/refs/heads/{branch}/require.luau`))()
end

local rbxm: ModuleScript = game.ReplicatedStorage:FindFirstChild("vns") 
	or (isfile(localpath) and game:GetObjects(getasset(localpath))[1])

if not rbxm then
	local rbxmbuffer
	local count = 0
	repeat
		task.wait()
		pcall(function()
			if count < 3 or not http then
				rbxmbuffer = buffer.fromstring(game:HttpGet(url))
			elseif http then
				rbxmbuffer = buffer.fromstring(http(url))
			end
		end)
		count += 1
	until rbxmbuffer or count >= 6

	if rbxmbuffer then
		print(`[vns][print][init] vns.rbxm successfully loaded, took {count} tries`)
		rbxm = SS:DeserializeInstancesAsync(rbxmbuffer)[1]
	else
		error(`[vns][error][init] httpget couldnt load for vns.rbxm`)
		return
	end
end

rbxm.Parent = gethiddenui()

local r = req(rbxm)
if not r then
	error("[vns][error][init] loadstring failed")
	return
end

r:Run(branch)
