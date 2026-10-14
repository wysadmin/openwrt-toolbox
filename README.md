# OpenWrt 软路由工具箱 toolbox.sh
> 适用于 OpenWrt / iStoreOS 软路由，一键多功能管理脚本

## ✨ 功能清单
### 主菜单
1. 系统信息查询：主机名、系统版本、内核、CPU、内存、网卡IP、运行时长
2. 系统清理（标准版）：清理opkg缓存、临时文件、释放内存
3. 系统+Docker清理：标准版清理 + 清理停止容器、悬空镜像
4. Docker管理子菜单
    - 查看运行容器
    - 查看本地镜像
    - 一键清理停止容器与悬空镜像
5. 磁盘占用查看：df -h + 目录占用TOP10
6. 网络测速子菜单
    - Speedtest-netperf 网速测速
    - 100MB 文件下载测速
    - Ping网关连通性测试
7. 常用命令合集子菜单
    - 网卡信息 ip a
    - iftop 实时流量监控（自动安装）
    - netstat 端口监听查看
    - 路由表查看
    - 系统日志 logread
    - CPU温度读取
8. 常用工具子菜单【重点】
    1. 一键添加 Passwall 软件源（自动多源切换，ghproxy备用镜像）
    2. 一键添加 AdGuardHome 软件源（自动多源切换，ghproxy备用镜像）
    3. 一键安装 Passwall（luci-app-passwall + 中文翻译）
    4. 一键安装 AdGuardHome（luci-app-adguardhome + 中文翻译）
    5. 一键恢复原opkg源备份
    6. 返回主菜单
    7. 一键备份 Passwall 配置
    8. 一键备份 AdGuardHome 配置
    9. 一键恢复 Passwall 备份
    10.一键恢复 AdGuardHome 备份
9. 重启路由器
10. 卸载工具箱（仅删除脚本本体，不修改任何插件配置）
11. 更新工具箱脚本（自动从Github拉取最新版本，双raw/ghproxy源）
0. 退出脚本

### 📦 配置备份功能
进入【常用工具】菜单
- **一键备份 Passwall**：打包 `/etc/config/passwall` 配置
- **一键备份 AdGuardHome**：打包luci配置 + AdGuardHome核心数据目录 `/etc/AdGuardHome/`
- **一键恢复**：从 `/root/backup` 目录选择历史备份包，覆盖配置并自动重启对应服务
> 备份文件统一存放路径：`/root/backup/`
> 命名格式：`pw_年月日_时分秒.tar.gz`、`adg_年月日_时分秒.tar.gz`

### 🔄 版本自动检测
每次启动工具箱会自动联网检测Github最新版本，
如有新版本会弹出提示，主菜单选择【11. 更新工具箱脚本】一键升级。
网络不通Github时自动跳过版本检测，不影响正常使用。
##脚本快捷命令 k
## 📥 安装方式
1. 软路由SSH连接，执行下载命令
```bash
wget https://raw.githubusercontent.com/wysadmin/openwrt-toolbox/main/toolbox.sh -O /root/toolbox.sh
chmod +x /root/toolbox.sh
