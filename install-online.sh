#!/usr/bin/env bash
# MiniPanel private GitHub release installer. Run as root on Debian 12/13 amd64.
set -euo pipefail
set +x
umask 077

[[ $EUID -eq 0 ]] || { echo '请使用 root 运行此在线安装脚本。'; exit 1; }
source /etc/os-release
[[ ${ID:-} == debian && ${VERSION_ID:-} =~ ^(12|13)$ ]] || { echo '仅支持 Debian 12 / 13'; exit 1; }
[[ $(dpkg --print-architecture) == amd64 ]] || { echo '仅支持 amd64 / x86_64'; exit 1; }

repo='zgahxd/minipanel'
version='v0.3.0'
download_dir=$(mktemp -d /tmp/minipanel-download.XXXXXXXX)
cleanup() { unset GH_TOKEN; rm -rf -- "$download_dir"; }
trap cleanup EXIT

if ! command -v gh >/dev/null 2>&1; then
    apt-get update
    apt-get install -y gh ca-certificates
fi

if [[ -z ${GH_TOKEN:-} ]] && ! gh auth status --hostname github.com >/dev/null 2>&1; then
    echo '私有仓库需要下载授权。请使用仅可读取 zgahxd/minipanel 的 GitHub Token。'
    read -r -s -p 'GitHub Token（输入不显示）：' GH_TOKEN </dev/tty
    echo
    [[ -n $GH_TOKEN ]] || { echo '未提供 Token，停止下载。'; exit 1; }
    export GH_TOKEN
fi

echo "正在从私有仓库下载 MiniPanel $version…"
gh release download "$version" --repo "$repo" \
    --pattern minipanel.tar.gz --pattern SHA256SUMS --dir "$download_dir"

# This checksum is pinned to the packaged release, not downloaded as a trust root.
expected_sha256='eb04ef330158481d29045942e0ca67b82ab73947e2ce6367654c1f646d32a279'
printf '%s  %s\n' "$expected_sha256" "$download_dir/minipanel.tar.gz" | sha256sum --check --status
echo '安装包 SHA256 校验通过。'
tar -xzf "$download_dir/minipanel.tar.gz" -C "$download_dir"

# The system installer does not need GitHub credentials.
unset GH_TOKEN GITHUB_TOKEN
bash "$download_dir/minipanel/install.sh"
