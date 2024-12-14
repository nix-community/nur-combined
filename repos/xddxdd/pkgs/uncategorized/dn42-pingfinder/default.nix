{
  sources,
  stdenv,
  lib,
  makeWrapper,
  # Runtime dependnecies
  curl,
  inetutils,
  which,
}:
let
  additionalPath = lib.makeBinPath [
    curl
    inetutils
    which
  ];
in
stdenv.mkDerivation rec {
  inherit (sources.dn42-pingfinder) pname version src;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    install -Dm755 clients/generic-linux-debian-redhat-busybox.sh $out/bin/dn42-pingfinder
    wrapProgram $out/bin/dn42-pingfinder \
      --suffix PATH : "${additionalPath}"

    runHook postInstall
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "DN42 Pingfinder";
    homepage = "https://git.dn42.dev/dn42/pingfinder/src/branch/master/clients";
    license = lib.licenses.unfreeRedistributable;
    mainProgram = "dn42-pingfinder";
  };
}
