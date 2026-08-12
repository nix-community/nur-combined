{
  lib,
  stdenv,
  buildGoModule,
  nodejs,
  pnpm_9,
  fetchPnpmDeps,
  pnpmConfigHook,
  go-bindata,
  go-bindata-assetfs,
  sources,
}:
let
  inherit (sources.sun-panel) version src;

  web = stdenv.mkDerivation (finalWebAttrs: {
    pname = "sun-panel-web";
    inherit version src;

    pnpmDeps = fetchPnpmDeps {
      inherit (finalWebAttrs) pname version src;
      pnpm = pnpm_9;
      fetcherVersion = 3;
      pnpmInstallFlags = [ "--registry=https://registry.npmmirror.com" ];
      prePnpmInstall = ''
        echo 'registry=https://registry.npmmirror.com' >> .npmrc
        if [ -n "''${https_proxy:-}" ]; then
          PROXY=$(printf '%s' "$https_proxy" | sed 's|^socks5://|socks5h://|')
          echo "proxy=$PROXY" >> .npmrc
          echo "https-proxy=$PROXY" >> .npmrc
        fi
      '';
      hash = "sha256-Zv+/e+go6jyxBwaO4YVtn11fNPzDOuxLlShaQvUOgzU=";
    };

    nativeBuildInputs = [
      nodejs
      pnpmConfigHook
      pnpm_9
    ];

    buildPhase = ''
      runHook preBuild
      pnpm run build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      cp -r dist $out
      runHook postInstall
    '';
  });
in
buildGoModule (finalAttrs: {
  pname = "sun-panel";
  inherit version src;

  sourceRoot = "${finalAttrs.src.name}/service";

  vendorHash = "sha256-dSwR0Z8r0EtMdLexjtd/WisqFWX6xC57Ve6ar6J4Hqk=";

  nativeBuildInputs = [
    go-bindata
    go-bindata-assetfs
  ];

  env.CGO_ENABLED = "1";
  env.GOPROXY = "https://goproxy.cn,direct";
  env.GOSUMDB = "sum.golang.google.cn";

  ldflags = [ "-X sun-panel/global.RUNCODE=release" ];

  preBuild = ''
    go-bindata-assetfs -o=assets/bindata.go -pkg=assets assets/...
    rm -f bindata.go
  '';

  postInstall = ''
    mkdir -p $out/share/sun-panel
    cp -r ${web} $out/share/sun-panel/web
    mkdir -p $out/libexec
    mv $out/bin/sun-panel $out/libexec/sun-panel
    cat > $out/bin/sun-panel <<EOF
    #!/bin/sh
    DATA_DIR="\''${SUN_PANEL_DATA_DIR:-\''${XDG_DATA_HOME:-\$HOME/.local/share}/sun-panel}"
    mkdir -p "\$DATA_DIR"
    if [ ! -e "\$DATA_DIR/web" ]; then
      ln -s $out/share/sun-panel/web "\$DATA_DIR/web"
    fi
    cd "\$DATA_DIR"
    exec $out/libexec/sun-panel "\$@"
    EOF
    chmod +x $out/bin/sun-panel
  '';

  meta = {
    changelog = "https://github.com/hslr-s/sun-panel/releases/tag/v${finalAttrs.version}";
    description = "Server and NAS navigation panel, homepage, browser homepage";
    homepage = "https://github.com/hslr-s/sun-panel";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = [
      {
        github = "zhyiheihei";
        name = "zhyiheihei";
      }
    ];
    mainProgram = "sun-panel";
  };
})
