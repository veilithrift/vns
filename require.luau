_G.vnsmodule = _G.vnsmodule or {}

local cache = _G.vnsmodule

local keyword = {
	["./"] = function(path, base)
		return base.Parent, path:sub(3)
	end,
	["../"] = function(path, base)
		return base.Parent and base.Parent.Parent, path:sub(4)
	end,
	["@self/"] = function(path, base)
		return base, path:sub(7)
	end,
	["@game/"] = function(path, base)
		return game, path:sub(7)
	end,
}

local function resolve(path: string, base: Instance)
	local current
	local remaining = path

	-- apply prefix
	for key, func in pairs(keyword) do
		if path:sub(1, #key) == key then
			current, remaining = func(path, base)
			break
		end
	end

	if not current then
		error("[vns][error][require] invalid path prefix:",path)
	end

	-- walk path
	for segment in string.gmatch(remaining, "[^/]+") do
		if segment == ".." then
			current = current.Parent
		else
			current = current:FindFirstChild(segment)
		end

		if not current then
			error("[vns][error][require] path resolution failed at:",segment)
		end
	end

	return current
end

local function customRequire(module: Instance)
	if cache[module] then
		return cache[module]
	end

	local chunk, err = loadstring(module.Source, module.Name)
	if not chunk then
		error("[vns][error][require] loadstring failed:",err)
	end

	local env = {}
	env.script = module
	--[[env.require = function(path)
		local resolved = resolve(path, module)
		return customRequire(resolved)
	end]]

	setmetatable(env, { __index = _G })
	print(env.script)
	print(env.game)
	setfenv(chunk, env)

	local result = chunk()

	cache[module] = result
	return result
end

return function(path, base)
	local module = resolve(path, base)
	return customRequire(module)
end
