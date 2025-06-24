# 1panel自用脚本库
在线仓库地址：https://github.com/noyboy/1panel
个人主页：https://www.xuechun.vip/

## 1Panel远程推送证书到其他服务器
**测试版本:** V2.0.2

**使用方法:**
1. 下载脚本，保存到本地，如`/root/sync-1panel-cert.sh`，记下路径`/root`，后面要用到。
2. 修改参数，一共三个：
  2.1 `PANEL_URL`: 1panel访问url（例https://1panel.xxx.cn），不需要加安全入口
  2.2 `API_SECRET`：API接口，在1panel系统设置里面开启，建议添加IP白名单并定期更换。
  2.3 `SSL_ID`：这个要手动获取，先上传一遍要同步的证书，再开启浏览器开发者工具，点击打开刚上传证书详情，就可以从开发者工具网络选项看到一个数字，就是这个SSL_ID。这个较为麻烦，暂不知道更简单方法。
3. 利用1panel证书自动续签功能，选择`证书推送到本地目录`，路径选刚才保存脚本的路径`/root/`。
4. 勾选`申请证书之后执行`，下面的脚本内容中填入以下内容，然后确认保存即可。
```shell
chmod +x /root/sync-1panel-cert.sh
/root/sync-1panel-cert.sh
```
保存确认后，1panel会自动执行一次，有异常及时[反馈我](https://github.com/noyboy/1panel)。

**其他**
可在运行脚本时，用参数指定证书路径，调用方法：
```
/root/sync-1panel-cert.sh /path
```

## 从1panel面板推送SSL证书到PVE主机
文件名：sync-pve-ssl.sh
