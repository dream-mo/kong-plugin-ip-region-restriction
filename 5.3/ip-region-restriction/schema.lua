local typedefs = require "kong.db.schema.typedefs"

return {
    name = "ip-region-restriction",
    fields = {
        {
            config = {
                type = "record",
                fields = {
                    { not_allow_provinces = { type = "array", required = false, elements = typedefs.utf8_name }, },
                    { status = { type = "integer", required = false, default = 403 } },
                    { message = { type = "string", required = false, default = "Access Forbidden" } },
                    { allow_ips = { type = "array", required = false, elements = typedefs.ip }, }
                },
            },
        },
    },
}
