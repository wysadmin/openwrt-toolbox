#!/bin/ash
# OpenWrt/iStoreOS 工具箱 toolbox.sh v1.13
# 修复：安全清理，不再全盘删除/tmp，避免menu.d/luci-base损坏

# ========== 配置 ==========
SCRIPT_NAME="toolbox.sh"
SCRIPT_PATH="/root/${SCRIPT_NAME}"
BACKUP_DIR="/root/backup"
GITHUB_RAW="https://raw.githubusercontent.com/wysadmin/openwrt-toolbox/main/toolbox.sh"
GHPROXY_RAW="https://ghproxy.com/${GITHUB_RAW}"

# 创建备份目录
mkdir -p ${BACKUP_DIR}

# 设置别名 k，实现输入k直接启动脚本
grep -q "alias k='${SCRIPT_PATH}'" /etc/profile || echo "alias k='${SCRIPT_PATH}'" >> /etc/profile
source /etc/profile

# ========== 函数定义 ==========
show_menu() {
clear
echo "====================================="
echo "        OpenWrt软路由工具箱 v1.13"
echo "====================================="
echo " 1. 系统信息查询"
echo " 2. 系统清理（标准版｜安全，不损坏LuCI菜单）"
echo " 3. 系统+Docker清理"
echo " 4. Docker管理子菜单"
echo " 5. 磁盘占用查看"
echo " 6. 网络测速子菜单"
echo " 7. 常用命令合集子菜单"
echo " 8. 常用工具子菜单【重点】"
echo " 9. 重启路由器"
echo "10. 卸载工具箱（仅删脚本本体）"
echo "11. 更新工具箱脚本（双源raw/ghproxy）"
echo " 0. 退出脚本"
echo "====================================="
read -p "请输入选项数字：" opt
case ${opt} in
1) show_system_info ;;
2) clean_system_safe ;;
3) clean_system_docker ;;
4) docker_menu ;;
5) show_disk ;;
6) speed_menu ;;
7) cmd_menu ;;
8) tool_menu ;;
9) reboot_router ;;
10) uninstall_toolbox ;;
11) update_script ;;
0) exit 0 ;;
*) echo "输入无效！回车返回菜单"; read; show_menu ;;
esac
}

# 1.系统信息
show_system_info(){
clear
echo "===== 系统信息 ====="
echo "主机名: $(hostname)"
echo "系统版本: $(cat /etc/openwrt_release | grep DISTRIB_DESCRIPTION | cut -d\' -f2)"
echo "内核版本: $(uname -r)"
echo "CPU: $(cat /proc/cpuinfo | grep model\ name | head -n1 | cut -d: -f2)"
echo "内存信息:"
free -h
echo -e "\n网卡IP:"
ip a | grep inet
echo -e "\n运行时长: $(uptime)"
echo -e "\n回车返回菜单"
read
show_menu
}

# 2.安全系统清理【核心修复，不再rm -rf /tmp/*】
clean_system_safe(){
clear
echo "===== 执行安全系统清理 ====="
echo "清理 opkg 软件包缓存..."
opkg clean
echo "清理 LuCI网页缓存..."
rm -rf /tmp/luci-*
echo "清理opkg临时包列表缓存..."
rm -rf /tmp/opkg-lists
echo "释放内存缓存..."
sync && echo 3 > /proc/sys/vm/drop_caches
echo "✅ 安全清理完成，不会破坏LuCI菜单menu.d"
echo -e "\n回车返回菜单"
read
show_menu
}

#3.系统+Docker清理
clean_system_docker(){
clear
echo "===== 系统+Docker清理 ====="
#先执行安全系统清理
opkg clean
rm -rf /tmp/luci-*
rm -rf /tmp/opkg-lists
sync && echo 3 > /proc/sys/vm/drop_caches
#docker清理
if command -v docker >/dev/null;then
echo "清理停止的容器..."
docker container prune -f
echo "清理悬空镜像..."
docker image prune -f
echo "✅ 系统+Docker清理完成"
else
echo "未检测到Docker，仅完成系统清理"
fi
echo -e "\n回车返回菜单"
read
show_menu
}

#4 Docker子菜单
docker_menu(){
clear
echo "===== Docker管理子菜单 ====="
echo "1.查看运行容器"
echo "2.查看本地镜像"
echo "3.一键清理停止容器+悬空镜像"
echo "0.返回主菜单"
read -p "选择：" dopt
case $dopt in
1) docker ps ;;
2) docker images ;;
3)
if command -v docker >/dev/null;then
docker container prune -f
docker image prune -f
echo "Docker垃圾清理完成"
else
echo "未安装Docker"
fi
;;
0) show_menu ;;
*) echo "无效输入";read;docker_menu;;
esac
echo -e "\n回车返回Docker菜单"
read
docker_menu
}

#5磁盘占用
show_disk(){
clear
echo "===== 磁盘整体占用 df -h ====="
df -h
echo -e "\n===== 目录占用TOP10 ====="
du -h / --max-depth=1 2>/dev/null | sort -hr | head -10
echo -e "\n回车返回菜单"
read
show_menu
}

#6测速子菜单
speed_menu(){
clear
echo "===== 网络测速子菜单 ====="
echo "1.Speedtest-netperf网速测速"
echo "2.100MB文件下载测速"
echo "3.Ping网关连通测试"
echo "0.返回主菜单"
read -p "选择：" sopt
case $sopt in
1)
if ! command -v speedtest-netperf >/dev/null;then
opkg update
opkg install speedtest-netperf
fi
speedtest-netperf
;;
2) wget -O /dev/null https://speed.hetzner.de/100MB.bin ;;
3)
gw=$(ip route | grep default | awk '{print $3}' | head -1)
ping -c4 $gw
;;
0) show_menu ;;
*) echo "无效输入";read;speed_menu;;
esac
echo -e "\n回车返回测速菜单"
read
speed_menu
}

#7常用命令合集
cmd_menu(){
clear
echo "===== 常用命令合集子菜单 ====="
echo "1.网卡信息 ip a"
echo "2.iftop实时流量监控（自动安装）"
echo "3.netstat端口监听查看"
echo "4.路由表查看"
echo "5.系统日志 logread"
echo "6.CPU温度读取"
echo "0.返回主菜单"
read -p "选择：" copt
case $copt in
1) ip a ;;
2)
if ! command -v iftop >/dev/null;then
opkg update
opkg install iftop
fi
iftop
;;
3) netstat -tulnp ;;
4) ip route ;;
5) logread ;;
6) cat /sys/class/thermal/thermal_zone0/temp | awk '{print $1/1000" ℃"}' ;;
0) show_menu ;;
*) echo "无效输入";read;cmd_menu;;
esac
echo -e "\n回车返回命令菜单"
read
cmd_menu
}

#8常用工具子菜单
tool_menu(){
clear
echo "===== 常用工具子菜单【重点】 ====="
echo "1.一键添加 Passwall 软件源（ghproxy备用）"
echo "2.一键添加 AdGuardHome 软件源（ghproxy备用）"
echo "3.一键安装 Passwall（luci-app-passwall +中文翻译）"
echo "4.一键安装 AdGuardHome（luci-app-adguardhome +中文翻译）"
echo "5.一键恢复原opkg源备份"
echo "6.返回主菜单"
echo "7.一键备份 Passwall 配置"
echo "8.一键备份 AdGuardHome 配置"
echo "9.一键恢复 Passwall 备份"
echo "10.一键恢复 AdGuardHome 备份"
read -p "选择：" topt
case $topt in
1) echo "这里填写你的添加passwall源脚本";read;tool_menu ;;
2) echo "这里填写添加AdGuardHome源脚本";read;tool_menu ;;
3) opkg update;opkg install luci-app-passwall luci-i18n-passwall-zh-cn;read;tool_menu ;;
4) opkg update;opkg install luci-app-adguardhome luci-i18n-adguardhome-zh-cn;read;tool_menu ;;
5) echo "恢复原opkg源";read;tool_menu ;;
6) show_menu ;;
7) backup_passwall ;;
8) backup_adg ;;
9) restore_passwall ;;
10) restore_adg ;;
*) echo "无效输入";read;tool_menu;;
esac
}

# 备份 Passwall
backup_passwall(){
clear
timestamp=$(date +%Y%m%d_%H%M%S)
bkfile="${BACKUP_DIR}/pw_${timestamp}.tar.gz"
tar -zcvf ${bkfile} /etc/config/passwall 2>/dev/null
echo "✅ Passwall备份成功：${bkfile}"
read
tool_menu
}

#备份 AdGuardHome
backup_adg(){
clear
timestamp=$(date +%Y%m%d_%H%M%S)
bkfile="${BACKUP_DIR}/adg_${timestamp}.tar.gz"
tar -zcvf ${bkfile} /etc/config/adguardhome /etc/AdGuardHome 2>/dev/null
echo "✅ AdGuardHome备份成功：${bkfile}"
read
tool_menu
}

#恢复Passwall
restore_passwall(){
clear
echo "可用Passwall备份列表："
ls ${BACKUP_DIR}/pw_*.tar.gz 2>/dev/null
read -p "输入完整备份文件名：" fname
if [ -f "${BACKUP_DIR}/${fname}" ];then
tar -zxf ${BACKUP_DIR}/${fname} -C /
/etc/init.d/passwall restart
echo "✅ Passwall配置恢复完成，已重启服务"
else
echo "文件不存在"
fi
read
tool_menu
}

#恢复AdGuardHome
restore_adg(){
clear
echo "可用AdGuardHome备份列表："
ls ${BACKUP_DIR}/adg_*.tar.gz 2>/dev/null
read -p "输入完整备份文件名：" fname
if [ -f "${BACKUP_DIR}/${fname}" ];then
tar -zxf ${BACKUP_DIR}/${fname} -C /
/etc/init.d/adguardhome restart
echo "✅ AdGuardHome配置恢复完成，已重启服务"
else
echo "文件不存在"
fi
read
tool_menu
}

#9重启路由
reboot_router(){
clear
read -p "确认重启路由器？ y/N " yn
if [ "$yn" = "y" ];then
reboot
fi
show_menu
}

#10卸载工具箱
uninstall_toolbox(){
clear
read -p "确认卸载工具箱（仅删除toolbox.sh，保留备份文件）? y/N " yn
if [ "$yn" = "y" ];then
#删除别名
sed -i '/alias k='${SCRIPT_NAME}'/d' /etc/profile
rm -f ${SCRIPT_PATH}
echo "✅ 工具箱脚本已删除，/root/backup备份文件保留"
exit 0
fi
show_menu
}

#11更新脚本 双源优先raw，失败自动切ghproxy
update_script(){
clear
echo "尝试从github raw下载更新..."
wget --timeout=10 ${GITHUB_RAW} -O ${SCRIPT_PATH}.tmp
if [ $? -eq 0 ];then
mv ${SCRIPT_PATH}.tmp ${SCRIPT_PATH}
chmod +x ${SCRIPT_PATH}
echo "✅ 更新成功！重新执行 k 启动新版"
else
echo "raw下载失败，切换ghproxy镜像"
wget --timeout=10 ${GHPROXY_RAW} -O ${SCRIPT_PATH}.tmp
if [ $? -eq 0 ];then
mv ${SCRIPT_PATH}.tmp ${SCRIPT_PATH}
chmod +x ${SCRIPT_PATH}
echo "✅ ghproxy镜像更新成功！执行 k 启动新版"
else
rm -f ${SCRIPT_PATH}.tmp
echo "❌ 更新失败，请检查网络"
fi
fi
chmod +x ${SCRIPT_PATH}
read
show_menu
}

# 程序入口
show_menu
