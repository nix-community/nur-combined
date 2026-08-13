{
  lib,
  stdenv,
  nix-update-script,
  fetchFromGitHub,
  fetchPnpmDeps,
  pnpm_10,
  pnpmConfigHook,
  nodejs_24,
}:

let
  pnpm = pnpm_10;
  nodejs = nodejs_24;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "sable-unwrapped";
  version = "nightly-unstable-2026-08-12";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "SableClient";
    repo = "Sable";
    rev = "47a3965d7e1a0ee711f16911820f3990592d6b96";
    hash = "sha256-I4Qj3BgKAusKZuWRtwXG3aCK3wDuajXSg/lIBP1klD4=";
  };

  nativeBuildInputs = [
    pnpm
    pnpmConfigHook
    nodejs
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-twGUkNt5vVj4GujXPehY22bkZZdomQTzjGqUD8pQmOk=";
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
    changelog = "https://github.com/SableClient/Sable/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ bartoostveen ];
    platforms = lib.platforms.all;
  };
})
