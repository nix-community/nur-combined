{ lib
, buildGoModule
, fetchFromGitLab
, stdenv
, patchForNixos ? true
}:

let
  os =
    if stdenv.isLinux then "linux"
    else if stdenv.isDarwin then "darwin"
    else throw "unsupported platform";

in
buildGoModule rec {
  pname = "device-flasher";
  version = "1.0.8";

  src = fetchFromGitLab {
    owner = "CalyxOS";
    repo = "device-flasher";
    rev = version;
    hash = "sha256-QW6f+uDNlpyajpLxX8t+N1r3rwo7m7hpAug0OkiBJOA=";
  };

  patches = lib.optionals patchForNixos [
    # Patch based on https://web.archive.org/web/20221231222031/https://michzappa.com/blog/flashing-calyxos-on-nixos.html
    ./nixos-adaptation.patch
  ];

  vendorHash = null;

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
      mv $binary-flasher.${os} $out/bin/$binary-flasher
    done

    runHook postInstall
  '';

  meta = with lib; {
    description = "Tool that flashes CalyxOS on your device";
    homepage = "https://github.com/calyxos/device-flasher";
    license = licenses.asl20;
    platforms = platforms.linux ++ platforms.darwin;
    mainProgram = "device-flasher";
    maintainers = with maintainers; [ wolfangaukang ];
  };
}
