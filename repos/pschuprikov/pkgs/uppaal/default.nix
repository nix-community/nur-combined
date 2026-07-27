{ lib, stdenv, fetchurl, unzip, autoPatchelfHook }:
stdenv.mkDerivation rec {
  pname = "uppaal";
  version = "4.1.26-2";
  name = "${pname}-${version}";
  src = builtins.path {
    path = builtins.getEnv "PWD" + "/pkgs/uppaal/${pname}64-${version}.zip";
    recursive = false;
    sha256 = "sha256-B8INwTU8UcswCduEXHwGpx3qcdgNkxpjoztip4Zisck=";
  };

  dontBuild = true;

  installPhase = ''
    install -d $out/lib/uppaal
    cp -r * $out/lib/uppaal
  '';

  postFixup = ''
    autoPatchelf $out/lib/bin-Linux
  '';

  buildInputs = [ autoPatchelfHook ];
  nativeBuildInputs = [ unzip ];

  meta = with lib; {
    license = licenses.unfree;
  };
}
