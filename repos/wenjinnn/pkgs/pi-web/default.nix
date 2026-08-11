{
  lib,
  buildNpmPackage,
  fetchurl,
  makeWrapper,
  nodejs,
  nodejs-slim,
  python3,
  pkg-config,
}:

buildNpmPackage rec {
  pname = "pi-web";
  version = "1.202608.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/@jmfederico/pi-web/-/pi-web-${version}.tgz";
    hash = "sha256-TEm10SpUUNfbzBMEEvAk6SYQKXSGgBB6EvYnxb1NjoE=";
  };

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
    ${nodejs}/bin/node - <<'NODE'
    const fs = require("fs");
    const pkg = JSON.parse(fs.readFileSync("package.json", "utf8"));
    pkg.dependencies = { ...pkg.dependencies, ...pkg.peerDependencies };
    delete pkg.devDependencies;
    delete pkg.peerDependencies;
    delete pkg.peerDependenciesMeta;
    fs.writeFileSync("package.json", JSON.stringify(pkg, null, 2) + String.fromCharCode(10));
    NODE
  '';

  npmDepsHash = "sha256-H5HFXfkWmhFXO7We19t8Vo1HHKPDX3urioJ1u44GxP0=";
  npmDepsFetcherVersion = 2;

  nativeBuildInputs = [
    makeWrapper
    pkg-config
    python3
  ];

  buildInputs = [ nodejs ];

  dontNpmBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules/pi-web
    cp -r dist node_modules package.json LICENSE README.md $out/lib/node_modules/pi-web/

    mkdir -p $out/bin
    makeWrapper ${nodejs-slim}/bin/node $out/bin/pi-web \
      --add-flags "$out/lib/node_modules/pi-web/dist/cli.js"
    makeWrapper ${nodejs-slim}/bin/node $out/bin/pi-web-server \
      --add-flags "$out/lib/node_modules/pi-web/dist/server/index.js"
    makeWrapper ${nodejs-slim}/bin/node $out/bin/pi-web-sessiond \
      --add-flags "$out/lib/node_modules/pi-web/dist/server/sessiond.js"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Web UI and persistent session manager for Pi Coding Agent";
    homepage = "https://pi-web.dev/";
    license = licenses.mit;
    mainProgram = "pi-web";
    platforms = platforms.all;
  };
}
