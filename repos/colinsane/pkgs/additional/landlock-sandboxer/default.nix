# N.B.: landlock is a relatively new thing as of 2024/01, and undergoing ABI revisions.
# the ABI is versioned, and the sandboxer will work when run against either a newer or older kernel than it was built from,
# but it will complain (stderr) about an update being available if kernel max ABI != sandbox max ABI.
{
  config ? {},
  linux,
  makeLinuxHeaders,
  stdenv,
}:
let

  # not strictly necessary to match linux versions (landlock ABI is versioned),
  # however when sandboxer version != kernel version,
  # the sandboxer may nag about one or the other wanting to be updated.
  linux' = ((config.boot or {}).kernelPackages or {}).kernel or linux;
  linuxHeaders = makeLinuxHeaders {
    inherit (linux') src version;
  };
in
stdenv.mkDerivation rec {
  pname = "landlock-sandboxer";
  version = linux'.version;
  src = linux'.src;

  buildInputs = [
    linuxHeaders  # to get the right linux headers!
  ];

  # starting in 6.9, the sandboxer prints diagnostics on startup,
  # which is annoying, and also risks breaking some users
  postPatch = ''
    substituteInPlace samples/landlock/sandboxer.c \
      --replace 'fprintf(stderr, "Executing the sandboxed command...\n");' ""
  '';

  # sourceRoot = "linux-${version}/samples/landlock";
  preBuild = ''
    cd samples/landlock
  '';

  makeFlags = [ "sandboxer" ];
  installPhase = ''
    mkdir -p $out/bin
    install -m755 sandboxer $out/bin/landlock-sandboxer
  '';

  passthru = {
    inherit linuxHeaders;
    linux = linux';
  };

  meta = {
    description = ''
      The goal of Landlock is to enable to restrict ambient rights (e.g. global filesystem access) for a set of processes.
    '';
    homepage = "https://landlock.io";
    mainProgram = "landlock-sandboxer";
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
