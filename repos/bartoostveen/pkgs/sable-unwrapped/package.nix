{
  lib,
  stdenv,
  nix-update-script,
  fetchFromGitHub,
  fetchPnpmDeps,
  pnpm_11,
  pnpmConfigHook,
  nodejs_24,
}:

let
  pnpm = pnpm_11;
  nodejs = nodejs_24;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "sable-unwrapped";
  version = "1.22.11";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "SableClient";
    repo = "Sable";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RwYKaJ4k2lqXjVSPN/o0Qw8GIGnXfb6acCpva36qQoM=";
  };

  patches = [
    # Revert Firebase config
    ./0001-Revert-chore-add-Firebase-config-for-native-FCM-push.patch
  ];

  nativeBuildInputs = [
    pnpm
    pnpmConfigHook
    nodejs
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-kEceCe0auMjcLSXYGOGLmm0PZpoRiz+FSl/Pa+pf/3g=";
  };

  env = {
    VITE_BUILD_HASH = finalAttrs.src.rev;
    SABLE_BUILD_FLAVOR = "stable";
  };

  buildPhase = ''
    runHook preBuild

    pnpm -- config set nodeOptions "--max-old-space-size=4096"
    pnpm build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    cp -r dist $out

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "An almost stable Matrix client";
    homepage = "https://github.com/SableClient/Sable";
    changelog = "https://github.com/SableClient/Sable/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ bartoostveen ];
    platforms = lib.platforms.all;
    knownVulnerabilities = [
      ''
        Sable is not maintained upstream anymore. Sable (v1) got superseded by Sable Next (v2).
        Sable Next is almost a drop-in replacement.

        - `sable-desktop`   got replaced by `sable-next-desktop`
        - `sable-unwrapped` got replaced by `sable-next-unwrapped`
        - `sable`           got replaced by `sable-next`

        Consider switching to these packages instead. At the time of writing (2026-10-18),
        there are no known security vulnerabilities, but given the nature of the JavaScript
        ecosystem, this package not being maintained anymore should be urgent enough to switch.
      ''
    ];
  };
})
