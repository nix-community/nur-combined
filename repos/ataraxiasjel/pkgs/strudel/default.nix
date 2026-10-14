{
  lib,
  stdenvNoCC,
  fetchFromGitea,
  fetchPnpmDeps,
  pnpmConfigHook,
  pnpm_11,
  nodejs_24,
  nix-update-script,
  _experimental-update-script-combinators,
  makeWrapper,
  miniserve,
  xdg-utils,
  withServer ? false,
}:

let
  pnpm = pnpm_11;
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "strudel";
  version = "0-unstable-2026-10-13";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "uzu";
    repo = "strudel";
    rev = "a3302cf16746d2f6f7c706be47f1ca85db497aa5";
    hash = "sha256-atDL1D3SkkkVrJBRlON4vB+VoQQs62/RPUL2Cj7VHJM=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-jZW5iWClF5OmmodVBNFw+StQTdXmz0DGeBOFEAjz9OQ=";
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

  passthru.updateScript = _experimental-update-script-combinators.sequence [
    (nix-update-script {
      extraArgs = [ "--version=branch" ];
    })
    [
      ./fixup-version.sh
      "./pkgs/strudel"
    ]
  ];

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
