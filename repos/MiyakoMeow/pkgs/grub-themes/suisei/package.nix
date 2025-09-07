{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:
stdenvNoCC.mkDerivation rec {
  pname = "suisei";
  version = "0-unstable-2024-11-01";

  src = fetchFromGitHub {
    owner = "kirakiraAZK";
    repo = "suiGRUB";
    rev = "2ea338454810e6fd3ad04166bc84c576e29a6bea";
    sha256 = "sha256-besErd3N+iVGiReYGzo6H3JKsgQOyRaRbe6E0wKKW54=";
  };

  installPhase = ''
    mkdir $out
    cp -r $src/* $out

    # 验证主题文件
    if [ ! -e "$out/theme.txt" ]; then
      echo "ERROR: theme.txt not found in output directory"
      exit 1
    fi
  '';

  passthru = {
    updateScript = nix-update-script {
      attrPath = "suisei";
      extraArgs = [
        "--version=branch"
      ];
    };
  };

  # 禁用自动解压步骤
  dontUnpack = true;
  dontBuild = true;

  meta = with lib; {
    description = "suiGRUB";
    homepage = "https://github.com/kirakiraAZK/suiGRUB";
    license = licenses.unlicense;
  };
}
