--[[
LuCI - Lua Configuration IPSEC

Copyright 2013 Juan Flores <juan.flores@gdc-cala.com.mx>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id: 
]]--

module("luci.controller.ipsec", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/ipsec_pre") then
		return
	end

        entry( {"admin", "network", "ipsec"}, cbi("ipsec/overview"), _("IPSEC") ).acl_depends = { "luci-app-ipsec" }
        entry( {"admin", "network", "ipsec", "advanced_status"}, cbi("ipsec_advanced_status", "IPSEC Advanced Status"), nil )
        entry( {"admin", "network", "ipsec", "tunnel_form"}, cbi("ipsec/tunnel_form", {autoapply=true}), nil ).leaf = true
        entry( {"admin", "network", "ipsec", "tunnel_delete"}, call("tunnel_delete"), nil ).leaf = true
        entry( {"admin", "network", "ipsec", "tunnel_status"}, call("tunnel_status"), nil ).leaf = true
        entry( {"admin", "network", "ipsec", "tunnel_reconnect"}, call("tunnel_reconnect"), nil ).leaf = true
        entry( {"admin", "network", "ipsec", "tunnel_shutdown"}, call("tunnel_shutdown"), nil ).leaf = true
end

function ipsec_advanced_status()
	local ipm = require "luci.model.ipsec".init()
	local ip_xfrm_state = ipm:ip_xfrm_state()
	local ip_xfrm_policy = ipm:ip_xfrm_policy()
	local iproute = ipm:iproute()
	luci.template.render("ipsec/advanced_status", 
		{ip_xfrm_state=ip_xfrm_state, ip_xfrm_policy=ip_xfrm_policy, iproute=iproute})
end

function tunnel_delete(tunnel)
	local ipm = require "luci.model.ipsec".init()
	local tun = ipm:del_tunnel(tunnel)
	if tun then
                luci.sys.call("env -i /sbin/uci set ipsec_pre.%q.enabled=0 && uci commit ipsec_pre >/dev/null 2>/dev/null" %{tunnel})
		luci.sys.call("env -i /usr/sbin/ipsec down remote_%q-%q >/dev/null 2>/dev/null" %{tunnel, tunnel})
		luci.sys.call("env -i /etc/init.d/ipsec_pre reload >/dev/null 2>/dev/null")
		ipm:commit("ipsec_pre")
		luci.http.redirect(luci.dispatcher.build_url("admin/network/ipsec"))
		return
	end

	luci.http.status(404, "No such tunnel")
end

function tunnel_reconnect(tunnel)
	local ipm = require "luci.model.ipsec".init()
	local tun = ipm:get_tunnel(tunnel)
	if tun then
                luci.sys.call("env -i /sbin/uci set ipsec_pre.%q.enabled=1 && uci commit ipsec_pre >/dev/null 2>/dev/null" %{tunnel})
		luci.sys.call("env -i /usr/sbin/ipsec up remote_%q-%q >/dev/null 2>/dev/null" %{tunnel, tunnel})
		luci.sys.call("env -i /etc/init.d/ipsec_pre reload >/dev/null 2>/dev/null")
		luci.http.status(200, "Reconnected")
		return
	end

	luci.http.status(404, "No such tunnel")
end

function tunnel_shutdown(tunnel)
	local ipm = require "luci.model.ipsec".init()
	local tun = ipm:get_tunnel(tunnel)
	if tun then
                luci.sys.call("env -i /sbin/uci set ipsec_pre.%q.enabled=0 && uci commit ipsec_pre >/dev/null 2>/dev/null" %{tunnel})
		luci.sys.call("env -i /usr/sbin/ipsec down remote_%q-%q >/dev/null 2>/dev/null" %{tunnel, tunnel})
		luci.sys.call("env -i /etc/init.d/ipsec_pre reload >/dev/null 2>/dev/null")
		luci.http.status(200, "Shutdown")
		return
	end

	luci.http.status(404, "No such tunnel")
end

function tunnel_status(tunnels)
	local ipm = require "luci.model.ipsec".init()
	local rv   = { }

	local tunnel
	for tunnel in tunnels:gmatch("[%w%.%-_]+") do
		local stat = ipm:get_tunnel_status(tunnel)
		rv[#rv+1] = {
			name = tunnel,
			status = stat.status,
		}
	end
	
	if #rv > 0 then
		luci.http.prepare_content("application/json")
		luci.http.write_json(rv)
		return
	end

	luci.http.status(404, "No such device")
end
