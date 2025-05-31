{
  pkgs,
  lib,
  kernel,
  kernelModuleMakeFlags,
  bc,
  ...
}:
let
  version = "1.19.10";
  pname = "RTL8851BU";
  src = pkgs.fetchFromGitHub {
    owner = "fofajardo";
    repo = "rtl8851bu";
    rev = "c623a50381243b41276862352020a469ca768ecc";
    hash = "sha256-6su7+1UklLrTqoHlF7GHqxzb1l1YLn1Fyv7hekI4cwU=";
  };
  runtime = [ ];
  librarys = [ ];
in
pkgs.stdenv.mkDerivation rec{
  inherit pname version src;

  nativeBuildInputs = [
    bc
    pkgs.nukeReferences
  ] ++ kernel.moduleBuildDependencies;
  buildInputs = runtime;
  makeFlags = kernelModuleMakeFlags;

  hardeningDisable = [ "pic" ];

  prePatch = ''
    substituteInPlace ./Makefile \
    --replace-fail '$(KSRC)' "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build" \
    --replace-fail /sbin/depmod \# \
    --replace-fail '$(MODDESTDIR)' "$out/lib/modules/${kernel.modDirVersion}/kernel/net/wireless/"
  '';

  preInstall = ''
    mkdir -p "$out/lib/modules/${kernel.modDirVersion}/kernel/net/wireless/"
  '';

  enableParallelBuilding = true;

  meta = with lib; {
    description = "Driver for RTL8851BU";
    homepage = "https://github.com/fofajardo/rtl8851bu.git";
    license = licenses.gpl2;
    sourceProvenance = [
      sourceTypes.fromSource
    ];
    platforms = platforms.linux;
  };
}
