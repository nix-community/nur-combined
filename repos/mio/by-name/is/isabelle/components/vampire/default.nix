{
  lib,
  pkgs,
  stdenv,
  gcc14Stdenv,
  fetchurl,
  fetchFromGitHub,
  vampireStdenv ? if stdenv.cc.isGNU then gcc14Stdenv else stdenv,
  writeTextFile,
}:

(pkgs.vampire.override {
  stdenv = vampireStdenv;
  enableZ3 = false;
}).overrideAttrs
  (
    finalAttrs: prevAttrs: {
      version = "4.8";

      # Isabelle uses a branch of vampire that is not in the normal release line
      # that adds support for higher order goals
      src = fetchFromGitHub {
        owner = "vprover";
        repo = "vampire";
        tag = "v4.8HO4Sledgahammer";
        hash = "sha256-CmppaGa4M9tkE1b25cY1LSPFygJy5yV4kpHKbPqvcVE=";
      };

      patches = [
        (fetchurl {
          url = "https://raw.githubusercontent.com/sempiternal-aurora/nixpkgs/30b07b7e68d352cc26eb51d6b2cf402845b16e77/pkgs/by-name/is/isabelleComponents/vampire/add-install-directive.patch";
          hash = "sha256-RaCXzwdJp+9NoyyTE+vdZ9GSQi+4viThdLT3Iuo4zes=";
        })
      ];

      postInstall = ''
        mv $out/bin/vampire_rel $out/bin/vampire
      '';

      cmakeFlags = prevAttrs.cmakeFlags ++ [
        (lib.cmakeFeature "CMAKE_BUILD_HOL" "On")
      ];

      passthru.settings = writeTextFile {
        name = "vampire-settings";
        text = ''
          VAMPIRE_HOME=${finalAttrs.finalPackage}/bin
          VAMPIRE_VERSION=${finalAttrs.version}
          VAMPIRE_EXTRA_OPTIONS="--mode casc"
        '';
        destination = "/etc/settings";
      };
    }
  )
