local cache = {}

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

local function resolve(path:string, base:Instance)
	local current

	for key, func in keyword do
		if path:sub(1, #key) == key then
			path, base = func(path, base)
		end
	end

	for segment in string.gmatch(path, "[^/]+") do
		if segment == "." then
			-- do nothing

		elseif segment == ".." then
			current = current and current.Parent

		else
			current = current and current:FindFirstChild(segment)
		end

		if not current then
			error("Path resolution failed at segment: " .. segment)
		end
	end

	return current
end

local function customRequire(path, base)
	local module = resolve(path, base)
	if not module then
		error("[vns] module not found:" .. path)
	end
	
	if cache[module] then
		return cache[module]
	end

	local chunk, err = loadstring(module.Source, module.Name)
	if not chunk then
		error("[vns] module loadstring failed:", err)
	end

	local result = chunk()

	cache[module] = result
	return result
end

return customRequire
