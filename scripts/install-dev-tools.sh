#!/usr/bin/env bash
set -euo pipefail

BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

need_x86_64() {
  [[ "$(uname -m)" == "x86_64" ]] || {
    echo "Only x86_64 is supported by this installer" >&2
    exit 1
  }
}

install_terraform() {
  local version archive sums expected actual
  version="$(curl -fsSL https://checkpoint-api.hashicorp.com/v1/check/terraform | python3 -c 'import json,sys; print(json.load(sys.stdin)["current_version"])')"
  archive="terraform_${version}_linux_amd64.zip"
  sums="terraform_${version}_SHA256SUMS"
  curl -fsSLO "https://releases.hashicorp.com/terraform/${version}/${archive}"
  curl -fsSLO "https://releases.hashicorp.com/terraform/${version}/${sums}"
  expected="$(awk -v f="$archive" '$2 == f {print $1}' "$sums")"
  actual="$(sha256sum "$archive" | awk '{print $1}')"
  [[ -n "$expected" && "$expected" == "$actual" ]] || {
    echo "Terraform checksum verification failed" >&2
    exit 1
  }
  unzip -qo "$archive"
  install -m 0755 terraform "$BIN_DIR/terraform"
}

install_kubernetes_cli() {
  az aks install-cli \
    --install-location "$BIN_DIR/kubectl" \
    --kubelogin-install-location "$BIN_DIR/kubelogin" \
    --kubelogin-version latest
}

install_helm() {
  local version archive checksum expected actual
  version="$(curl -fsSL https://get.helm.sh/helm-latest-version)"
  archive="helm-${version}-linux-amd64.tar.gz"
  checksum="${archive}.sha256sum"
  curl -fsSLO "https://get.helm.sh/${archive}"
  curl -fsSLO "https://get.helm.sh/${checksum}"
  expected="$(awk '{print $1}' "$checksum")"
  actual="$(sha256sum "$archive" | awk '{print $1}')"
  [[ -n "$expected" && "$expected" == "$actual" ]] || {
    echo "Helm checksum verification failed" >&2
    exit 1
  }
  tar -xzf "$archive"
  install -m 0755 linux-amd64/helm "$BIN_DIR/helm"
}

need_x86_64
cd "$WORK_DIR"
install_terraform
install_kubernetes_cli
install_helm
printf 'Installed tools in %s\n' "$BIN_DIR"
