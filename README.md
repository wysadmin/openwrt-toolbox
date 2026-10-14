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
11. 更新工具箱脚本（手动检测版本并更新，双raw/ghproxy源）
0. 退出脚本

### 📦 配置备份功能
进入【常用工具】菜单
- **一键备份 Passwall**：打包 `/etc/config/passwall` 配置
- **一键备份 AdGuardHome**：打包luci配置 + AdGuardHome核心数据目录 `/etc/AdGuardHome/`
- **一键恢复**：从 `/root/backup` 目录选择历史备份包，覆盖配置并自动重启对应服务
> 备份文件统一存放路径：`/root/backup/`
> 命名格式：`pw_年月日_时分秒.tar.gz`、`adg_年月日_时分秒.tar.gz`

### 🔄 版本更新说明
**不会自动检测版本**，每次启动工具箱不联网检测更新。
如需检查新版本、升级脚本，手动在主菜单选择【11. 更新工具箱脚本】。

## 📥 安装方式
1. 软路由SSH连接，执行下载命令
```bash
wget https://raw.githubusercontent.com/wysadmin/openwrt-toolbox/main/toolbox.sh -O /root/toolbox.sh
chmod +x /root/toolbox.sh






## ⌨️ 脚本启动快捷命令

安装完成后，SSH 终端输入 k 启动工具箱


## 📝 使用说明

1. 脚本使用 ash 编写，原生兼容 OpenWrt/iStoreOS，无需额外依赖
2. 更新脚本：主菜单选择`11`，手动检测版本并一键拉取最新代码
3. 备份 / 恢复配置：进入【常用工具】操作；**恢复操作会覆盖现有配置，恢复前请确认**
4. 卸载脚本：主菜单选择`10`，只会删除 toolbox.sh，不会删除任何插件、备份文件

## ⚠️ 注意事项

- 执行插件安装、源添加、配置恢复建议在空闲网络时段操作
- AdGuardHome 备份包含数据库，备份包体积会大于 Passwall
- 备份文件保存在`/root/backup`，软路由重置前请手动下载备份包到本地电脑保存
- 本脚本仅提供快捷管理功能，**修改系统配置前请自行做好重要数据备份**
