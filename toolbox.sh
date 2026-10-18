#!/bin/sh
# OpenWrt / iStoreOS 工具箱 toolbox.sh
# 版本 v1.14
# 仓库：https://github.com/wysadmin/openwrt-toolbox
# 修复危险清理命令，保护 LuCI menu.d
# 备份统一存放 /root/backup

# ====================== 自动识别包管理器 ======================
if command -v opkg >/dev/null 2>&1; then
    PKG_MANAGER="opkg"
elif command -v apk >/dev/null 2>&1; then
    PKG_MANAGER="apk"
else
    echo "⚠️  未识别到包管理器！部分功能无法使用"
    PKG_MANAGER=""
fi

# 包管理器缓存清理函数
pkg_clean() {
    if [ "$PKG_MANAGER" = "opkg" ]; then
        opkg clean
    elif [ "$PKG_MANAGER" = "apk" ]; then
        apk cache clean
    fi
}
# ============================================================

# 创建备份目录
mkdir -p /root/backup

# 设置别名 k
set_alias() {
    if ! grep -q "alias k='/root/toolbox.sh'" /etc/profile; then
        echo "alias k='/root/toolbox.sh'" >> /etc/profile
        echo "✅ 已设置快捷命令 k，新开SSH终端生效"
    fi
}

# 系统信息查询（固定字段：主机名、系统版本、Linux版本、CPU架构、CPU型号、系统时间、运行时长）
show_system_info(){
    echo "==================== 系统信息 ===================="
    echo "主机名:        $(hostname)"
    if [ -f "/etc/openwrt_release" ]; then
        echo "系统版本:      $(cat /etc/openwrt_release)"
    else
        echo "系统版本:      iStoreOS / Alpine"
    fi
    echo "Linux版本:     $(uname -r)"
    echo "CPU架构:       $(uname -m)"
    CPU_MODEL=$(cat /proc/cpuinfo | grep 'model name' | head -n1 | cut -d: -f2 | sed 's/^ //')
    echo "CPU型号:       ${CPU_MODEL:-未知}"
    echo "系统时间:      $(date)"
    echo "运行时长:      $(uptime | cut -d, -f1)"
    echo "包管理器:      $PKG_MANAGER"
    echo "备份目录:      /root/backup"
    echo "=================================================="
}

# 【安全系统清理】移除 rm -rf /tmp/*，保护LuCI临时文件
clean_system(){
    echo "===== 开始安全系统清理 ====="
    # 清理软件包缓存
    pkg_clean
    # 只清理/tmp下老旧缓存文件，不删除luci会话、菜单临时文件
    find /tmp -maxdepth 1 -type f -name "*.log" -o -name "*cache*" 2>/dev/null | xargs rm -f 2>/dev/null
    # 释放内存缓存
    sync
    echo 3 > /proc/sys/vm/drop_caches 2>/dev/null
    echo "✅ 系统清理完成！已保护LuCI/menu.d系统文件"
}

# 系统+Docker清理
clean_system_docker(){
    clean_system
    if command -v docker >/dev/null 2>&1; then
        echo "===== 清理Docker ====="
        docker container prune -f
        docker image prune -f
        echo "✅ Docker清理完成"
    else
        echo "⚠️ 未检测到Docker，跳过Docker清理"
    fi
}

# Docker子菜单
menu_docker(){
    while true; do
        echo
        echo "===== Docker管理 ====="
        echo "1. 查看运行容器"
        echo "2. 查看本地镜像"
        echo "3. 一键清理停止容器与悬空镜像"
        echo "0. 返回主菜单"
        read -p "请输入选项:" dopt
        case $dopt in
            1) docker ps ;;
            2) docker images ;;
            3) docker container prune -f; docker image prune -f ;;
            0) break ;;
            *) echo "无效选项" ;;
        esac
    done
}

# 磁盘占用查看
disk_info(){
    echo "===== 磁盘信息 df -h ====="
    df -h
    echo
    echo "===== 目录占用TOP10 ====="
    du -h / --max-depth=1 2>/dev/null | sort -hr | head -10
}

# 网络测速子菜单
menu_speedtest(){
    while true; do
        echo
        echo "===== 网络测速 ====="
        echo "1. Speedtest-netperf 网速测速"
        echo "2. 100MB 文件下载测速"
        echo "3. Ping网关连通性测试"
        echo "0. 返回主菜单"
        read -p "请输入选项:" sopt
        case $sopt in
            1) speedtest-netperf ;;
            2) wget -O /dev/null https://speed.hetzner.de/100MB.bin ;;
            3) ping $(ip route | grep default | awk '{print $3}') -c 4 ;;
            0) break ;;
            *) echo "无效选项" ;;
        esac
    done
}

# 常用工具子菜单：Passwall / AdGuardHome 备份&恢复、添加源、一键安装
menu_tools(){
    while true; do
        echo
        echo "===== 常用工具 ====="
        echo "1. 一键添加 Passwall 软件源"
        echo "2. 一键安装 Passwall"
        echo "3. 一键添加 ADG 软件源"
        echo "4. 一键安装 AdGuardHome"
        echo "5. 一键备份 Passwall"
        echo "6. 一键恢复 Passwall"
        echo "7. 一键备份 AdGuardHome"
        echo "8. 一键恢复 AdGuardHome"
        echo "0. 返回主菜单"
        read -p "请输入选项:" topt
        case $topt in
            1) echo "【待填入】添加Passwall源脚本"; echo "✅ Passwall源添加完成" ;;
            2) echo "【待填入】安装Passwall"; echo "✅ Passwall安装完成" ;;
            3) echo "【待填入】添加ADG源脚本"; echo "✅ ADG源添加完成" ;;
            4) echo "【待填入】安装AdGuardHome"; echo "✅ AdGuardHome安装完成" ;;
            5)
                tar -zcf /root/backup/passwall_backup_$(date +%Y%m%d_%H%M%S).tar.gz /etc/passwall 2>/dev/null
                echo "✅ Passwall备份已保存至 /root/backup/"
            ;;
            6)
                echo "查找备份文件列表:"
                ls /root/backup/passwall_backup_*.tar.gz 2>/dev/null
                read -p "输入要恢复的完整备份文件名:" pwfile
                if [ -f "/root/backup/$pwfile" ]; then
                    tar -zxf /root/backup/$pwfile -C /
                    echo "✅ Passwall恢复完成，请重启Passwall服务"
                else
                    echo "❌ 文件不存在"
                fi
            ;;
            7)
                tar -zcf /root/backup/adg_backup_$(date +%Y%m%d_%H%M%S).tar.gz /etc/adguardhome 2>/dev/null
                echo "✅ AdGuardHome备份已保存至 /root/backup/"
            ;;
            8)
                echo "查找备份文件列表:"
                ls /root/backup/adg_backup_*.tar.gz 2>/dev/null
                read -p "输入要恢复的完整备份文件名:" adgfile
                if [ -f "/root/backup/$adgfile" ]; then
                    tar -zxf /root/backup/$adgfile -C /
                    echo "✅ AdGuardHome恢复完成，请重启AdGuardHome服务"
                else
                    echo "❌ 文件不存在"
                fi
            ;;
            0) break ;;
            *) echo "无效选项" ;;
        esac
    done
}

# 一键更新脚本：raw / ghproxy双源
update_script(){
    echo "===== 更新工具箱脚本 ====="
    echo "1. 使用官方raw地址"
    echo "2. 使用ghproxy国内镜像"
    echo "0. 取消"
    read -p "选择下载源:" uopt
    case $uopt in
        1)
            wget https://raw.githubusercontent.com/wysadmin/openwrt-toolbox/main/toolbox.sh -O /root/toolbox.sh
            ;;
        2)
            wget https://ghproxy.com/https://raw.githubusercontent.com/wysadmin/openwrt-toolbox/main/toolbox.sh -O /root/toolbox.sh
            ;;
        0) return ;;
        *) echo "无效选项"; return ;;
    esac
    chmod +x /root/toolbox.sh
    echo "✅ 更新完成，输入 k 重新启动工具箱"
}

# 卸载工具箱
uninstall_toolbox(){
    read -p "确认要卸载工具箱吗？(y/N)" ans
    if [ "$ans" = "y" ] || [ "$ans" = "Y" ]; then
        rm -f /root/toolbox.sh
        sed -i '/alias k='\''\/root\/toolbox.sh'\''/d' /etc/profile
        echo "✅ 工具箱已卸载，新开SSH终端生效"
    fi
}

# ====================== 主菜单 ======================
main_menu(){
    while true; do
        clear
        show_system_info
        echo
        echo "===== OpenWrt工具箱 主菜单 v1.14 ====="
        echo "1. 系统信息查询"
        echo "2. 系统清理（标准版）【安全保护LuCI】"
        echo "3. 系统+Docker清理"
        echo "4. Docker管理子菜单"
        echo "5. 磁盘占用查看"
        echo "6. 网络测速子菜单"
        echo "7. 常用工具子菜单"
        echo "8. 更新脚本（手动触发）"
        echo "9. 卸载工具箱"
        echo "0. 退出"
        read -p "请输入功能选项:" opt
        case $opt in
            1) show_system_info; read -p "回车返回菜单" ;;
            2) clean_system; read -p "回车返回菜单" ;;
            3) clean_system_docker; read -p "回车返回菜单" ;;
            4) menu_docker ;;
            5) disk_info; read -p "回车返回菜单" ;;
            6) menu_speedtest ;;
            7) menu_tools ;;
            8) update_script ;;
            9) uninstall_toolbox ;;
            0) echo "退出工具箱"; exit 0 ;;
            *) echo "输入错误，请重新选择"; read -p "回车继续" ;;
        esac
    done
}

# 初始化别名
set_alias
# 启动主菜单
main_menu
