-- 加载xdb_searcher模块
local xdb = require("xdb_searcher")
-- todo 路径需要自己定义
local db_path = "/opt/kong/plugins/ip-region-restriction/ip2region.xdb"

-- 1、从指定的 db_path 加载整个 xdb 到内存。
-- xdb内容加载一次即可，建议在服务启动的时候加载为全局对象。
content = xdb.load_content(db_path)
if content == nil then
    print(string.format("failed to load xdb content from '%s'", db_path))
    return
end

-- 2、使用全局的 content 创建带完全基于内存的查询对象。
searcher, err = xdb.new_with_buffer(content)
if err ~= nil then
    print(string.format("failed to create content buffer searcher: %s", err))
    return
end

-- IP格式: 国家|区域|省份|城市|ISP
-- 解析ipRegion内容
local function ipRegionParse(s, delimiter)
    local result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    local ipRegion = {
        country = result[1],
        region = result[2],
        province = result[3],
        city = result[4],
        isp = result[5]
    }
    return ipRegion
end

--- 判断value是否在table中
local function isInclude(tab, value)
    for k,v in ipairs(tab) do
      if v == value then
          return true
      end
    end
    return false
end

-- 检查IP地址
function checkIp(ip_str, not_allow_provinces, allow_ips)
    -- 特殊ip放行
    local is_allow_ip = isInclude(allow_ips, ip_str)
    if is_allow_ip then
        return true
    end
    local s_time = xdb.now()
    -- 调用查询 API
    local region,  err = searcher:search(ip_str)
    if err ~= nil then
        local log_str = string.format("failed to search(%s): %s", ip_str, err)
        kong.log("ip_restriction 查询失败=>", log_str)
        return true
    end
    local log_str = string.format("IP: %s {region: %s,  took: %.5f μs}", ip_str, region, xdb.now() - s_time)
    -- 内网IP放行
    local ipTable = ipRegionParse(region, "|")
    if ipTable['isp'] == "内网IP" then
        return true
    end
    -- 判断是否是境内IP
    if ipTable['country'] == "中国" then
        if isInclude(not_allow_provinces, ipTable['province']) then
            kong.log("ip_restriction 拦截(境外IP)=>", log_str)
            return false
        else
            return true
        end
    else
        kong.log("ip_restriction 拦截(境外/未知区域IP)=>", log_str)
        return false
    end
end