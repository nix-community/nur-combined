{pkgs ? import <nixpkgs> {}}: let
  inherit (pkgs) stdenv lib fetchFromGitHub linuxPackages_latest;
  inherit (linuxPackages_latest) kernel;
in
  stdenv.mkDerivation rec {
    pname = "samsung-galaxybook-extras";
    version = "0.9";
    name = "${pname}-${version}-${kernel.modDirVersion}";
    passthru.moduleName = "samsung-galaxybook-extras";

    src = fetchFromGitHub {
      owner = "TahlonBrahic";
      repo = "samsung-galaxybook-extras";
      rev = "refs/heads/fix_platform_driver";
      sha256 = "sha256-8y5lSAIM8YgVC7DhTCaYG8nTxmwryjyVt7hTHGAG85U=";
    };

    hardeningDisable = ["pic" "format"];
    nativeBuildInputs = kernel.moduleBuildDependencies;

    kernelVersion = kernel.modDirVersion;

    makeFlags = [
      "KERNELRELEASE=${kernel.modDirVersion}"
      "KERNEL_SRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
      "INSTALL_MOD_PATH=$(out)/lib/modules/${kernel.modDirVersion}/kernel"
    ];

    installPhase = ''
        mkdir -p $out/lib/modules/$kernelVersion
            for x in $(find . -name '*.ko'); do
        cp $x $out/lib/modules/$kernelVersion/
      done
    '';

    enableParallelBuilding = true;

    meta = {
      description = "A samsung galaxybook kernel module made for the Galaxy Book 2";
      homepage = "https://github.com/joshuagrisham/samsung-galaxybook-extras";
      license = lib.licenses.gpl2;
      maintainers = [];
      platforms = lib.platforms.linux;
    };
  }
