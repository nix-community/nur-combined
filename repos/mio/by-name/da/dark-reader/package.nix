{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_22,
}:

buildNpmPackage (finalAttrs: {
  pname = "dark-reader";
  version = "4.9.128";

  src = fetchFromGitHub {
    owner = "darkreader";
    repo = "darkreader";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZeQsQb4m19mhqmackQYfaqs3Vk2GkIBTefluWU4ALMQ=";
  };

  nodejs = nodejs_22;

  npmDepsHash = "sha256-9aH2gUbbAj6xpPoe2FJ5KYMR4KVDxdD6P8f73soc5Ns=";

  buildPhase = ''
    runHook preBuild
    npm run build:firefox
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/dark-reader
    cp -r build/release/firefox/. $out/share/dark-reader/
    runHook postInstall
  '';

  doCheck = false;

  meta = {
    changelog = "https://github.com/darkreader/darkreader/releases/tag/v${finalAttrs.version}";
    description = "Dark Reader browser extension — eye-care dark mode for every website";
    homepage = "https://darkreader.org";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.all;
  };
})
