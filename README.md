# OpenWRT-工具箱
OpenWrt / iStoreOS 交互式一键工具箱，软件源自动切换

## ✨功能清单
1. 系统信息查询（主机名、系统版本、CPU、运行时长、温度）
2. 系统清理、系统+Docker一键清理
3. Docker容器/镜像管理
4. 磁盘占用查看
5. 网络测速、ping网关测试
6. 常用网络命令集合（ip、iftop、netstat、路由、日志）
7. 软件源工具：
    - Passwall软件源自动探测（Github+ghproxy双源自动切换），一键安装Passwall
    - AdGuardHome软件源自动探测，一键安装AdGuardHome
    - 一键备份&恢复opkg源配置，防止源配置翻车
8. 软路由重启

## 🚀快速安装命令
复制下面这行到OpenWrt/iStoreOS终端执行
```bash
wget https://raw.githubusercontent.com/wysadmin/openwrt-toolbox/main/toolbox.sh -O /root/toolbox.sh
chmod +x /root/toolbox.sh
/root/toolbox.sh
## 🗑️ 快速卸载命令
复制下面这行到OpenWrt/iStoreOS终端执行
```bash
# 仅删除工具箱脚本（保留插件与源备份）
rm -f /root/toolbox.sh

# 完全清理（脚本 + 源备份文件一起删除）
rm -f /root/toolbox.sh /etc/opkg/distfeeds.conf.bak
