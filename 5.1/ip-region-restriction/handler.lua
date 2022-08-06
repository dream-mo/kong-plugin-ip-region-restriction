local IP_RESTRICTION = require("ip_restriction")

local ipRegionRestrictionHandler = {}

ipRegionRestrictionHandler.PRIORITY = 1
ipRegionRestrictionHandler.VERSION = "0.1.0"

function ipRegionRestrictionHandler:access(conf)
      local remote_addr = ngx.var.remote_addr
      if not remote_addr then
        return kong.response.error(403, "Cannot identify the client IP address, unix domain sockets are not supported.")
      end
      local status = conf.status or 403
      local message = conf.message or "Your IP address is not allowed"
      local not_allow_provinces = conf.not_allow_provinces or {"台湾省","香港","澳门"}
      local allow_ips = conf.allow_ips or {}
      local can_pass = checkIp(remote_addr, not_allow_provinces, allow_ips)
      if not can_pass then
        kong.response.error(status, message)
      end
end

return ipRegionRestrictionHandler


