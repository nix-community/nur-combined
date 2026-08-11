{ stdenv
, fetchurl
, lib
}:
let
  version = "20.2.7.LTS";
in
stdenv.mkDerivation {
  pname = "armcl";
  inherit version;

  src = fetchurl {
    url = "https://dr-download.ti.com/software-development/ide-configuration-compiler-or-debugger/MD-sDOoXkUcde/${version}/ti_cgt_tms470_${version}_linux-x64_installer.bin";
    sha256 = "sha256-nUKX9eCs9m9zNn9stanW0Rt5ln1OF5IEkgvVyHGtR6M=";
    executable = true;
  };

  dontConfigure = true;
  dontBuild = true;
  dontUnpack = true;
  dontPatch = true;
  nativeBuildInputs = [
    stdenv.cc
  ];

  installPhase = ''
    runHook preInstall
    $(cat $NIX_CC/nix-support/dynamic-linker) $src --prefix $out --unattendedmodeui none --mode unattended
    runHook postInstall
  '';

  postInstall = ''
    mv $out/ti-cgt-arm_${version}/* $out
    rm -r $out/ti-cgt-arm_${version}
    rm $out/ti_cgt_tms470*uninstaller.*
  '';

  meta = with lib; {
    description = "Texas Instruments Arm C/C++ Compiler Tools";
    homepage = "https://www.ti.com/tool/ARM-CGT";
    license = licenses.unfree;
    platforms = platforms.linux;
    maintainers = [ maintainers.detegr ];
  };
}
