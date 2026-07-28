{
  lib,
  vacuRoot,
  vaculib,
  ...
}:
let
  apkgs = lib.pipe (import /${vacuRoot}/androidPackages { inherit vaculib; }) [
    builtins.attrNames
    (lib.remove "buildGradleAndroidPackage")
  ];
in
{
  vacuBuilds = lib.mkMerge [
    (lib.genAttrs apkgs (_: {
      multiSystem = true;
    }))
    { "aegis-authenticator".aliases = [ "aegis" ]; }
  ];

  perSystem = { pkgs, ... }: {
    vacuBuildDerivations = lib.genAttrs apkgs (name: pkgs.${name});

    devShells.fdroid =
      let
        jdk = pkgs.jdk_headless;
        inherit (pkgs.androidenv.androidPkgs) androidsdk;
      in
      pkgs.mkShell {
        packages = [
          pkgs.fdroidserver
          jdk
          pkgs.apksigner
          androidsdk
        ];

        env = {
          JAVA_HOME = jdk.home;
          ANDROID_HOME = "${androidsdk}/libexec/android-sdk";
        };

        shellHook = ''
          export PATH="$PATH:${androidsdk}/bin"
        '';
      };
  };
}
