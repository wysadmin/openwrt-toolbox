#!/bin/sh
# OpenWrt软路由工具箱 v1.8 Github发布版
# 功能：系统信息查询、清理、Docker管理、测速、常用命令、Passwall/AdGuardHome源自动探测+一键安装、一键恢复源备份
# 项目地址：https://github.com/wysadmin/openwrt-toolbox

# 主菜单函数
menu() {
clear
echo "=============================="
echo "    OpenWrt软路由工具箱 v1.8"
echo "=============================="
echo "  1. 系统信息查询"
echo "  2. 系统清理（标准版）"
echo "  3. 系统+Docker清理"
echo "  4. Docker管理"
echo "  5. 磁盘占用查看"
echo "  6. 网络测速"
echo "  7. 常用命令合集"
echo "  8. 常用工具"
echo "  9. 重启软路由"
echo "  0. 退出脚本"
echo "=============================="
read -p "请输入你的选择：" opt
case $opt in
1)
    clear
    echo "系统信息查询"
    echo "------------------------"
    echo "主机名:        $(hostname)"
    echo "系统版本:      $(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d '"')"
    echo "Linux版本:     $(uname -r)"
    echo "------------------------"
    echo "CPU架构:       $(uname -m)"
    if [ -f /proc/device-tree/model ]; then
        echo "CPU型号:       $(tr -d '\0' < /proc/device-tree/model)"
    else
        echo "CPU型号:       $(lscpu 2>/dev/null | grep 'Model name' | cut -d: -f2 | sed 's/^ *//')"
    fi
    echo "------------------------"
    echo "系统时间:      $(date '+%Y-%m-%d %H:%M:%S')"
    echo "运行时长:      $(uptime -p | sed 's/up //')"
    echo ""
    echo "操作完成"
    echo "按任意键继续..."
    read -n 1
    menu
;;
2)
    clear
    echo "开始执行【标准版系统清理】..."
    opkg clean; rm -rf /tmp/opkg-lists; find /etc/config -name "*-opkg" -type f -delete; sync && echo 3 > /proc/sys/vm/drop_caches; /etc/init.d/log restart
    echo "✅ 标准版清理完成！"
    read -p "按回车返回主菜单..."
    menu
;;
3)
    clear
    echo "开始执行【系统+Docker清理】..."
    opkg clean; rm -rf /tmp/opkg-lists; find /etc/config -name "*-opkg" -delete; sync && echo 3 > /proc/sys/vm/drop_caches; /etc/init.d/log restart; docker system prune -f
    echo "✅ 系统+Docker清理完成！"
    read -p "按回车返回主菜单..."
    menu
;;
4)
    docker_menu
;;
5)
    clear
    echo "====磁盘占用===="
    df -h
    echo ""
    du -sh /overlay/*
    read -p "按回车返回主菜单..."
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
    read -p "⚠️确认重启？输入y确认：" ans
    if [ "$ans" = "y" ];then
        reboot
    fi
    menu
;;
0)
    echo "退出工具箱"
    exit 0
;;
*)
    echo "❌输入错误，请重新选择！"
    sleep 1
    menu
;;
esac
}

# Docker子菜单
docker_menu(){
clear
echo "====Docker管理子菜单===="
echo "1. 查看运行容器"
echo "2. 查看本地镜像"
echo "3. 清理停止容器/悬空镜像"
echo "4. 返回主菜单"
read -p "请选择：" dopt
case $dopt in
1) docker ps;read -p "回车返回";docker_menu;;
2) docker images;read -p "回车返回";docker_menu;;
3) docker system prune -f;echo "清理完成";read -p "回车返回";docker_menu;;
4) menu;;
*) echo "输入错误";sleep 1;docker_menu;;
esac
}

# 测速子菜单
speedtest_menu(){
clear
echo "====网络测速子菜单===="
echo "1. Speedtest测速（netperf）"
echo "2. 单文件下载测试"
echo "3. ping网关测试"
echo "4. 返回主菜单"
read -p "请选择：" sopt
case $sopt in
1)
    if ! command -v speedtest-netperf >/dev/null; then
        echo "⚠️未检测到测速工具，正在安装 speedtest-netperf..."
        opkg update && opkg install speedtest-netperf
    fi
    echo "开始测速，请稍等..."
    speedtest-netperf
    read -p "回车返回测速菜单";speedtest_menu
;;
2)
    echo "测试下载100MB测试文件"
    wget -O /dev/null https://speed.hetzner.de/100MB.bin
    read -p "回车返回测速菜单";speedtest_menu
;;
3)
    read -p "输入网关IP（默认192.168.1.1）:" gwip
    [ -z "$gwip" ] && gwip="192.168.1.1"
    ping $gwip -c 20
    read -p "回车返回测速菜单";speedtest_menu
;;
4) menu;;
*) echo "输入错误";sleep 1;speedtest_menu;;
esac
}

# 常用命令子菜单
cmd_menu(){
clear
echo "====常用命令合集===="
echo "1. 查看网卡信息 ip a"
echo "2. 查看实时流量 iftop（需要安装）"
echo "3. 查看端口监听 netstat"
echo "4. 查看路由表"
echo "5. 查看系统日志"
echo "6. 查看CPU温度"
echo "7. 返回主菜单"
read -p "请选择：" copt
case $copt in
1) ip a; read -p "回车返回";cmd_menu;;
2)
    if ! command -v iftop >/dev/null; then
        echo "⚠️未安装iftop，正在安装..."
        opkg update && opkg install iftop
    fi
    echo "按 q 退出iftop"
    iftop
    read -p "回车返回";cmd_menu
;;
3) netstat -tulnp; read -p "回车返回";cmd_menu;;
4) route -n; read -p "回车返回";cmd_menu;;
5) logread; read -p "回车返回";cmd_menu;;
6)
    # x86软路由读取CPU温度
    cat /sys/class/thermal/thermal_zone0/temp | awk '{print $1/1000 " ℃"}'
    read -p "回车返回";cmd_menu
;;
7) menu;;
*) echo "输入错误";sleep 1;cmd_menu;;
esac
}

# 常用工具子菜单
tools_menu(){
clear
echo "====常用工具菜单===="
echo "1. 一键添加 Passwall 软件源（自动多源切换）"
echo "2. 一键添加 ADG(AdGuardHome) 软件源（自动多源切换）"
echo "3. 一键安装 Passwall"
echo "4. 一键安装 AdGuardHome"
echo "5. 返回主菜单"
echo "6. 一键恢复原源备份"
read -p "请选择：" topt
case $topt in
1)
    clear
    echo "====一键添加Passwall软件源【多源自动探测】===="
    echo "⚠️自动备份原源文件 distfeeds.conf.bak"
    cp /etc/opkg/distfeeds.conf /etc/opkg/distfeeds.conf.bak
    # Passwall 源列表：原版github + ghproxy镜像
    PW_SOURCES=(
        "src-git passwall https://github.com/xiaorouji/openwrt-passwall.git;main src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall-packages.git;main"
        "src-git passwall https://ghproxy.com/https://github.com/xiaorouji/openwrt-passwall.git;main src-git passwall_packages https://ghproxy.com/https://github.com/xiaorouji/openwrt-passwall-packages.git;main"
    )
    PW_OK=0
    for src in "${PW_SOURCES[@]}"; do
        echo -e "\n正在测试源：$src"
        timeout 8 git ls-remote $(echo $src | awk '{print $3}') >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "✅ 源连通成功，写入配置"
            echo "$src" | awk '{print $1" "$2" "$3" "$4;print $5" "$6" "$7" "$8}' >> /etc/opkg/distfeeds.conf
            PW_OK=1
            break
        else
            echo "❌ 当前源超时/无法访问，尝试下一个备用源..."
        fi
    done
    if [ $PW_OK -eq 1 ]; then
        echo "开始更新软件包列表 opkg update"
        opkg update
        echo "✅ Passwall源配置完成"
    else
        echo "❌ 所有Passwall源均无法连通，请检查网络"
    fi
    read -p "回车返回常用工具菜单";tools_menu
;;
2)
    clear
    echo "====一键添加AdGuardHome软件源【多源自动探测】===="
    echo "⚠️自动备份原源文件 distfeeds.conf.bak"
    cp /etc/opkg/distfeeds.conf /etc/opkg/distfeeds.conf.bak
    # ADG源列表
    ADG_SOURCES=(
        "src-git adguardhome https://github.com/rufengsuixing/luci-app-adguardhome.git"
        "src-git adguardhome https://ghproxy.com/https://github.com/rufengsuixing/luci-app-adguardhome.git"
    )
    ADG_OK=0
    for src in "${ADG_SOURCES[@]}"; do
        echo -e "\n正在测试源：$src"
        repo_url=$(echo $src | cut -d' ' -f3)
        timeout 8 git ls-remote $repo_url >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "✅ 源连通成功，写入配置"
            echo "$src" >> /etc/opkg/distfeeds.conf
            ADG_OK=1
            break
        else
            echo "❌ 当前源超时/无法访问，尝试下一个备用源..."
        fi
    done
    if [ $ADG_OK -eq 1 ]; then
        echo "开始更新软件包列表 opkg update"
        opkg update
        echo "✅ ADG源配置完成"
    else
        echo "❌ 所有ADG源均无法连通，请检查网络"
    fi
    read -p "回车返回常用工具菜单";tools_menu
;;
3)
    clear
    echo "====开始一键安装 Passwall===="
    opkg install luci-app-passwall luci-i18n-passwall-zh-cn
    echo "✅ Passwall安装完成！请刷新LuCI页面"
    read -p "回车返回常用工具菜单";tools_menu
;;
4)
    clear
    echo "====开始一键安装 AdGuardHome===="
    opkg install luci-app-adguardhome luci-i18n-adguardhome-zh-cn
    echo "✅ AdGuardHome安装完成！请到LuCI页面进行配置"
    read -p "回车返回常用工具菜单";tools_menu
;;
5) menu;;
6)
    clear
    echo "====一键恢复源备份 distfeeds.conf.bak ===="
    if [ -f /etc/opkg/distfeeds.conf.bak ]; then
        cp /etc/opkg/distfeeds.conf.bak /etc/opkg/distfeeds.conf
        echo "✅ 已恢复备份源配置，正在执行 opkg update"
        opkg update
    else
        echo "❌ 未找到备份文件 distfeeds.conf.bak"
    fi
    read -p "回车返回常用工具菜单";tools_menu
;;
*) echo "输入错误";sleep 1;tools_menu;;
esac
}

# 启动入口
menu
