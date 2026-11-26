{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-better-render";
  version = "0.5.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "JeffeyChou";
    repo = "pi-better-render";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4R657QxdYzwaNzwhY7/zHw7jom7GHUy8VN8qS1jqXUc=";
  };

  patches = [ ./bundle-beautiful-mermaid.patch ];

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-k71fw2WNP249pa5DiE7iUcPdQuDpkltLdT1J1s1B9r4=";

  npmInstallFlags = [ "--omit=dev" ];

  dontNpmBuild = true;

  postInstall = ''
    cp -r $out/lib/node_modules/pi-better-render/. $out
    rm -rf $out/lib
  '';

  meta = {
    description = "Streaming-first rich rendering for Pi's TUI";
    homepage = "https://github.com/JeffeyChou/pi-better-render";
    downloadPage = "https://github.com/JeffeyChou/pi-better-render/releases";
    changelog = "https://github.com/JeffeyChou/pi-better-render/releases/tag/v${finalAttrs.version}";
    license = with lib.licenses; [
      mit
      asl20
    ];
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
