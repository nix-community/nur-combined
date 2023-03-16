{ stdenv, lib, unzip, requireFile, hostPlatform, autoPatchelfHook }: let
  subdir =
    if hostPlatform.isAarch64 then "aarch64"
    else if hostPlatform.isx86_64 then "x64"
    else if hostPlatform.isx86 then "x86"
    else if hostPlatform.isPowerPC or false then "ppc64"
    else throw "Unknown nvflash platform ${hostPlatform.config}";
in stdenv.mkDerivation rec {
  pname = "nvflash";
  version = "5.692";

  nativeBuildInputs = [ unzip autoPatchelfHook ];

  src = requireFile {
    url = "https://www.techpowerup.com/download/nvidia-nvflash/";
    name = "nvflash_${version}_linux.zip";
    sha256 = "1ywpiw467pvkwy90slpfgpq2bnjvj64ji0g94cx7kx31gz5sn5dz";
  };
  sourceRoot = ".";

  buildPhase = "true";

  inherit subdir;
  installPhase = ''
    install -Dm0755 -t $out/bin $subdir/nvflash
  '';

  passthru.ci.skip = true;
  meta = with lib; {
    platforms = [ "aarch64-linux" "x86_64-linux" "i686-linux" "powerpc64-linux" ];
  };
}
