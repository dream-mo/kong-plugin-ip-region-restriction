# kong-plugin-ip-region-restriction
This is a kong plug-in, which mainly uses the ip2region library to filter the attribution information of some IPs and prohibit access.

https://github.com/lionsoul2014/ip2region
# How To Use ?
1.select your lua version directory plugin
2.Move the entire ip-region-restriction directory to your kong plugins directory
3.modify ip-region-restriction/ip_restriction.lua line:4 db_path="your ip2regeion.db file path"
3.modify /etc/kong/kong.conf:
```text
plugins=bundled,ip-region-restriction
```
Restart kong (kong restart) 
```shell script
kong restart
```

or reload (kong prepare && kong reload)
```shell script
kong prepare && kong reload
```

Verify that the plugin loaded successfully
```shell script
 curl -s 127.0.0.1:8001 | jq '.plugins.available_on_server' | grep 'ip-region-restriction'
```
Use Konga to configure and view the effect
![1292211659796101_ pic](https://user-images.githubusercontent.com/22147280/183253144-e00a0c1e-9801-4278-9020-64d704b0119b.jpg)
