{
  lib,
  buildGoModule,
  fetchFromGitHub,
  go_1_26,
  stdenvNoCC,
  bun2nix,
  makeWrapper,
  nodejs,
}:

let
  version = "3.0.1";

  src = fetchFromGitHub {
    owner = "txperl";
    repo = "PixivBiu";
    tag = "v${version}";
    hash = "sha256-iQ9c/0c21JZBLINNVeCgkisAClkReOR0xfTibwKprWQ=";
  };

  frontend = stdenvNoCC.mkDerivation {
    pname = "pixivbiu-frontend";
    inherit version src;

    nativeBuildInputs = [
      bun2nix.hook
      nodejs
    ];

    bunRoot = "frontend";
    bunDeps = bun2nix.fetchBunDeps {
      bunNix = ./bun.nix;
    };
    bunInstallFlags = [
      "--frozen-lockfile"
      "--linker=hoisted"
    ];
    dontRunLifecycleScripts = true;

    postBunSetInstallCacheDirPhase = ''
      chmod -R u+w "$BUN_INSTALL_CACHE_DIR"
    '';

    postPatch = ''
      substituteInPlace frontend/bun.lock \
        --replace-fail "https://registry.npmmirror.com/" "https://registry.npmjs.org/"
    '';

    buildPhase = ''
      runHook preBuild

      cd frontend
      bun run build
      cd ..

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r internal/web/dist/. $out/

      runHook postInstall
    '';
  };
in
(buildGoModule.override { go = go_1_26; }) (finalAttrs: {
  pname = "pixivbiu";
  inherit version src;

  vendorHash = "sha256-C2Zegax6HtK95QLcXHVpL+znsWKu1RdQ2QnYVN6oFOs=";

  nativeBuildInputs = [ makeWrapper ];

  postConfigure = ''
    find internal/web/dist -mindepth 1 ! -name .gitkeep -delete
    cp -r ${frontend}/. internal/web/dist/
  '';

  subPackages = [ "cmd/server" ];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  env.CGO_ENABLED = 0;

  postInstall = ''
    mv $out/bin/server $out/bin/pixivbiu
  '';

  postFixup = ''
    wrapProgram $out/bin/pixivbiu \
      --run 'export PIXIVBIU_DATA_DIR="''${PIXIVBIU_DATA_DIR:-''${XDG_DATA_HOME:-$HOME/.local/share}/pixivbiu}"'
  '';

  meta = {
    description = "Pixiv auxiliary tool, built from source";
    homepage = "https://github.com/txperl/PixivBiu";
    changelog = "https://github.com/txperl/PixivBiu/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "pixivbiu";
    platforms = lib.platforms.linux;
  };
})
