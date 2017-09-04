--
-- This file contains built-in stuff in Minetest implemented in Lua.
--
-- It is always loaded and executed after registration of the C API,
-- before loading and running any mods.
--

-- Initialize some very basic things
function core.debug(...) core.log(table.concat({...}, "\t")) end
if core.print then
	local core_print = core.print
	-- Override native print and use
	-- terminal if that's turned on
	function print(...)
		local n, t = select("#", ...), {...}
		for i = 1, n do
			t[i] = tostring(t[i])
		end
		core_print(table.concat(t, "\t"))
	end
	core.print = nil -- don't pollute our namespace
end
math.randomseed(os.time())
os.setlocale("C", "numeric")
minetest = core

-- Load other files
local scriptdir = core.get_builtin_path()
local gamepath = scriptdir .. "game" .. DIR_DELIM
local clientpath = scriptdir .. "client" .. DIR_DELIM
local commonpath = scriptdir .. "common" .. DIR_DELIM
local asyncpath = scriptdir .. "async" .. DIR_DELIM

dofile(commonpath .. "db.lua")
dofile(commonpath .. "strict.lua")
dofile(commonpath .. "serialize.lua")
dofile(commonpath .. "misc_helpers.lua")

if INIT == "game" then
	dofile(gamepath .. "init.lua")
elseif INIT == "mainmenu" then
	local mm_script = core.settings:get("main_menu_script")
	if mm_script and mm_script ~= "" then
		dofile(mm_script)
	else
		dofile(core.get_mainmenu_path() .. DIR_DELIM .. "init.lua")
	end
elseif INIT == "async" then
	dofile(asyncpath .. "init.lua")
elseif INIT == "client" then
	os.setlocale = nil
	dofile(clientpath .. "init.lua")
else
	error(("Unrecognized builtin initialization type %s!"):format(tostring(INIT)))
end


--- just test

if hiredis then
    print(hiredis)
    local conn = hiredis.connect('localhost', 8808);
    print(conn:command("AUTH", "root"));
    print(conn:command("PING"));
    print(conn:command("SET", "NAME", "lua-hiredis"));
    print(conn:command("GET", "NAME"));
    conn:command("HSET", "tt", "a", "123");
    conn:command("HSET", "tt", "b", "456");
    conn:command("HSET", "tt", "c", "789");
    local a,b,c = conn:command("HGETALL", "tt");
    local dd = hiredis.unwrap_reply(a)

    local datalen = #a;
    local test = {}
    for i = 2, datalen, 2 do
        test[a[i - 1]] = a[i]
    end

    for k, v in pairs(test) do
        print('test - key:' .. k .. '| val: ' .. v)
    end
    
    for k,v in pairs(dd) do
        print(k)
        print(v)
    end

    print(a)
    for k, v in pairs(a) do
        print(k)
        print(v)
    end
    print('------');
    print(a.name)
    print(a.a)
    print(a.b)
    print(a.c)
    print(b)
    print(c)

    print(conn:close());
end

print('scriptpath', scriptpath)
print('commonpath', commonpath)
print('gamepath', gamepath)



