--[[
LuCI - Lua Configuration Interface

Copyright 2008 Steven Barth <steven@midlink.org>
Modifications 2013 Christian Richarz <cricharz@multidata.de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id: openvpn.lua 8880 2012-07-09 06:25:04Z soma $
]]--

local fs  = require "nixio.fs"
local sys = require "luci.sys"
local uci = require "luci.model.uci".cursor()
local testfullps = luci.sys.exec("ps --help 2>&1 | grep BusyBox") --check which ps do we have
local psstring = (string.len(testfullps)>0) and  "ps w" or  "ps axfw" --set command we use to get pid

local m = Map("openvpn", translate("OpenVPN"))
local s = m:section( TypedSection, "openvpn", translate("OpenVPN instances"), translate("Below is a list of configured OpenVPN instances and their current state") )
s.template = "cbi/tblsection"
s.addremove = true
s.extedit = luci.dispatcher.build_url( "admin", "network", "openvpn", "basic", "%s" )

function s.create(self, name)
      
-- create new section with default settings for a simple client configuration

    if name and not name:match("[^a-zA-Z0-9_]") then
	uci:section( "openvpn", "openvpn", name, { 
		mode 	 	= "p2p",
		enabled		= "1",
		dev_type	= "tun"
   	} ) 
	uci:save("openvpn")
        luci.http.redirect( self.extedit:format(name, recipe) )
    else
	self.invalid_cts = true
    end
end

s:option( Flag, "enabled", translate("Enabled") )

local active = s:option( DummyValue, "_active", translate("Started") )
function active.cfgvalue(self, section)
	local pid = sys.exec("%s | grep %s | grep openvpn | grep -v grep | awk '{print $1}'" % { psstring,section} )
	if pid and #pid > 0 and tonumber(pid) ~= nil then
		return (sys.process.signal(pid, 0))
			and translatef("yes (%i)", pid)
			or  translate("no")
	end
	return translate("no")
end

local updown = s:option( Button, "_updown", translate("Start/Stop") )
updown._state = false
function updown.cbid(self, section)
	local pid = sys.exec("%s | grep %s | grep openvpn | grep -v grep | awk '{print $1}'" % { psstring,section} )
	self._state = pid and #pid > 0 and sys.process.signal(pid, 0)
	self.option = self._state and "stop" or "start"
	return AbstractValue.cbid(self, section)
end
function updown.cfgvalue(self, section)
	self.title = self._state and "stop" or "start"
	self.inputstyle = self._state and "reset" or "reload"
end
function updown.write(self, section, value)
	if self.option == "stop" then
		luci.sys.call("/etc/init.d/openvpn stop %s" % section)
	else
		luci.sys.call("/etc/init.d/openvpn start %s" % section)
	end
end

local port = s:option( DummyValue, "rport", translate("Port") )
function port.cfgvalue(self, section)
	local val = AbstractValue.cfgvalue(self, section)
	return val
end

local proto = s:option( DummyValue, "proto", translate("Protocol") )
function proto.cfgvalue(self, section)
	local val = AbstractValue.cfgvalue(self, section)
	return val
end


return m
