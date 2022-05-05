{ lib, stdenv, fetchFromGitHub, python3, xorg, makeWrapper, help2man }:

stdenv.mkDerivation rec {
  pname = "disper";
  version = "0.3.1.1";

  src = fetchFromGitHub {
    owner = "apeyser";
    repo = pname;
    rev = "${pname}-${version}";
    sha256 = "1kl4py26n95q0690npy5mc95cv1cyfvh6kxn8rvk62gb8scwg9zn";
  };

  nativeBuildInputs = [ makeWrapper python3 help2man ];
  propagatedBuildInputs = [ python3 ];

  strictDeps = true;

  preConfigure = ''
    export makeFlags="PREFIX=$out"
  '';

  postInstall = let
    lib_path = with xorg; lib.makeLibraryPath [ xorg.libXrandr xorg.libX11 ];
  in ''
    2to3 -wn "$out/share/disper/src"
    substituteInPlace "$out/bin/disper" \
      --replace 'except Exception,e:' 'except e:'
    wrapProgram $out/bin/disper \
      --prefix "LD_LIBRARY_PATH" : "${lib_path}"
  '';

  meta = with lib; {
    description = "On-the-fly display switch utility";
    license = licenses.gpl3;
    homepage = "https://willem.engen.nl/projects/disper/";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.unix;
  };
}
