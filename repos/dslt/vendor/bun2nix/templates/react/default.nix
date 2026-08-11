{ stdenv, bun2nix, ... }:
stdenv.mkDerivation {
  pname = "react-bun2nix-example";
  version = "1.0.0";

  src = ./.;

  nativeBuildInputs = [
    bun2nix.hook
  ];

  bunDeps = bun2nix.fetchBunDeps {
    bunNix = ./bun.nix;
  };

  buildPhase = ''
    bun run build \
      --minify
  '';

  installPhase = ''
    mkdir -p $out/dist

    cp -R ./dist $out
  '';
}
