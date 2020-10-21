{ stdenv, dpkg, buildFHSUserEnv, udev, fetchurl, buildEnv }:

let
  arch = {
    "x86_64-linux" = "x86_64";
    "i686-linux"   = "x86";
  }.${stdenv.system};

  jlinkSrc = stdenv.mkDerivation rec {
    name = "jlink-v${version}";
    version = "6.42c";
    version' = stdenv.lib.replaceStrings ["."] [""] version;

    src = fetchurl {
      url = "https://www.segger.com/downloads/jlink/JLink_Linux_V${version'}_${arch}.deb";
      # TODO: fix  sha256 for i686
      sha256 = "1ladqgszyicjg01waasbn5b6fngv4ap3vcksxcv1smrgr9yv9bv4";
      curlOpts = "-d accept_license_agreement=accepted -d confirm=yes";
    };

    nativeBuildInputs = [ dpkg ];
    unpackCmd = "mkdir tmp && dpkg -x $curSrc $_";

    installPhase = ''
      cp -r . $out
    '';

    dontPatchELF = true;
  };

  wrapJlink = name: deps: buildFHSUserEnv rec {
    inherit name;
    runScript = "${jlinkSrc}/opt/SEGGER/JLink_V*/${name}";
    targetPkgs = pkgs: deps;
  };

in

{
  JLinkExe = wrapJlink "JLinkExe" [ udev ];
}
