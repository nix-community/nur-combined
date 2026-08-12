{pkgs ? import <nixpkgs> {}}: let
  inherit (pkgs) stdenv lib fetchFromGitHub linuxPackages;
  inherit (linuxPackages) kernel;
in
  stdenv.mkDerivation rec {
    pname = "samsung-volatile";
    name = "samsung-volatile-module-${version}-${kernel.version}";
    version = "1.0";
    passthru.moduleName = "samsung-volatile";

    src = fetchFromGitHub {
      owner = "TahlonBrahic";
      repo = "samsung-volatile";
      rev = "refs/heads/main";
      hash = "sha256-2+507B3WYDLKqGZlbduA5Mo2qeNWOFyzRnMlTu97kmQ=";
    };

    hardeningDisable = ["pic" "format"];
    nativeBuildInputs = kernel.moduleBuildDependencies;

    makeFlags =
      kernel.makeFlags
      ++ [
        "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
      ];

    installPhase = ''
      runHook preInstall
      install -D samsung-volatile.ko -t $out/lib/modules/${kernel.modDirVersion}/extra
      runHook postInstall
    '';

    enableParallelBuilding = true;

    meta = {
      description = "A modified samsung-laptop kernel module that can boot from EFI systems";
      homepage = "https://github.com/tahlonbrahic/linux";
      license = lib.licenses.gpl2;
      maintainers = [];
      platforms = lib.platforms.linux;
    };
  }
