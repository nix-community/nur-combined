#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq

cd pkgs/by-name/home-assistant-operating-system

curl https://api.github.com/repos/home-assistant/operating-system/releases/latest | jq -r '
def asset_by_name(name):
  first(.[] | select(.name == name)) | {
    url: .browser_download_url,
    sha256: .digest | sub("^sha256:"; "")
  };
{
  platforms: {
      "aarch64-linux":  (
        "haos_generic-aarch64-" + .tag_name + ".qcow2.xz" as $name
        | .assets | asset_by_name($name)
      ),
      "x86_64-linux":  (
        "haos_ova-" + .tag_name + ".qcow2.xz" as $name
        | .assets | asset_by_name($name)
      )
  },
  version: .tag_name
}
' > src.json
