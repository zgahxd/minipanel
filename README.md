# MiniPanel

面向 Debian 12 / 13（amd64 / x86_64）的轻量中文服务器管理面板。

- 直接安装到系统，通过 `https://服务器IP:8888` 登录后台。
- 一键原生安装 Nginx、PHP-FPM、Oracle MySQL 8.4 LTS。
- 添加域名并自动创建网站目录和 Nginx 配置。
- 网站暂停/恢复、服务重启、安装日志、MySQL 数据库与独立账号。
- 点击网站目录管理文件，支持子目录、新建文件夹、流式上传与下载。
- 网站域名自签名 SSL，独立的强制 HTTPS 开关；面板后台也使用 HTTPS。
- PHP、Nginx 和面板文件传输不设固定文件大小上限，适合网盘用途。

这是私有仓库。安装包位于 Releases，未经授权的下载请求可能返回 404；这不代表文件不存在。

## 私有仓库安装

使用拥有此仓库读取权限的 GitHub 账号授权，或使用仅选中本仓库、具有 **Contents: Read-only** 权限的 fine-grained Personal Access Token。Token 只在服务器终端输入，不要发到聊天、写进脚本或仓库。

### 一键安装（在 Debian 的 root 终端执行）

复制下面这一条命令执行：

```bash
bash -c 'set -euo pipefail; set +x; umask 077; [[ $EUID -eq 0 ]] || { echo "请在 Debian 的 root 终端执行"; exit 1; }; source /etc/os-release; [[ ${ID:-} == debian && ${VERSION_ID:-} =~ ^(12|13)$ ]] || { echo "仅支持 Debian 12/13"; exit 1; }; apt-get update; apt-get install -y gh ca-certificates; bootstrap=$(mktemp /tmp/minipanel-bootstrap.XXXXXXXX); trap '"'"'unset GH_TOKEN; rm -f -- "$bootstrap"'"'"' EXIT; if [[ -z ${GH_TOKEN:-} ]] && ! gh auth status --hostname github.com >/dev/null 2>&1; then read -r -s -p "GitHub 只读 Token（输入不显示）：" GH_TOKEN </dev/tty; echo; [[ -n $GH_TOKEN ]] || exit 1; export GH_TOKEN; fi; gh api --hostname github.com -H "Accept: application/vnd.github.raw+json" "repos/zgahxd/minipanel/contents/install-online.sh?ref=main" > "$bootstrap"; printf "%s  %s\n" "0c894b6b25501499554a1aa315b7480d36d7786ebe37a24e5f130a018f2763d3" "$bootstrap" | sha256sum --check --status; bash "$bootstrap";'
```

也可以复制仓库中的 `one-line-install.txt` 内容执行。命令会安装下载依赖，提示输入 Token，然后下载带校验的一键安装脚本。已有 `GH_TOKEN` 环境变量时无需重复输入。

### 已配置 GitHub CLI 授权的服务器

下载 `install-online.sh` 后，在 root 终端执行：

```bash
bash install-online.sh
```

脚本下载固定版本 `v0.2.0`，核对安装包的固定 SHA256，再执行包内的系统安装程序。安装完成后面板无需访问 GitHub；再次下载或更新私有安装包才需要授权。

## 登录与使用

安装完成后，访问 `https://服务器公网IP:8888`。账号 `admin`，随机初始密码由安装脚本输出，并保存在服务器 `/root/minipanel-login.txt`。

放行 TCP 8888，网站另需放行 TCP 80；启用域名 SSL 时也要放行 TCP 443。后台默认生成自签名证书，安装输出提供证书指纹，可按包内说明替换为有效证书。

登录后台后点击“一键安装环境”，完成后添加域名，再去域名服务商设置 A 记录指向服务器公网 IP。

## 验证范围

23 项本地测试通过，浏览器模拟流程已验证。真实 Debian 安装、systemd、公网 TLS 与 Nginx/PHP/MySQL 实际链路仍需在空白服务器验收。完整源码、测试和中文说明都在安装包中。

## 文件

- `install-online.sh`：在线下载与校验安装器。
- `one-line-install.txt`：可直接复制到服务器的安装命令。
- `minipanel.tar.gz`：Linux 安装包（含源码）。
- `minipanel.zip`：相同内容的 ZIP 源码包。
- `SHA256SUMS`：Linux 安装包校验值。

[GitHub 私有 Release 下载文档](https://docs.github.com/en/rest/releases/assets)

实际上传仍受磁盘容量、网盘程序自身设置及 CDN 等外部服务限制。大文件通过流式传输控制内存占用，不提供断点续传。
