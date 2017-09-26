--Minetest
--Copyright (C) 2013 sapier
--
--This program is free software; you can redistribute it and/or modify
--it under the terms of the GNU Lesser General Public License as published by
--the Free Software Foundation; either version 2.1 of the License, or
--(at your option) any later version.
--
--This program is distributed in the hope that it will be useful,
--but WITHOUT ANY WARRANTY; without even the implied warranty of
--MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--GNU Lesser General Public License for more details.
--
--You should have received a copy of the GNU Lesser General Public License along
--with this program; if not, write to the Free Software Foundation, Inc.,
--51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

--------------------------------------------------------------------------------
local function get_formspec(tabview, name, tabdata)
	-- Update the cached supported proto info,
	-- it may have changed after a change by the settings menu.

	local retval =
		"label[1.5,0;".. fgettext("Name / Password") .. "]" ..
    	"button[2,2.6;2,1.5;btn_mp_connect;".. fgettext("Connect") .. "]" ..
		"field[1.9,1;2.6,0.5;te_name;;" ..
			core.formspec_escape(core.settings:get("name")) .."]" ..
		"pwdfield[1.9,2;2.6,0.5;te_pwd;]"
	return retval
end

--------------------------------------------------------------------------------
local function main_button_handler(tabview, fields, name, tabdata)
	if fields.btn_mp_connect or fields.key_enter then
		gamedata.playername = fields.te_name
		gamedata.password   = fields.te_pwd
		gamedata.address    = '115.159.156.101'
		gamedata.port	    = '8888'
		gamedata.servername	   = ""
        gamedata.serverdescription = ""

		gamedata.selected_world = 0

		core.settings:set("address", gamedata.address)
		core.settings:set("remote_port", gamedata.port)
			
 		core.start()		
 		return true		
 	end
end

--------------------------------------------------------------------------------
local function on_activate(type,old_tab,new_tab)
	if type == "LEAVE" then return end
	asyncOnlineFavourites()
end

--------------------------------------------------------------------------------
return {
	name = "main",
	caption = fgettext("Main"),
	cbf_formspec = get_formspec,
	cbf_button_handler = main_button_handler,
	on_change = on_activate
}

