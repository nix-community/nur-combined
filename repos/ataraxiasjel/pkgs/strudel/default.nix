{
  lib,
  stdenvNoCC,
  fetchFromGitea,
  fetchPnpmDeps,
  pnpmConfigHook,
  pnpm_10,
  nodejs_24,
  nix-update-script,
  makeWrapper,
  miniserve,
  xdg-utils,
  withServer ? false,
}:

let
  pnpm = pnpm_10;
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "strudel";
  version = "0-unstable-2026-08-19";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "uzu";
    repo = "strudel";
    rev = "8f81463b9cb5ddd5f117ed7baef6a1fde9445dc2";
    hash = "sha256-1crdG/ev1gW+OmHEjLq9Wi2bnksfQ84qRMpw2+uxyGw=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-VloQ39SAhbRw9Rc3ZAE4ngtu6OFwed5Yq8FVSZMHkNM=";
  };

  nativeBuildInputs = [
    nodejs_24
    pnpmConfigHook
    pnpm
  ]
  ++ lib.optionals withServer [ makeWrapper ];

  env.ASTRO_TELEMETRY_DISABLED = "1";

  buildPhase = ''
    runHook preBuild

    # Generates ./doc.json, imported by website/src/docs/*.jsx and the REPL
    # Reference panel; equivalent of the root package.json `prebuild` script.
    pnpm run jsdoc-json

    pnpm --dir website build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share
    cp -a website/dist $out/share/strudel
    ${lib.optionalString withServer ''
      install -Dm755 ${./strudel.sh} $out/bin/strudel
    ''}

    runHook postInstall
  '';

  postFixup = lib.optionalString withServer ''
    wrapProgram $out/bin/strudel \
      --set-default STRUDEL_ROOT $out/share/strudel \
      --prefix PATH : ${
        lib.makeBinPath [
          miniserve
          xdg-utils
        ]
      }
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = {
    description = "Music live coding environment for the browser (strudel.cc)";
    homepage = "https://strudel.cc";
    downloadPage = "https://codeberg.org/uzu/strudel";
    license = lib.licenses.agpl3Plus;
    inherit (nodejs_24.meta) platforms;
    maintainers = with lib.maintainers; [ ataraxiasjel ];
  }
  // lib.optionalAttrs withServer { mainProgram = "strudel"; };
})
