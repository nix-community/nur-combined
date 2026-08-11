{
  bun2nix,
  stdenv,
  lib,
  ...
}:
bun2nix.writeBunApplication {
  packageJson = ./package.json;

  src = ./.;

  # nextjs relies on platform specific bun instances
  bunInstallFlags = [
    "--cpu=*"
  ]
  # non linux builds want symlinks instead of hardlinks for nextjs
  ++ lib.optionals (stdenv.hostPlatform.system != "x86_64-linux") [
    "--linker=isolated"
    "--backend=symlink"
  ];

  buildPhase = ''
    bun run build
  '';

  # nextjs needs to bind to a port during the build process
  __darwinAllowLocalNetworking = true;

  startScript = ''
    bun run start
  '';

  bunDeps = bun2nix.fetchBunDeps {
    bunNix = ./bun.nix;
  };
}
