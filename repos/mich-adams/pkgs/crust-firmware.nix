{
  buildPackages,
  fetchFromGitHub,
  flex,
  lib,
  stdenv,
  bison,
swig,
or1k-newlib,
}:

let
  or1k-toolchain = buildPackages.pkgsCross.or1k.buildPackages;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "crust-firmware";
  version = "0.6";

  src = fetchFromGitHub {
    owner = "crust-firmware";
    repo = "crust";
    rev = "v${finalAttrs.version}";
    hash = "sha256-zalBVP9rI81XshcurxmvoCwkdlX3gMw5xuTVLOIymK5=";
  };

  depsBuildBuild = [
    stdenv.cc
  ];

  nativeBuildInputs = [
    flex
    bison
    swig
  ] ++ (with or1k-toolchain; [
    binutils
    gcc
  ]);

  # postPatch = ''
  #   substituteInPlace Makefile --replace "= lex" '= ${lib.getExe' buildPackages.flex "flex"}'
  # '';

	#env.CROSS_COMPILE = "or1k-elf-";
	#env.HOST_COMPILE = "${buildPackages.stdenv.cc}/bin/${buildPackages.stdenv.cc.targetPrefix}";
	#env.HOSTCC       = "${buildPackages.stdenv.cc}/bin/${buildPackages.stdenv.cc.targetPrefix}gcc";
	#env.HOSTLD       = "${buildPackages.stdenv.cc}/bin/${buildPackages.stdenv.cc.targetPrefix}ld";
  buildPhase = ''

    make pinephone_defconfig
    # make pinephone_defconfig
    make scp
  '';

  installPhase = ''
    mkdir $out
    cp -v build/scp/scp.bin $out
  '';

  meta = with lib; {
    description = "Libre SCP firmware for Allwinner sunxi SoCs";
    homepage = "https://github.com/crust-firmware/crust";
    license = with licenses; [ bsd3 gpl2Only mit ];
    maintainers = [ ];
    platforms = platforms.all;
  };
})
