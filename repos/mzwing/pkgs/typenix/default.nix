{
  lib,
  buildGo126Module,
  source,
  tree-sitter-nix,
}:
buildGo126Module {
  inherit (source) pname src;
  version = "0-unstable-${source.date}";

  vendorHash = "sha256-dBeHvSWuiCoAMezWx0VXstrATvmTILv183o2jWnc058=";

  # CGO is needed for tree-sitter-nix
  env.CGO_ENABLED = "1";

  subPackages = ["cmd/tsgo"];

  ldflags = [
    "-s"
    "-w"
  ];

  # Point upstream symlink at tree-sitter-nix source
  preBuild = ''
    ln -sfn ${tree-sitter-nix.src}/src internal/nixparser/treesitter_nix/upstream
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
