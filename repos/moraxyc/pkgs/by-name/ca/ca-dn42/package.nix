{
  lib,
  stdenvNoCC,
  fetchurl,
  openssl,
  curl,
  coreutils,
  makeBinaryWrapper,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "ca-dn42";
  version = "0.3.9";

  # src = fetchurl {
  #   url = "https://ca.dn42.us/ca.dn42";
  #   hash = "sha256-k0rpw0Dcbwb2rAp71hpI0MC1OguLv3VZQ+/QHoEH+e0=";
  # };
  src = ./ca.dn42;

  unpackPhase = "true";

  nativeBuildInputs = [ makeBinaryWrapper ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 $src $out/bin/ca.dn42

    runHook postInstall
  '';

  postFixup = ''
    patchShebangs $out/bin
    wrapProgram $out/bin/ca.dn42 --prefix PATH : "${
      lib.makeBinPath [
        coreutils
        curl
        openssl
      ]
    }"
  '';

  meta = {
    description = "DN42 Self-Serve CA Client";
    homepage = "https://wiki.dn42.dev/services/Automatic-CA";
    license = lib.licenses.cc0;
    maintainers = with lib.maintainers; [ moraxyc ];
    platforms = lib.platforms.all;
    mainProgram = "ca.dn42";
  };
})
