local g = getgenv()
g.module = g.module or {}

local cache = g.module

local prefix = {
	["."] = function(path, base)
		return base.Parent
	end,
	[".."] = function(path, base)
		return base.Parent and base.Parent.Parent
	end,
	["@self"] = function(path, base)
		return base
	end,
	["@game"] = function(path, base)
		return game
	end,
}

local function resolve(path: string, base: Instance)
	if typeof(path) == "Instance" and path:IsA("ModuleScript") then
		return path
	end
	local current
	local remaining = path

	-- apply prefix
	local prefixended = false
	while not prefixended do
		local e = false
		for key, func in pairs(prefix) do
			if remaining:sub(1, #key) == key then
				current = func(remaining, base)
				remaining = remaining:sub(#key + 2)
				e = true
				break
			end
		end
		if not e then
			prefixended = true
		end
	end

	if not current then
		error("[vns][error][require] invalid path prefix: "..path)
	end

	-- walk path
	for segment in string.gmatch(remaining, "[^/]+") do
		local currentdebug = current
		if segment == ".." then
			current = current.Parent
		else
			current = current:FindFirstChild(segment)
		end

		if not current then
			local message = string.format("[vns][error][require] path resolution failed: (base: %*), (path: %*), (segment: %*), (current: %*)", base:GetFullName(), path, segment, currentdebug:GetFullName())
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

	local env = {}
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
