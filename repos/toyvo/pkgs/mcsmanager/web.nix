{
  lib,
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation rec {
  pname = "mcsmanager-web";
  version = "10.12.2";

  src = fetchurl {
    url = "https://github.com/MCSManager/MCSManager/releases/download/v${version}/mcsmanager_linux_web_only_release.tar.gz";
    hash = "sha256-SMz4pj4VP4nZJYZhNBSOJxO6dtJRVSBx9UIbAnA+3T8=";
  };

  sourceRoot = "mcsmanager/web";

  dontBuild = true;
  dontConfigure = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/mcsmanager/web
    cp -r app.js app.js.map node_modules public package.json $out/lib/mcsmanager/web/
    runHook postInstall
  '';

  meta = with lib; {
    description = "MCSManager web panel - distributed game server management interface";
    homepage = "https://mcsmanager.com/";
    license = licenses.asl20;
    platforms = platforms.linux;
    maintainers = [
      {
        name = "Collin Diekvoss";
        email = "Collin@Diekvoss.com";
        matrix = "@toyvo:matrix.org";
        github = "ToyVo";
        githubId = 5168912;
      }
    ];
  };
}
