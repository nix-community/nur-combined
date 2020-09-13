{ stdenv, lib, fetchFromGitHub, linuxManualConfig, python, features ? {}, kernelPatches ? [], randstructSeed ? null }:

# Additional features cannot be added to this kernel
assert features == {};

let
  passthru = { features = {}; };
  version = "5.6.0-1137-ayufan";

  src = fetchFromGitHub {
    owner = "ayufan-rock64";
    repo = "linux-mainline-kernel";
    rev = version;
    sha256 = "1qcw7h8kkj6kv8vzfrnhih0854h1iss65grjc8p8npff1397l480";
  };

  extraOptions = {
    BINFMT_MISC = "y";
  };

  configfile = stdenv.mkDerivation {
    name = "ayufan-rock64-linux-kernel-config-${version}";
    version = version;
    inherit src;

    buildPhase = ''
      make rockchip_linux_defconfig

      cat > arch/arm64/configs/nixos_extra.config <<EOF
      ${lib.concatStringsSep "\n" (
        lib.mapAttrsToList (n: v: "CONFIG_${n}=${v}") extraOptions
      )}
      EOF

      make nixos_extra.config
    '';

    installPhase = ''
      cp .config $out
    '';
  };

  drv = linuxManualConfig ({
    inherit stdenv kernelPatches;

    inherit src;

    inherit version;

    modDirVersion = "5.6.0";

    inherit configfile;

    extraMeta.platforms = [ "aarch64-linux" ];

    allowImportFromDerivation = true; # Let nix check the assertions about the config
  } // lib.optionalAttrs (randstructSeed != null) { inherit randstructSeed; });

in

stdenv.lib.extendDerivation true passthru drv
