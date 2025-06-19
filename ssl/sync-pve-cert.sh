#!/bin/bash

# 功能：1panel自动申请证书后，同步到内网pve主机；
# 使用：sync-pve-cert.sh [证书存放路径]
#       如：sync-pve-cert.sh '/path/to/cert' #指定pem证书存放目录
#       或者 sync-pve-cert.sh #证书与当前脚本在同一目录
# 要求：需要搭配ssh免密登录pve主机；

# 远程主机IP，这里代理内网主机192.168.31.254:22到本机127.0.0.1:28122
REMOTE_USER_IP="root@127.0.0.1"    # 默认root用户可以不填写

# 远程主机ssh端口号
REMOTE_PORT=28122

# 证书文件，有脚本参数时用参数指定的目录，无参数时用当前脚本目录
PEM_PATH="${1:-$(dirname "$(readlink -f "$0")")}"   #证书目录
FULLCHAIN_PEM="$PEM_PATH/fullchain.pem"            #证书文件
PRIVKEY_PEM="$PEM_PATH/privkey.pem"                #密钥文件

# 如果证书不存在则退出
[ ! -f "$FULLCHAIN_PEM" ] && { echo "证书文件：${FULLCHAIN_PEM}未找到" ; exit 1 ; }
[ ! -f "$PRIVKEY_PEM" ] && { echo "密钥文件：${PRIVKEY_PEM}未找到" ; exit 2 ; }

# 检测目标主机免密登录是否可用
res=`ssh -p $REMOTE_PORT $REMOTE_USER_IP -o PreferredAuthentications=publickey -o StrictHostKeyChecking=no "date" |wc -l`
if [ ! $res -eq 1 ] ; then
    echo "错误：目标主机 $REMOTE_USER_IP:$REMOTE_PORT 免密连接异常，请检测公钥设置是否正确。"
    exit 1
fi

# 推送证书到pve主机
# 语法：scp -P 端口号 -p 文件路径 用户名@远程主机IP:目标目录
#    确保-P参数紧跟在scp命令之后，否则可能会出现错误。
#    -p(小写) 保留文件的修改时间、访问时间和权限信息
#    在传输文件或目录时，需要确保源文件或目录具有可读权限，目标目录具有可写权限。
#    如果需要传输的是目录，可以使用-r参数来递归复制整个目录。
# 注意需要把密钥后缀.pem改为.key

# 同步证书
scp -P $REMOTE_PORT $FULLCHAIN_PEM ${REMOTE_USER_IP}:/etc/pve/nodes/n100/pveproxy-ssl.pem
[ ! $? -eq 0 ] && { echo "${FULLCHAIN_PEM} 同步到远程主机 [$REMOTE_USER_IP:$REMOTE_PORT] 失败！" ; exit 1 ; }

# 同步私钥
scp -P $REMOTE_PORT $PRIVKEY_PEM ${REMOTE_USER_IP}:/etc/pve/nodes/n100/pveproxy-ssl.key
[ ! $? -eq 0 ] && { echo "${PRIVKEY_PEM} 同步到远程主机 [$REMOTE_USER_IP:$REMOTE_PORT] 失败！" ; exit 1 ; }

# 检测文件传输是否正确
ssh -p $REMOTE_PORT $REMOTE_USER_IP "cd /etc/pve/nodes/n100/; ls -l; "

# 重启服务，经测试会自动刷新
# ssh -p ${REMOTE_PORT} root@${REMOTE_PORT} "systemctl restart pveproxy;"

echo "证书已同步到远程主机 $REMOTE_USER_IP:$REMOTE_PORT."

exit 0
