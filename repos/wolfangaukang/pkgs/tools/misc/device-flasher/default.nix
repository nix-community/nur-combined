{ lib
, buildGoModule
, fetchFromGitHub
, stdenv
}:

let
  os = if stdenv.isLinux then "linux"
       else if stdenv.isDarwin then "darwin"
       else throw "unsupported platform";

in buildGoModule rec {
  pname = "device-flasher";
  version = "1.0.6";

  src = fetchFromGitHub {
    owner = "CalyxOS";
    repo = "device-flasher";
    rev = version;
    sha256 = "sha256-0BZRPaXc2bWH/WuMYk2zdx5y4HWHA3ZrTxbxmBqL4BQ=";
  };

  vendorSha256 = null;

  buildPhase = ''
    runHook preBuild

    for binary in device parallel; do
      make $binary-flasher.${os}
    done

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    for binary in device parallel; do
      mv $binary-flasher.${os} $out/bin
    done

    runHook postInstall
  '';

  meta = with lib; {
    description = "Tool that flashes CalyxOS on your device";
    homepage = "https://github.com/calyxos/device-flasher";
    license = licenses.asl20;
    platforms = with platforms; [ linux darwin ];
    maintainers = with maintainers; [ wolfangaukang ];
  };
}
