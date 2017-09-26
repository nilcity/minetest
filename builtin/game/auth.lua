-- Minetest: builtin/auth.lua

--
-- Authentication handler
-- use redis to replace txt file
--

function core.string_to_privs(str, delim)
	assert(type(str) == "string")
	delim = delim or ','
	local privs = {}
	for _, priv in pairs(string.split(str, delim)) do
		privs[priv:trim()] = true
	end
	return privs
end

function core.privs_to_string(privs, delim)
	assert(type(privs) == "table")
	delim = delim or ','
	local list = {}
	for priv, bool in pairs(privs) do
		if bool then
			list[#list + 1] = priv
		end
	end
	return table.concat(list, delim)
end

assert(core.string_to_privs("a,b").b == true)
assert(core.privs_to_string({a=true,b=true}) == "a,b")

core.builtin_auth_handler = {
	get_auth = function(name)
		assert(type(name) == "string")
		-- Figure out what password to use for a new player (singleplayer
		-- always has an empty password, otherwise use default, which is
		-- usually empty too)
        local user_data = db.user.find(name)
        -- If not in authentication storage, return nil
        if not user_data then 
            return nil
        end
		-- Figure out what privileges the player should have.
		-- Take a copy of the privilege table
        local user_privileges = core.string_to_privs(user_data['privileges'])
		local privileges = {}
		for priv, _ in pairs(user_privileges) do
			privileges[priv] = true
		end
		-- If singleplayer, give all privileges except those marked as give_to_singleplayer = false
		if core.is_singleplayer() then
			for priv, def in pairs(core.registered_privileges) do
				if def.give_to_singleplayer then
					privileges[priv] = true
				end
			end
		-- For the admin, give everything
		elseif name == core.settings:get("name") then
			for priv, def in pairs(core.registered_privileges) do
				privileges[priv] = true
			end
		end
		-- All done
		return {
			password = user_data['password'],
			privileges = privileges,
			-- Is set to nil if unknown
			last_login = user_data['last_login'],
		}
	end,
	create_auth = function(name, password)
		assert(type(name) == "string")
		assert(type(password) == "string")
		core.log('info', "Built-in authentication handler adding player '"..name.."'")

		local default_data = {
            name = name,
			password = password,
			privileges = core.settings:get("default_privs"),
			last_login = os.time(),
		}
        db.user.insert(default_data)
	end,
	set_password = function(name, password)
		assert(type(name) == "string")
		assert(type(password) == "string")
        local auth_user = db.user.find(name)
		if not auth_user then
			core.builtin_auth_handler.create_auth(name, password)
		else
			core.log('info', "Built-in authentication handler setting password of player '"..name.."'")
            db.user.update(name, 'password', password)
		end
		return true
	end,
	set_privileges = function(name, privileges)
		assert(type(name) == "string")
		assert(type(privileges) == "table")
        local auth_user = db.user.find(name)
		if not auth_user then
			core.builtin_auth_handler.create_auth(name,
				core.get_password_hash(name,
					core.settings:get("default_password")))
		end

        local user_privileges = core.string_to_privs(auth_user['privileges'])
		-- Run grant callbacks
		for priv, _ in pairs(privileges) do
			if not user_privileges[priv] then
				core.run_priv_callbacks(name, priv, nil, "grant")
			end
		end

		-- Run revoke callbacks
		for priv, _ in pairs(user_privileges) do
			if not privileges[priv] then
				core.run_priv_callbacks(name, priv, nil, "revoke")
			end
		end

		
        db.user.update(name, 'privileges', core.privs_to_string(privileges))

		core.notify_authentication_modified(name)
	end,
	reload = function()
        -- just do nothing
		return true
	end,
	record_login = function(name)
		assert(type(name) == "string")
        local auth_user = db.user.find(name)
		assert(auth_user)
        -- update last_login key
        db.user.update(name, 'last_login', os.time())
	end,
}

function core.register_authentication_handler(handler)
	if core.registered_auth_handler then
		error("Add-on authentication handler already registered by "..core.registered_auth_handler_modname)
	end
	core.registered_auth_handler = handler
	core.registered_auth_handler_modname = core.get_current_modname()
	handler.mod_origin = core.registered_auth_handler_modname
end

function core.get_auth_handler()
	return core.registered_auth_handler or core.builtin_auth_handler
end

local function auth_pass(name)
	return function(...)
		local auth_handler = core.get_auth_handler()
		if auth_handler[name] then
			return auth_handler[name](...)
		end
		return false
	end
end

core.set_player_password = auth_pass("set_password")
core.set_player_privs    = auth_pass("set_privileges")
core.auth_reload         = auth_pass("reload")


local record_login = auth_pass("record_login")

core.register_on_joinplayer(function(player)
	record_login(player:get_player_name())
end)

core.register_on_prejoinplayer(function(name, ip)
    print(name .. '|' .. ip);
    -- check it in redis
    local auth_user = db.user.find(name)

	if auth_user ~= nil then
		return auth_user
    else 
        return nil
	end

    -- don't check name is lower case, if u know what u want
	if auth_user['name'] == name then
		return string.format("\nCannot create new player called '%s'. "..
				"Another account called '%s' is already registered. "..
				"Please check the spelling if it's your account "..
				"or use a different nickname.", name, name)
	end
end)
