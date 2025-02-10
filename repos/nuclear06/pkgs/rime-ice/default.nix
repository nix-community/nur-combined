# Refer to https://github.com/nix-community/nur-combined/blob/master/repos/definfo/pkgs/rime-ice/default.nix
{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  unstableGitUpdater,
  userConfig ? "",
}:
stdenvNoCC.mkDerivation {
  pname = "rime-ice";
  version = "2024.12.12";

  src = fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-ice";
    rev = "2024.12.12";
    hash = "sha256-2QZdlLGZwWIesbjYTE/2yhM1hHGVVp7jR02bR0oqxV0=";
  };

  installPhase = ''
    mkdir -p $out/share/rime-data
    rm -rf ./others
    rm -f README.md LICENSE
    rm -rf ./.github
    rm squirrel.yaml weasel.yaml
    cp -r ./* $out/share/rime-data
    if [[ -n "${userConfig}" ]];then
      echo "Specify user configuration path: [${userConfig}]"  
      cp -rf ${userConfig}/* $out/share/rime-data
    else
      echo "Not Specify any user configuration"
    fi
  '';

  passthru.updateScript = unstableGitUpdater {
    branch = "main";
    hardcodeZeroVersion = true;
  };

  meta = {
    description = "Rime 配置：雾凇拼音 | 长期维护的简体词库";
    homepage = "https://github.com/iDvel/rime-ice";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.all;
  };
}
