from pathlib import Path


def test_installer_targets_user_local_bin_and_required_tools():
    script = Path("scripts/install-dev-tools.sh")
    assert script.exists()
    content = script.read_text()
    assert '"$HOME/.local/bin"' in content
    for tool in ("terraform", "kubectl", "kubelogin", "helm"):
        assert tool in content
