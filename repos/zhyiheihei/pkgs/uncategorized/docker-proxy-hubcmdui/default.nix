{
  lib,
  stdenv,
  fetchNpmDeps,
  buildNpmPackage,
  nodejs,
  sources,
}:
let
  inherit (sources.docker-proxy-hubcmdui) version src;

  lockfile = ./package-lock.json;

  web = buildNpmPackage (finalAttrs: {
    pname = "docker-proxy-hubcmdui-web";
    inherit version src;

    sourceRoot = "${finalAttrs.src.name}/hubcmdui/src";

    postPatch = ''
      sed -i 's|https://registry.npmjs.org/|https://registry.npmmirror.com/|g' package-lock.json
      mkdir -p ../web
      chmod -R u+w ../web
    '';

    npmDeps = fetchNpmDeps {
      inherit (finalAttrs) src sourceRoot postPatch;
      name = "docker-proxy-hubcmdui-web-npm-deps";
      hash = "sha256-FtW9nVP+3RChc3luvncxnUSWByBiXbQlTBWp7m9BZj8=";
      npmRegistryOverridesString = builtins.toJSON {
        "registry.npmjs.org" = "https://registry.npmmirror.com";
      };
    };

    npmInstallFlags = [ "--registry=https://registry.npmmirror.com" ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r ../web/dist $out/dist
      runHook postInstall
    '';
  });

  server = buildNpmPackage (finalAttrs: {
    pname = "docker-proxy-hubcmdui-server";
    inherit version src;

    sourceRoot = "${finalAttrs.src.name}/hubcmdui";

    postPatch = ''
      cp ${lockfile} package-lock.json
    '';

    npmDeps = fetchNpmDeps {
      inherit (finalAttrs) src sourceRoot postPatch;
      name = "docker-proxy-hubcmdui-server-npm-deps";
      hash = "sha256-vEDR7okpuGbIhfQB7yabO266Lmy1M2X5TBbE38Gbv3k=";
      npmRegistryOverridesString = builtins.toJSON {
        "registry.npmjs.org" = "https://registry.npmmirror.com";
      };
    };

    npmInstallFlags = [ "--registry=https://registry.npmmirror.com" ];
    dontNpmBuild = true;
  });
in
stdenv.mkDerivation (finalAttrs: {
  pname = "docker-proxy-hubcmdui";
  inherit version src;

  sourceRoot = "${finalAttrs.src.name}/hubcmdui";

  nativeBuildInputs = [ nodejs ];

  dontStrip = true;

  postPatch = ''
    substituteInPlace database/database.js utils/database-checker.js \
      --replace "path.join(__dirname, '../data/app.db')" "path.join(process.env.HUBCMDUI_DATA_DIR || path.join(__dirname, '..'), 'data', 'app.db')"
    substituteInPlace logger.js \
      --replace "path.join(__dirname, 'logs')" "path.join(process.env.HUBCMDUI_DATA_DIR || path.join(__dirname, '..'), 'logs')"
    substituteInPlace init-dirs.js \
      --replace "path.join(__dirname, 'logs')" "path.join(process.env.HUBCMDUI_DATA_DIR || path.join(__dirname, '..'), 'logs')" \
      --replace "path.join(__dirname, 'data')" "path.join(process.env.HUBCMDUI_DATA_DIR || path.join(__dirname, '..'), 'data')" \
      --replace "path.join(__dirname, 'temp')" "path.join(process.env.HUBCMDUI_DATA_DIR || path.join(__dirname, '..'), 'temp')"
    substituteInPlace routes/login.js \
      --replace "path.join(__dirname, '../config/users.json')" "path.join(process.env.HUBCMDUI_DATA_DIR || path.join(__dirname, '..'), 'config', 'users.json')"
    substituteInPlace compatibility-layer.js \
      --replace "path.join(__dirname, './data/config.json')" "path.join(process.env.HUBCMDUI_DATA_DIR || path.join(__dirname, '..'), 'data', 'config.json')"
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/libexec/hubcmdui $out/bin
    cp -r . $out/libexec/hubcmdui/
    rm -rf $out/libexec/hubcmdui/node_modules
    cp -r ${server}/lib/node_modules/hubcmdui/node_modules $out/libexec/hubcmdui/node_modules
    cp -r ${web}/dist $out/libexec/hubcmdui/web/dist
    cat > $out/bin/docker-proxy-hubcmdui <<EOF
    #!/bin/sh
    DATA_DIR="\''${HUBCMDUI_DATA_DIR:-\''${XDG_DATA_HOME:-\$HOME/.local/share}/docker-proxy-hubcmdui}"
    mkdir -p "\$DATA_DIR/data" "\$DATA_DIR/logs" "\$DATA_DIR/temp" "\$DATA_DIR/config"
    export HUBCMDUI_DATA_DIR="\$DATA_DIR"
    export NODE_ENV=production
    exec ${nodejs}/bin/node $out/libexec/hubcmdui/server.js "\$@"
    EOF
    chmod +x $out/bin/docker-proxy-hubcmdui
    runHook postInstall
  '';

  meta = {
    changelog = "https://github.com/dqzboy/Docker-Proxy/releases/tag/v${finalAttrs.version}";
    description = "Web management panel for the Docker-Proxy registry proxy";
    homepage = "https://github.com/dqzboy/Docker-Proxy";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
    maintainers = [
      {
        github = "zhyiheihei";
        name = "zhyiheihei";
      }
    ];
    mainProgram = "docker-proxy-hubcmdui";
  };
})
