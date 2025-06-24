#!/bin/bash

# 1Panel网址，修改成你自己的
PANEL_URL="https://panel.xxx.cn"  

# 1Panel API接口，修改成你自己的
API_SECRET="TQZqhm6pVfPxoWG6dA53FmsILXgbW"

# 指定域名在远程1oanel内部id，修改成你自己的，方法见
SSL_ID=3

# 描述
DESCRIPTION="aliyun"

### 固定参数 ==========================================================

# 1panel 证书更新API接口
API_SSL_UPLOAD="/api/v2/websites/ssl/upload"  # 更新证书接口

TIME_ZONE="Asia/Shanghai"                     # 时区设置（用于日志时间显示）

# 当前脚本路径
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")   # 自动获取脚本所在目录
DEFAULT_CONFIG_FILE="${SCRIPT_DIR}/config"    # 配置文件与脚本同目录

# 证书文件，有脚本参数时用参数指定的目录，无参数时用当前脚本目录
PEM_PATH="${1:-$(dirname "$(readlink -f "$0")")}"  #证书目录
FULLCHAIN_PEM="$PEM_PATH/fullchain.pem"            #证书文件
PRIVKEY_PEM="$PEM_PATH/privkey.pem"                #密钥文件

# 如果证书不存在则退出
[ ! -f "$FULLCHAIN_PEM" ] && { echo "证书文件：${FULLCHAIN_PEM}未找到" ; exit 1 ; }
[ ! -f "$PRIVKEY_PEM" ] && { echo "密钥文件：${PRIVKEY_PEM}未找到" ; exit 2 ; }


### 函数定义 ==========================================================
# 输出带时间戳的日志信息
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# 终止脚本并显示错误信息
die() {
    log "ERROR: $1" >&2
    exit 1
}

# 读取证书内容，使用远程上传的方式的，避免JSON的转义问题
PRIVATE_KEY_CONTENT=$(cat "$PRIVKEY_PEM" | awk '{printf "%s\\n", $0}' | sed 's/\\n$//')
CERTIFICATE_CONTENT=$(cat "$FULLCHAIN_PEM" | awk '{printf "%s\\n", $0}' | sed 's/\\n$//')

current_time=$(TZ=$TIME_ZONE date '+%Y-%m-%d %H:%M:%S %Z (UTC%:z)')

# 构建上传证书的请求数据：
# - type参数：值为paste为远程上传证书内容，需要privateKey和certificate指定证书文本内容。
#            值为local则读取远程主机内的文件，用privateKeyPath和certificatePath指定，证书在远程主机的文件路径
#
UPLOAD_DATA=$(cat <<EOF
{
    "privateKey": "$PRIVATE_KEY_CONTENT",
    "certificate": "$CERTIFICATE_CONTENT",
    "type": "paste",
    "sslID": $SSL_ID,
    "description": "${DESCRIPTION} ${current_time}"
}
EOF
)

# 生成1panel需要的Token：md5(1panel+SECRET+unix_stamp)
TIMESTAMP=$(date +%s);
TOKEN_MD5=$(echo -n "1panel${API_SECRET}${TIMESTAMP}"|md5sum |cut -d" " -f1);

# 发送证书上传请求
UPLOAD_RESPONSE=$(curl -s -X POST "${PANEL_URL}{$API_SSL_UPLOAD}" \
	-H "Content-Type: application/json" \
	-H "1Panel-Token: $TOKEN_MD5" \
	-H "1Panel-Timestamp: $TIMESTAMP" \
	-d "$UPLOAD_DATA")

# 输出上传结果
echo "证书上传响应: $UPLOAD_RESPONSE"

exit 0
