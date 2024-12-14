{
  lib,
  buildGoModule,
  fetchFromGitHub,
  clojure,
  nix-update-script,
}:

let
  version = "0.2.6";
in

buildGoModule {
  pname = "glojure";
  inherit version;

  src = fetchFromGitHub {
    owner = "glojurelang";
    repo = "glojure";
    rev = "refs/tags/v${version}";
    hash = "sha256-WzyslO3YaGPJnINDSjk3AcjC/raVh5c5K2a6EBZC4Rk=";
  };

  vendorHash = "sha256-bofeBp8aa/I5jhblv+BhqHX9tmD1hDgUBwEFJpLH/A8=";

  nativeBuildInputs = [ clojure ];

  ldflags = [
    "-s"
    "-w"
  ];

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  checkFlags = [
    # Requires network access
    "-skip=FuzzCLJConformance/seed"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "glj";
    description = "Clojure interpreter hosted on Go, with extensible interop support";
    homepage = "https://github.com/glojurelang/glojure";
    changelog = "https://github.com/glojurelang/glojure/releases/tag/v${version}";
    license = lib.licenses.epl10;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
