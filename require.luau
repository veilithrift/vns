local g = getgenv()
g.module = g.module or {}

local cache = g.module

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
		error("[vns][error][require] invalid path prefix: "..path)
	end

	-- walk path
	for segment in string.gmatch(remaining, "[^/]+") do
		if segment == ".." then
			current = current.Parent
		else
			current = current:FindFirstChild(segment)
		end

		if not current then
			local message = string.format("[vns][error][require] path resolution failed: (base: %*), (path: %*), (segment: %*)", base:GetFullName(), path, segment)
			error(message)
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
		error("[vns][error][require] loadstring failed: "..err)
	end

	local env = {
		game = game,
		print = print,
		pairs = pairs,
		ipairs = ipairs,
		math = math,
		string = string,
		table = table,
	}
	env.script = module

	setmetatable(env, {__index = g})
	setfenv(chunk, env)

	local result = chunk()

	cache[module] = result
	return result
end

return function(path, base)
	local module = resolve(path, base)
	return customRequire(module)
end
