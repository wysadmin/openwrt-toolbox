#!/bin/sh
# OpenWrt toolbox v1.12, POSIX ash compatible
# Project: https://github.com/wysadmin/openwrt-toolbox
VER="1.12"
RAW_URL="https://raw.githubusercontent.com/wysadmin/openwrt-toolbox/main/toolbox.sh"
RAW_PROXY="https://ghproxy.com/https://raw.githubusercontent.com/wysadmin/openwrt-toolbox/main/toolbox.sh"

# 版本检测函数，仅在【更新】菜单手动调用
check_version(){
    REMOTE_VER=""
    echo "🔍正在检测新版本..."
    if wget --timeout=5 -q -O /tmp/ver.tmp $RAW_URL; then
        REMOTE_VER=$(grep "VER=" /tmp/ver.tmp | head -1 | sed -e 's/.*VER="//' -e 's/"//')
    else
        wget --timeout=5 -q -O /tmp/ver.tmp $RAW_PROXY
        REMOTE_VER=$(grep "VER=" /tmp/ver.tmp | head -1 | sed -e 's/.*VER="//' -e 's/"//')
    fi
    rm -f /tmp/ver.tmp
    if [ -n "$REMOTE_VER" ]; then
        HAS_NEW=$(echo "$REMOTE_VER > $VER" | awk '{if($1)print 1;else print 0}')
        if [ "$HAS_NEW" -eq 1 ];then
            echo "🎉发现新版本 v$REMOTE_VER (当前v$VER)"
        else
            echo "✅当前已是最新版本 v$VER"
        fi
    else
        echo "❌无法获取远端版本信息，网络异常"
    fi
}

menu() {
clear
echo "=============================="
echo "    OpenWrt软路由工具箱 v$VER"
echo "=============================="
echo "  1. 系统信息查询"
echo "  2. 系统清理（标准版）"
echo "  3. 系统+Docker清理"
echo "  4. Docker管理"
echo "  5. 磁盘占用查看"
echo "  6. 网络测速"
echo "  7. 常用命令合集"
echo "  8. 常用工具"
echo "  9. 重启路由器"
echo " 10. 卸载工具箱（删除脚本）"
echo " 11. 更新工具箱脚本"
echo "  0. 退出脚本"
echo "=============================="
read -p "请输入选项：" opt
case $opt in
1)
    clear
    echo "系统信息查询"
    echo "------------------------"
    echo "主机名:        $(hostname)"
    echo "系统版本:      $(cat /etc/openwrt_release | grep DISTRIB_DESCRIPTION | cut -d\' -f2)"
    echo "内核版本:      $(uname -r)"
    echo "CPU架构:       $(uname -m)"
    echo "运行时间:      $(uptime | cut -d',' -f1)"
    echo "内存信息:"
    free -h
    echo ""
    echo "网卡信息:"
    ip addr | grep inet
    echo ""
    echo "操作完成"
    read -p "按回车返回主菜单..." dummy
    menu
;;
2)
    clear
    echo "====开始执行【标准版系统清理】===="
    opkg clean; rm -rf /tmp/* /var/tmp/*
    sync && echo 3 > /proc/sys/vm/drop_caches
    echo "✅ 标准版清理完成！"
    read -p "按回车返回主菜单..." dummy
    menu
;;
3)
    clear
    echo "====开始执行【系统+Docker清理】===="
    opkg clean; rm -rf /tmp/* /var/tmp/*
    sync && echo 3 > /proc/sys/vm/drop_caches
    docker system prune -f
    echo "✅ 系统+Docker清理完成！"
    read -p "按回车返回主菜单..." dummy
    menu
;;
4)
    docker_menu
;;
5)
    clear
    echo "====磁盘占用查看===="
    df -h
    echo ""
    du -sh /* 2>/dev/null | sort -hr | head -10
    read -p "按回车返回主菜单..." dummy
    menu
;;
6)
    speedtest_menu
;;
7)
    cmd_menu
;;
8)
    tools_menu
;;
9)
    read -p "⚠️确认重启路由器？输入y确认：" ans
    if [ "$ans" = "y" ];then
        reboot
    else
        echo "已取消重启"
        sleep 1
    fi
    menu
;;
10)
    clear
    echo "==== 卸载工具箱 ===="
    echo "⚠️仅删除脚本本体，不会删除任何插件配置"
    read -p "确认删除工具箱脚本？输入 y 确认：" ans
    if [ "$ans" = "y" ];then
        rm -f /root/toolbox.sh
        echo "✅工具箱脚本已删除，脚本即将退出！"
        exit 0
    else
        echo "已取消卸载"
        sleep 1
    fi
    menu
;;
11)
    clear
    echo "==== 更新工具箱脚本 ===="
    check_version
    read -p "确认更新？输入 y 确认：" ans
    if [ "$ans" = "y" ];then
        echo "尝试拉取原版raw..."
        if wget --timeout=10 $RAW_URL -O /root/toolbox.sh.new; then
            echo "✅ 下载成功，替换脚本"
            mv /root/toolbox.sh.new /root/toolbox.sh
            chmod +x /root/toolbox.sh
            echo "✅ 更新完成！自动启动新版工具箱"
            sleep 1
            exec /root/toolbox.sh
        else
            echo "❌ 原版raw访问失败，尝试ghproxy镜像"
            if wget --timeout=10 $RAW_PROXY -O /root/toolbox.sh.new;then
                mv /root/toolbox.sh.new /root/toolbox.sh
                chmod +x /root/toolbox.sh
                echo "✅ 通过ghproxy更新成功！启动新版"
                sleep 1
                exec /root/toolbox.sh
            else
                echo "❌ 更新失败！网络无法访问github raw"
                rm -f /root/toolbox.sh.new
            fi
        fi
    else
        echo "已取消更新"
        sleep 1
    fi
    menu
;;
0)
    echo "退出工具箱，再见。"
    exit 0
;;
*)
    echo "❌输入错误，请重新选择！"
    sleep 1
    menu
;;
esac
}

docker_menu(){
clear
echo "====Docker管理子菜单===="
echo "1. 查看运行容器"
echo "2. 查看本地镜像"
echo "3. 清理停止容器+悬空镜像"
echo "4. 返回主菜单"
read -p "请选择：" dopt
case $dopt in
1) docker ps;read -p "回车返回" dummy;docker_menu;;
2) docker images;read -p "回车返回" dummy;docker_menu;;
3) docker system prune -f;echo "清理完成";read -p "回车返回" dummy;docker_menu;;
4) menu;;
*) echo "输入错误";sleep 1;docker_menu;;
esac
}

speedtest_menu(){
clear
echo "====网络测速子菜单===="
echo "1. Speedtest测速（netperf）"
echo "2. 100MB文件下载测试"
echo "3. Ping网关测试"
echo "4. 返回主菜单"
read -p "请选择：" sopt
case $sopt in
1)
    if ! command -v speedtest-netperf >/dev/null; then
        echo "⚠️未检测测速工具，正在安装 speedtest-netperf"
        opkg update && opkg install speedtest-netperf
    fi
    echo "开始测速..."
    speedtest-netperf
    read -p "回车返回测速菜单" dummy;speedtest_menu
;;
2)
    echo "下载100MB测试文件"
    wget -O /dev/null https://speed.hetzner.de/100MB.bin
    read -p "回车返回测速菜单" dummy;speedtest_menu
;;
3)
    read -p "输入网关IP（默认192.168.1.1）:" gwip
    [ -z "$gwip" ] && gwip="192.168.1.1"
    ping $gwip -c 20
    read -p "回车返回测速菜单" dummy;speedtest_menu
;;
4) menu;;
*) echo "输入错误";sleep 1;speedtest_menu;;
esac
}

cmd_menu(){
clear
echo "====常用命令合集===="
echo "1. 查看网卡信息 ip a"
echo "2. 实时流量 iftop（需安装）"
echo "3. 端口监听 netstat"
echo "4. 查看路由表"
echo "5. 查看系统日志"
echo "6. CPU温度"
echo "7. 返回主菜单"
read -p "请选择：" copt
case $copt in
1) ip a; read -p "回车返回" dummy;cmd_menu;;
2)
    if ! command -v iftop >/dev/null; then
        echo "⚠️未安装iftop，正在安装..."
        opkg update && opkg install iftop
    fi
    echo "按 q 退出iftop"
    iftop
    read -p "回车返回" dummy;cmd_menu
;;
3) netstat -tulnp; read -p "回车返回" dummy;cmd_menu;;
4) route -n; read -p "回车返回" dummy;cmd_menu;;
5) logread; read -p "回车返回" dummy;cmd_menu;;
6)
    cat /sys/class/thermal/thermal_zone0/temp | awk '{print $1/1000 " ℃"}'
    read -p "回车返回" dummy;cmd_menu
;;
7) menu;;
*) echo "输入错误";sleep 1;cmd_menu;;
esac
}

tools_menu(){
clear
echo "====常用工具菜单===="
echo "1. 一键添加 Passwall 软件源（自动多源切换）"
echo "2. 一键添加 ADG(AdGuardHome) 软件源（自动多源切换）"
echo "3. 一键安装 Passwall"
echo "4. 一键安装 AdGuardHome"
echo "5. 一键恢复原源备份"
echo "6. 返回主菜单"
echo "7. 一键备份 Passwall 配置"
echo "8. 一键备份 AdGuardHome 配置"
echo "9. 一键恢复 Passwall 备份"
echo "10.一键恢复 AdGuardHome 备份"
read -p "请选择：" topt
case $topt in
1)
    clear
    echo "====一键添加Passwall软件源【多源自动探测】===="
    echo "⚠️自动备份原源文件 distfeeds.conf.bak"
    cp /etc/opkg/distfeeds.conf /etc/opkg/distfeeds.conf.bak
    # 优先github源，失败切换ghproxy镜像
    SRC1="src-git passwall https://github.com/xiaorouji/openwrt-passwall.git;main src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall-packages.git;main"
    SRC2="src-git passwall https://ghproxy.com/https://github.com/xiaorouji/openwrt-passwall.git;main src-git passwall_packages https://ghproxy.com/https://github.com/xiaorouji/openwrt-passwall-packages.git;main"
    PW_OK=0
    echo -e "\n正在测试源1：$SRC1"
    URL1=$(echo $SRC1 | awk '{print $3}')
    timeout 8 git ls-remote $URL1 >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "✅源1连通成功，写入配置"
        echo "$SRC1" | awk '{print $1" "$2" "$3" "$4;print $5" "$6" "$7" "$8}' >> /etc/opkg/distfeeds.conf
        PW_OK=1
    else
        echo "❌源1不可访问，尝试ghproxy镜像源"
        URL2=$(echo $SRC2 | awk '{print $3}')
        timeout 8 git ls-remote $URL2 >/dev/null 2>&1
        if [ $? -eq 0 ];then
            echo "✅镜像源连通成功，写入配置"
            echo "$SRC2" | awk '{print $1" "$2" "$3" "$4;print $5" "$6" "$7" "$8}' >> /etc/opkg/distfeeds.conf
            PW_OK=1
        fi
    fi
    if [ $PW_OK -eq 1 ]; then
        echo "开始更新软件包列表 opkg update"
        opkg update
        echo "✅ Passwall源配置完成"
    else
        echo "❌ 所有Passwall源均无法连通，请检查网络"
    fi
    read -p "回车返回常用工具菜单" dummy;tools_menu
;;
2)
    clear
    echo "====一键添加AdGuardHome软件源【多源自动探测】===="
    echo "⚠️自动备份原源文件 distfeeds.conf.bak"
    cp /etc/opkg/distfeeds.conf /etc/opkg/distfeeds.conf.bak
    ADG_SRC1="src-git adguardhome https://github.com/rufengsuixing/luci-app-adguardhome.git"
    ADG_SRC2="src-git adguardhome https://ghproxy.com/https://github.com/rufengsuixing/luci-app-adguardhome.git"
    ADG_OK=0
    URL1=$(echo $ADG_SRC1 | cut -d' ' -f3)
    timeout 8 git ls-remote $URL1 >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "✅源连通成功，写入配置"
        echo "$ADG_SRC1" >> /etc/opkg/distfeeds.conf
        ADG_OK=1
    else
        echo "❌github源失败，测试ghproxy镜像"
        URL2=$(echo $ADG_SRC2 | cut -d' ' -f3)
        timeout 8 git ls-remote $URL2 >/dev/null 2>&1
        if [ $? -eq 0 ];then
            echo "✅镜像源连通成功，写入配置"
            echo "$ADG_SRC2" >> /etc/opkg/distfeeds.conf
            ADG_OK=1
        fi
    fi
    if [ $ADG_OK -eq 1 ]; then
        echo "开始更新软件包列表 opkg update"
        opkg update
        echo "✅ ADG源配置完成"
    else
        echo "❌ 所有ADG源均无法连通，请检查网络"
    fi
    read -p "回车返回常用工具菜单" dummy;tools_menu
;;
3)
    clear
    echo "====开始一键安装 Passwall===="
    opkg install luci-app-passwall luci-i18n-passwall-zh-cn
    echo "✅ Passwall安装完成！请刷新LuCI页面"
    read -p "回车返回常用工具菜单" dummy;tools_menu
;;
4)
    clear
    echo "====开始一键安装 AdGuardHome===="
    opkg install luci-app-adguardhome luci-i18n-adguardhome-zh-cn
    echo "✅ AdGuardHome安装完成！请到LuCI页面进行配置"
    read -p "回车返回常用工具菜单" dummy;tools_menu
;;
5)
    clear
    echo "====一键恢复源备份 distfeeds.conf.bak ===="
    if [ -f /etc/opkg/distfeeds.conf.bak ]; then
        cp /etc/opkg/distfeeds.conf.bak /etc/opkg/distfeeds.conf
        echo "✅ 已恢复备份源配置，执行 opkg update"
        opkg update
    else
        echo "❌ 未找到备份文件 distfeeds.conf.bak"
    fi
    read -p "回车返回常用工具菜单" dummy;tools_menu
;;
6) menu;;

# ====== 7.备份Passwall ======
7)
    clear
    echo "==== 一键备份 Passwall 配置 ===="
    BACKUP_DIR="/root/backup"
    mkdir -p $BACKUP_DIR
    TIME=$(date +%Y%m%d_%H%M%S)
    BACKUP_FILE="$BACKUP_DIR/pw_$TIME.tar.gz"
    if [ -f /etc/config/passwall ];then
        tar -zcvf $BACKUP_FILE /etc/config/passwall
        echo "✅ Passwall备份成功：$BACKUP_FILE"
    else
        echo "❌ 未找到Passwall配置文件 /etc/config/passwall"
    fi
    read -p "回车返回常用工具菜单" dummy;tools_menu
;;

# ====== 8.备份AdGuardHome ======
8)
    clear
    echo "==== 一键备份 AdGuardHome 配置 ===="
    BACKUP_DIR="/root/backup"
    mkdir -p $BACKUP_DIR
    TIME=$(date +%Y%m%d_%H%M%S)
    BACKUP_FILE="$BACKUP_DIR/adg_$TIME.tar.gz"
    if [ -f /etc/config/adguardhome ];then
        tar -zcvf $BACKUP_FILE /etc/config/adguardhome /etc/AdGuardHome/
        echo "✅ AdGuardHome备份成功：$BACKUP_FILE"
    else
        echo "❌ 未找到AdGuardHome配置文件 /etc/config/adguardhome"
    fi
    read -p "回车返回常用工具菜单" dummy;tools_menu
;;

# ====== 9.恢复Passwall备份 ======
9)
    clear
    echo "==== 一键恢复 Passwall 备份 ===="
    BACKUP_DIR="/root/backup"
    echo "备份文件列表："
    ls $BACKUP_DIR/pw_*.tar.gz 2>/dev/null
    read -p "输入要恢复的备份文件名(全称)：" bkname
    BK_PATH="$BACKUP_DIR/$bkname"
    if [ -f $BK_PATH ];then
        read -p "⚠️恢复会覆盖现有passwall配置！输入y确认：" ans
        if [ "$ans" = "y" ];then
            tar -zxvf $BK_PATH -C /
            /etc/init.d/passwall restart
            echo "✅ Passwall配置恢复并重启服务完成"
        else
            echo "已取消恢复"
        fi
    else
        echo "❌ 文件不存在"
    fi
    read -p "回车返回常用工具菜单" dummy;tools_menu
;;

# ====== 10.恢复AdGuardHome备份 ======
10)
    clear
    echo "==== 一键恢复 AdGuardHome 备份 ===="
    BACKUP_DIR="/root/backup"
    echo "备份文件列表："
    ls $BACKUP_DIR/adg_*.tar.gz 2>/dev/null
    read -p "输入要恢复的备份文件名(全称)：" bkname
    BK_PATH="$BACKUP_DIR/$bkname"
    if [ -f $BK_PATH ];then
        read -p "⚠️恢复会覆盖现有ADG配置！输入y确认：" ans
        if [ "$ans" = "y" ];then
            tar -zxvf $BK_PATH -C /
            /etc/init.d/adguardhome restart
            echo "✅ AdGuardHome配置恢复并重启服务完成"
        else
            echo "已取消恢复"
        fi
    else
        echo "❌ 文件不存在"
    fi
    read -p "回车返回常用工具菜单" dummy;tools_menu
;;

*) echo "输入错误";sleep 1;tools_menu;;
esac
}

# 启动入口
menu
