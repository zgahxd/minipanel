# MiniPanel

面向 Debian 12 / 13（amd64 / x86_64）的轻量中文服务器管理面板。

- 直接安装到系统，通过 `https://服务器IP:8888` 登录后台。
- 一键原生安装 Nginx、PHP-FPM、Oracle MySQL 8.4 LTS。
- 添加域名并自动创建网站目录和 Nginx 配置。
- 网站暂停/恢复、服务重启、安装日志、MySQL 数据库与独立账号。
- 点击网站目录管理文件，支持子目录、新建文件夹、流式上传与下载。
- 网站域名自签名 SSL，独立的强制 HTTPS 开关；面板后台也使用 HTTPS。
- PHP、Nginx 和面板文件传输不设固定文件大小上限，适合网盘用途。

这是公开仓库，安装包和源码可直接下载，无需 GitHub 登录或 Token。

## 一键安装 / 升级

在 Debian 12 / 13 amd64 的 root 终端执行：

```bash
bash -c 'set -euo pipefail; [[ $EUID -eq 0 ]] || { echo "请使用 root 执行"; exit 1; }; source /etc/os-release; [[ ${ID:-} == debian && ${VERSION_ID:-} =~ ^(12|13)$ ]] || { echo "仅支持 Debian 12/13"; exit 1; }; apt-get update; apt-get install -y curl ca-certificates; f=$(mktemp); trap '"'"'rm -f -- "$f"'"'"' EXIT; curl -fsSL --retry 3 --proto '"'"'=https'"'"' --proto-redir '"'"'=https'"'"' https://raw.githubusercontent.com/zgahxd/minipanel/main/install-online.sh -o "$f"; printf "%s  %s\n" "d56b3e7d6ad011051648ad26b3cd0568f60ed22cc988a8443928ba9ded206265" "$f" | sha256sum --check --status; bash "$f"'
```

也可以复制仓库中的 `one-line-install.txt`。命令使用 HTTPS 下载脚本、校验脚本 SHA256，再下载安装固定的 v0.3.0 安装包并校验其 SHA256。无需 GitHub CLI 或 Token。

已安装服务器执行同一命令可更新面板代码并重启面板；保留账号、网站与数据库。正在上传或解压时不要升级。旧版本归档里的私有下载说明已过时，以这里的公开安装命令为准。

## 登录与使用

安装完成后，访问 `https://服务器公网IP:8888`。账号 `admin`，随机初始密码由安装脚本输出，并保存在服务器 `/root/minipanel-login.txt`。

放行 TCP 8888，网站另需放行 TCP 80；启用域名 SSL 时也要放行 TCP 443。后台默认生成自签名证书，安装输出提供证书指纹，可按包内说明替换为有效证书。

登录后台后点击“一键安装环境”，完成后添加域名，再去域名服务商设置 A 记录指向服务器公网 IP。

## 验证范围

30 项本地测试通过，浏览器模拟流程已验证。真实 Debian 安装、systemd、公网 TLS 与 Nginx/PHP/MySQL 实际链路仍需在空白服务器验收。完整源码、测试和中文说明都在安装包中。

## 文件

- `install-online.sh`：在线下载与校验安装器。
- `one-line-install.txt`：可直接复制到服务器的安装命令。
- `minipanel.tar.gz`：Linux 安装包（含源码）。
- `minipanel.zip`：相同内容的 ZIP 源码包。
- `SHA256SUMS`：Linux 安装包校验值。



实际上传仍受磁盘容量、网盘程序自身设置及 CDN 等外部服务限制。大文件通过流式传输控制内存占用，不提供断点续传。

### v0.3 文件管理更新

支持勾选、多选、全选、下载选中文件；单选 ZIP/TAR/TGZ 等压缩包后解压到新文件夹，完成后自动进入。增加返回、上一级和路径导航。目标目录不能已存在；暂不支持 RAR、7z、加密包。30 项测试通过，1 项 Linux 文件系统集成测试在 Windows 跳过，仍需 Debian 验收。
