#!/bin/bash

# 功能：1panel自动申请证书后，同步到内网pve主机；
# 使用：sync-pve-cert.sh 证书存放路径
#        如：sync-pve-cert.sh '/path/to/cert'
# 要求：需要搭配ssh免密登录pve主机；

# 远程pve主机IP，这里代理内网主机192.168.31.254:22到本机127.0.0.1:28122
PVE_IP=127.0.0.1

# 远程pve主机ssh端口号
PVE_SSH_PORT=28122

# 推送证书到pve主机
# 语法：scp -P 端口号 文件路径 用户名@远程主机IP:目标目录
#    确保-P参数紧跟在scp命令之后，否则可能会出现错误。
#    在传输文件或目录时，需要确保源文件或目录具有可读权限，目标目录具有可写权限。
#    如果需要传输的是目录，可以使用-r参数来递归复制整个目录。
# 注意需要把密钥后缀.pem改为.key

scp -P ${PVE_SSH_PORT} $1/fullchain.pem root@${PVE_IP}:/etc/pve/nodes/n100/pveproxy-ssl.pem
scp -P ${PVE_SSH_PORT} $1/privkey.pem root@${PVE_IP}:/etc/pve/nodes/n100/pveproxy-ssl.key

# 重启服务，经测试会自动刷新
# ssh  -p ${PVE_SSH_PORT} root@${PVE_IP} "systemctl restart pveproxy;"

#END
