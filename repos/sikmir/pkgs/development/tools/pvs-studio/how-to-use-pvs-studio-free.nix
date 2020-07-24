{ stdenv, cmake, sources }:
let
  pname = "how-to-use-pvs-studio-free";
  date = stdenv.lib.substring 0 10 sources.how-to-use-pvs-studio-free.date;
  version = "unstable-" + date;
in
stdenv.mkDerivation {
  inherit pname version;
  src = sources.how-to-use-pvs-studio-free;

  nativeBuildInputs = [ cmake ];

  postPatch = stdenv.lib.optionalString stdenv.cc.isClang ''
    substituteInPlace CMakeLists.txt \
      --replace "stdc++fs" "c++fs"
  '';

  meta = with stdenv.lib; {
    inherit (sources.how-to-use-pvs-studio-free) description homepage;
    license = licenses.asl20;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
