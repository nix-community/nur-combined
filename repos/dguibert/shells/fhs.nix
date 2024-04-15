{
  config,
  withSystem,
  ...
}: {
  flake = withSystem "x86_64-linux" (ctx @ {
    pkgs,
    system,
    ...
  }: {
    devShells.${system}.fhs =
      (pkgs.buildFHSUserEnvBubblewrap {
        name = "fhs-env";
        targetPkgs = pkgs:
          with pkgs; [
            bash
            curl
            coreutils
            gnumake
            gnutar
            gzip
            bzip2
            xz
            gawk
            gnused
            gnugrep
            glib
            binutils.bintools # glib: locale
            patch
            texinfo
            diffutils
            pkg-config
            gitMinimal
            findutils
            nix
            openssh
          ];
        multiPkgs = pkgs:
          with pkgs; [
          ];
        runScript = "bash";
        profile = ''
          export ENVRC=fhs
        '';
      })
      .env;
  });
}
