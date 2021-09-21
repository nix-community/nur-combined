{ stdenv, lib
, meson, ninja, pkgconfig
, boost, gmp, rapidjson, intervalset, loguru, redox, cppzmq, zeromq
, debug ? false
}:

stdenv.mkDerivation rec {
  pname = "batsched";
  version = "master";
  src = builtins.fetchurl "https://framagit.org/api/v4/projects/batsim%2Fbatsched/repository/archive.tar.gz?sha=master";

  unpackPhase = ''
    # extract archive
    tar xf $src

    # as we suppose the archive has been obtained from gitlab on batsim's master branch,
    # the archive should contain a directory named "batsim-master-COMMIT".
    local parsed_commit=$(ls | sed -n -E 's/^${pname}-master-([[:xdigit:]]{40})$/\1/p')
    echo "git commit seems to be $parsed_commit (parsed from extracted archive directory name)"

    # hack meson's default version
    cd ${pname}-master-$parsed_commit
    local version_name="commit $parsed_commit (built by Nix from master branch)"
    echo "overriding meson's version: $version_name"
    sed -iE "s/version: '.*',/version: '$version_name',/" meson.build
  '';

  # Temporary hack. Meson is no longer able to pick up Boost automatically.
  # https://github.com/NixOS/nixpkgs/issues/86131
  BOOST_INCLUDEDIR = "${lib.getDev boost}/include";
  BOOST_LIBRARYDIR = "${lib.getLib boost}/lib";

  nativeBuildInputs = [ meson ninja pkgconfig ];
  buildInputs = [ boost gmp rapidjson intervalset loguru redox cppzmq zeromq ];

  ninjaFlags = [ "-v" ];

  mesonBuildType = if debug then "debug" else "release";
  CXXFLAGS = if debug then "-O0" else "";
  hardeningDisable = if debug then [ "fortify" ] else [];
  dontStrip = debug;

  meta = with lib; {
    description = "Batsim C++ scheduling algorithms.";
    longDescription = "A set of scheduling algorithms for Batsim (and WRENCH).";
    homepage = "https://gitlab.inria.fr/batsim/batsched";
    platforms = platforms.all;
    license = licenses.free;
    broken = false;
  };
}
