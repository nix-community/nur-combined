{
  lib,
  stdenv,
  makeWrapper,
  nodejs,
  pnpm_9,
  fetchPnpmDeps,
  pnpmConfigHook,
  python3,
  python3Packages,
  sources,
}:
let
  inherit (sources.filecodebox) version src;

  frontend = stdenv.mkDerivation (finalWebAttrs: {
    pname = "filecodebox-frontend";
    inherit (sources.filecodebox-frontend) version src;

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
      hash = "sha256-+Z+MXHNPRw13B5mnJEm/axLe/AKRjJCJ4cnKmx3rswA=";
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

  python = python3.withPackages (ps: [
    ps.aioboto3
    ps.aiofiles
    ps.aiohttp
    ps.fastapi
    ps.pydantic
    ps.python-multipart
    ps.starlette
    ps.uvicorn
    python3Packages.tortoise-orm
  ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "filecodebox";
  inherit version src;

  nativeBuildInputs = [
    makeWrapper
  ];

  dontConfigure = true;
  dontBuild = true;

  postPatch = ''
    sed -i 's/^from pathlib import Path$/from pathlib import Path\nimport os/' core/settings.py
    sed -i 's|^data_root = BASE_DIR / "data"$|data_root = Path(os.environ.get("FILECODEBOX_DATA_DIR", str(BASE_DIR / "data")))|' core/settings.py
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/filecodebox/themes
    cp -r . $out/share/filecodebox/
    cp -r ${frontend}/. $out/share/filecodebox/themes/2024

    makeWrapper ${python}/bin/python $out/bin/filecodebox \
      --chdir "$out/share/filecodebox" \
      --run 'DATA_DIR="''${FILECODEBOX_DATA_DIR:-''${XDG_DATA_HOME:-$HOME/.local/share}/filecodebox}"; mkdir -p "$DATA_DIR"; export FILECODEBOX_DATA_DIR="$DATA_DIR"' \
      --add-flag "-m" \
      --add-flag "uvicorn" \
      --add-flag "--host" \
      --add-flag "0.0.0.0" \
      --add-flag "--port" \
      --add-flag "12345" \
      --add-flag "main:app"

    runHook postInstall
  '';

  meta = {
    changelog = "https://github.com/vastsa/FileCodeBox/releases/tag/v${finalAttrs.version}";
    description = "Lightweight anonymous file sharing server with a FastAPI backend and Vue 3 theme";
    homepage = "https://github.com/vastsa/FileCodeBox";
    license = lib.licenses.lgpl3Only;
    platforms = lib.platforms.linux;
    maintainers = [
      {
        github = "zhyiheihei";
        name = "zhyiheihei";
      }
    ];
    mainProgram = "filecodebox";
  };
})
