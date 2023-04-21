{ stdenv, lib, fetchFromGitHub, cmake, simgrid, cppzmq, python3, zeromq
, debug ? false
, optimize ? (!debug)
}:

with lib;

let
  optionOnOff = option: if option then "on" else "off";
in

stdenv.mkDerivation rec {
  pname = "elastisim";
  version = "1e967c";

  src = fetchFromGitHub {
    owner  = "elastisim";
    repo   = "elastisim";
    rev    = "1e967ce8e965fedce08da0e0edffe9f99161ca0a";
    sha256 = "sha256-yMScmVE6FAE5PWUAKZkbGAuCXZ6OCZsbjlKzvOnIcjQ=";
  };

  propagatedBuildInputs = [ ];
  nativeBuildInputs = [ cmake python3 simgrid cppzmq zeromq ];

  # "Release" does not work. non-debug mode is Debug compiled with optimization
  cmakeBuildType = "Debug";
  cmakeFlags = [
  ];
  makeFlags = optional debug "VERBOSE=1";

  installPhase = ''
    mkdir -p $out/bin
    cp elastisim $out/bin
  '';

  dontStrip = debug;

  meta = {
    description = "Batch-system simulation for elastic workloads";
    longDescription = ''
    '';
    homepage = "https://github.com/elastisim/elastisim";
    license = licenses.bsd3;
    maintainers = [];
    platforms = platforms.all;
    broken = false;
  };
}
