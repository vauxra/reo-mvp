# Tooling state

Created: 2026-08-29

## Installed now

| Tool | Version | Path | Install path |
|---|---:|---|---|
| Terraform | 1.16.0 | `~/.local/bin/terraform` | `scripts/install-dev-tools.sh`; HashiCorp SHA-256 checked |
| kubectl | 1.37.0 | `~/.local/bin/kubectl` | `az aks install-cli` |
| kubelogin | 0.2.19 | `~/.local/bin/kubelogin` | `az aks install-cli` |
| Helm | 4.2.4 | `~/.local/bin/helm` | `scripts/install-dev-tools.sh`; Helm SHA-256 checked |

`~/.local/bin` is already on PATH.

## Already installed

| Tool | Version | Path |
|---|---:|---|
| Azure CLI | 2.89.1 | `/usr/bin/az` |
| GitHub CLI | 2.98.0 | `/usr/bin/gh` |
| Docker | 29.1.3 | `/usr/bin/docker` |
| Git | 2.43.0 | `/usr/bin/git` |
| Python | 3.13.11 | `/home/micheal/miniconda3/bin/python3` |
| VS Code CLI | 1.135.0 | `/usr/bin/code` |

## Cleanup later

Remove only tools installed for REO:

```bash
rm -f ~/.local/bin/terraform ~/.local/bin/kubectl ~/.local/bin/kubelogin ~/.local/bin/helm
```

Do not remove tools in the "Already installed" table.

## Verification

```bash
terraform version
kubectl version --client
kubelogin --version
helm version --short
```
