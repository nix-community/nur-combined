# N.B.: landlock is a relatively new thing as of 2024/01, and undergoing ABI revisions.
# the ABI is versioned, and the sandboxer will work when run against either a newer or older kernel than it was built from,
# but it will complain (stderr) about an update being available if kernel max ABI != sandbox max ABI.
{ stdenv
, linux
, makeLinuxHeaders
}:
let
  linuxHeaders = makeLinuxHeaders {
    inherit (linux) src version;
  };
in
stdenv.mkDerivation rec {
  pname = "landlock-sandboxer";
  version = linux.version;
  src = linux.src;

  NIX_DEBUG = 6;

  buildInputs = [
    linuxHeaders  # to get the right linux headers!
  ];

  # sourceRoot = "linux-${version}/samples/landlock";
  preBuild = ''
    cd samples/landlock
  '';

  makeFlags = [ "sandboxer" ];
  installPhase = ''
    mkdir -p $out/bin
    install -m755 sandboxer $out/bin
  '';

  passthru = {
    inherit linuxHeaders;
  };

  meta = {
    description = ''
      The goal of Landlock is to enable to restrict ambient rights (e.g. global filesystem access) for a set of processes.
    '';
    homepage = "https://landlock.io";
  };
}

# alternatively, build more in line with kernel's build system.
# takes longer, but may inherit hardening settings and the like.
# linux.overrideAttrs (_: {
#   buildFlags = [ "-C" "../samples/landlock" "sandboxer" ];
#   installPhase = ''
#     mkdir -p $out/bin
#     install -m755 ../samples/landlock/sandboxer $out/bin
#   '';
# })
