{ lib, stdenv

, fetchurl

, dpkg
, autoPatchelfHook
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "vanta-agent";
  version = "2.13.0";

  src = fetchurl {
    url = "https://vanta-agent-repo.s3.amazonaws.com/targets/versions/${finalAttrs.version}/vanta-amd64.deb";
    hash = "sha256-rO0Xfl1MDUdJByLd3kGqAP5u6OgxbaO5MJoprgW1etc=";
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
