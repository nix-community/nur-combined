{
  lib,
  buildGoModule,
  fetchFromGitHub,
  clojure,
  nix-update-script,
}:

let
  version = "0.2.5";
in

buildGoModule rec {
  pname = "glojure";
  inherit version;

  src = fetchFromGitHub {
    owner = "glojurelang";
    repo = "glojure";
    rev = "v${version}";
    hash = "sha256-Dm4rBCCUElR8Qbz1m9ae3JyNdr7pXFZn0cMYSQLrNY0=";
  };

  vendorHash = "sha256-bofeBp8aa/I5jhblv+BhqHX9tmD1hDgUBwEFJpLH/A8=";

  nativeBuildInputs = [ clojure ];

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
    license = lib.licenses.epl10;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
