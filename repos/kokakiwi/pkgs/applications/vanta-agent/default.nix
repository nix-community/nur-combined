{ lib, stdenv

, fetchurl

, dpkg
, autoPatchelfHook
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "vanta-agent";
  version = "2.13.1";

  src = fetchurl {
    url = "https://vanta-agent-repo.s3.amazonaws.com/targets/versions/${finalAttrs.version}/vanta-amd64.deb";
    hash = "sha256-Ct74W9BYlC3lmh/CrnR2z60tFUyV1bDGL6wHv/dnD0Y=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
  ];

  unpackPhase = ''
    runHook preUnpack

    dpkg-deb -x $src .

    runHook postUnpack
  '';

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -a var $out/
    cp -a etc $out/

    mkdir -p $out/bin
    ln -s $out/var/vanta/vanta-cli $out/bin/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Vanta Agent";
    homepage = "https://vanta.com";
    maintainers = with maintainers; [ matdibu ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "vanta-cli";
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
})
