{
  lib,
  buildGoApplication,
  callPackage,
  source,
}:
buildGoApplication {
  pname = "typenix";
  inherit (source) src;
  version = "0-unstable-${source.date}";

  modules = ./gomod2nix.toml;

  # Enable CGO for tree-sitter and gomod2nix's dependency cache.
  CGO_ENABLED = "1";

  subPackages = ["cmd/tsgo"];

  ldflags = [
    "-s"
    "-w"
  ];

  # Use the tree-sitter-nix revision upstream's flake locks.
  preBuild = ''
    ln -sfn ${(callPackage ./tree-sitter-nix.nix {}).src}/src internal/nixparser/treesitter_nix/upstream
  '';

  postInstall = ''
    mv $out/bin/tsgo $out/bin/typenix
    mkdir -p $out/share/nixlibs
    cp internal/bundled/nixlibs/*.d.ts $out/share/nixlibs/
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    test -x $out/bin/typenix
    ls $out/share/nixlibs/*.d.ts >/dev/null

    runHook postInstallCheck
  '';

  meta = {
    description = "Full typing for Nix based on TypeScript";
    homepage = "https://github.com/ryanrasti/typenix";
    license = lib.licenses.asl20;
    mainProgram = "typenix";
    maintainers = [
      {
        name = "mzwing";
      }
    ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
}
