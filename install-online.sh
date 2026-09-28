#!/usr/bin/env bash
# MiniPanel public GitHub release installer. Debian 12/13 amd64, root.
set -euo pipefail
umask 077
[[ $EUID -eq 0 ]] || { echo '请使用 root 运行此安装脚本。'; exit 1; }
source /etc/os-release
[[ ${ID:-} == debian && ${VERSION_ID:-} =~ ^(12|13)$ ]] || { echo '仅支持 Debian 12 / 13'; exit 1; }
[[ $(dpkg --print-architecture) == amd64 ]] || { echo '仅支持 amd64 / x86_64'; exit 1; }
repo='zgahxd/minipanel'
version='v0.4.1'
if ! command -v curl >/dev/null 2>&1 || [[ ! -s /etc/ssl/certs/ca-certificates.crt ]]; then
    apt-get update
    apt-get install -y curl ca-certificates
fi
download_dir=$(mktemp -d /tmp/minipanel-download.XXXXXXXX)
cleanup() { rm -rf -- "$download_dir"; }
trap cleanup EXIT
echo "正在下载 MiniPanel $version（公开下载，无需 Token）…"
curl --fail --show-error --silent --location --retry 3 --connect-timeout 30 --proto '=https' --proto-redir '=https' \
    "https://github.com/$repo/releases/download/$version/minipanel.tar.gz" -o "$download_dir/minipanel.tar.gz"
expected_sha256='2ffeaaee8adddc984ce6d4ff72e4e05d7081ae49dbcefbbe571e2b5d7cec05fe'
printf '%s  %s\n' "$expected_sha256" "$download_dir/minipanel.tar.gz" | sha256sum --check --status
echo '安装包 SHA256 校验通过。'
tar -xzf "$download_dir/minipanel.tar.gz" -C "$download_dir"
bash "$download_dir/minipanel/install.sh"
