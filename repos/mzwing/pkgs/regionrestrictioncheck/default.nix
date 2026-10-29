{
  lib,
  stdenvNoCC,
  source,
  makeWrapper,
  bash,
  bind,
  coreutils,
  curl,
  gawk,
  gnugrep,
  gnused,
  jq,
  openssl,
  python3,
}:
stdenvNoCC.mkDerivation {
  pname = "regionrestrictioncheck";
  inherit (source) src;
  # Upstream publishes no tags, so version the tracked HEAD commit as unstable.
  version = "0-unstable-${source.date}";

  nativeBuildInputs = [makeWrapper];
  buildInputs = [bash];

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 check.sh $out/bin/regionrestrictioncheck
    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/regionrestrictioncheck \
      --prefix PATH : ${
      lib.makeBinPath [
        bind.host
        coreutils
        curl
        gawk
        gnugrep
        gnused
        jq
        openssl
        python3
      ]
    }
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    # `-F` runs one function for IPv4 and then IPv6; `true` checks nothing and leaves only the section headers.
    $out/bin/regionrestrictioncheck -F true | grep -F 'IPv6:'

    runHook postInstallCheck
  '';

  meta = {
    description = "Check which streaming and AI services are unlocked from this network";
    homepage = "https://github.com/1-stream/RegionRestrictionCheck";
    license = lib.licenses.agpl3Only;
    mainProgram = "regionrestrictioncheck";
    maintainers = [
      {
        name = "mzwing";
      }
    ];
    platforms = lib.platforms.all;
  };
}
