{
  fetchzip,
  lib,
  proton,
  stdenvNoCC,
  writeScript,
}:
let
  version = "11-9";
  sources = {
    aarch64 = fetchzip {
      url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton${version}/GE-Proton${version}-aarch64.tar.gz";
      sha256 = "sha256-JtOnOLh127C4cU9s2EI3A2kzL2wvjF3t+XzQAJ90zow=";
    };
    x86_64 = fetchzip {
      url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton${version}/GE-Proton${version}-x86_64.tar.gz";
      sha256 = "sha256-1o3sTPdQmIOKkm6qctt9lQfDEMCsysFyVfVK4sfRpw8=";
    };
  };
in
proton.mkProton {
  pname = "proton-ge";
  inherit version;
  src = if stdenvNoCC.targetPlatform.isAarch64 then sources.aarch64 else sources.x86_64;

  passthru = sources // {
    updateScript = writeScript "update-proton-ge" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p curl common-updater-scripts jq

      version="$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest \
        | jq -r '.tag_name | scan("GE-Proton(.*)") | .[0]')"
      ${lib.concatMapStringsSep "\n" (
        system:
        ''update-source-version "$UPDATE_NIX_ATTR_PATH" "$version" --source-key=${system} --ignore-same-version''
      ) (builtins.attrNames sources)}
    '';
  };

  meta = {
    description = "Compatibility tool for Steam Play based on Wine and additional components";
    homepage = "https://github.com/GloriousEggroll/proton-ge-custom";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
