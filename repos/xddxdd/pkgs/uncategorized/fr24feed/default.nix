{
  sources,
  lib,
  stdenv,
  buildFHSEnv,
  dpkg,
}:
let
  source =
    if stdenv.isx86_64 then
      sources.fr24feed-amd64
    else if stdenv.isi686 then
      sources.fr24feed-i386
    else if stdenv.isAarch32 then
      sources.fr24feed-armhf
    else if stdenv.isAarch64 then
      sources.fr24feed-arm64
    else
      throw "Unsupported architecture";

  distPkg = stdenv.mkDerivation rec {
    pname = "fr24feed-dist";
    inherit (source) version src;

    nativeBuildInputs = [ dpkg ];

    unpackPhase = ''
      runHook preUnpack

      dpkg -x $src .

      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall

      install -Dm755 usr/bin/fr24feed $out/bin/fr24feed
      install -Dm755 usr/bin/fr24feed-signup-adsb $out/bin/fr24feed-signup-adsb
      install -Dm755 usr/bin/fr24feed-signup-uat $out/bin/fr24feed-signup-uat

      runHook postInstall
    '';
  };

  fhsArgs = {
    name = "fr24feed-fhs";
    targetPkgs = _pkgs: [
      _pkgs.procps
      _pkgs.bash
    ];
    runScript = "${distPkg}/bin/fr24feed";

    unshareUser = false;
    unshareIpc = false;
    unsharePid = false;
    unshareNet = false;
    unshareUts = false;
    unshareCgroup = false;
  };

  # FHS for starting main program
  fhs = buildFHSEnv fhsArgs;

  # FHS for starting signup programs, link fr24feed.ini to current directory
  fhs-signup = buildFHSEnv (
    fhsArgs
    // {
      extraBwrapArgs = [
        "--symlink $(pwd)/fr24feed.ini /etc/fr24feed.ini"
        "--symlink $(pwd)/fr24uat-feed.ini /etc/fr24uat-feed.ini"
      ];
    }
  );
in
stdenv.mkDerivation rec {
  pname = "fr24feed";
  inherit (source) version;
  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 ${fhs}/bin/fr24feed-fhs $out/bin/fr24feed
    install -Dm755 ${fhs-signup}/bin/fr24feed-fhs $out/bin/.fr24feed-signup
    install -Dm755 ${distPkg}/bin/fr24feed-signup-adsb $out/bin/fr24feed-signup-adsb
    install -Dm755 ${distPkg}/bin/fr24feed-signup-uat $out/bin/fr24feed-signup-uat

    runHook postInstall
  '';

  postFixup = ''
    # Signup scripts need FHS for a few utils in /usr/bin
    substituteInPlace $out/bin/fr24feed-signup-adsb \
      --replace-fail "/usr/bin/fr24feed" "$out/bin/.fr24feed-signup"
    printf "\necho \"NixOS note: fr24feed.ini is generated in current directory\"\n" >> $out/bin/fr24feed-signup-adsb

    substituteInPlace $out/bin/fr24feed-signup-uat \
      --replace-fail "/usr/bin/fr24feed" "$out/bin/.fr24feed-signup"
    printf "\necho \"NixOS note: fr24uat-feed.ini is generated in current directory\"\n" >> $out/bin/fr24feed-signup-uat
  '';

  passthru = { inherit distPkg; };

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Flightradar24 Decoder & Feeder lets you effortlessly share ADS-B data with Flightradar24";
    homepage = "https://www.flightradar24.com/share-your-data";
    license = lib.licenses.unfreeRedistributable;
    mainProgram = "fr24feed";
  };
}
