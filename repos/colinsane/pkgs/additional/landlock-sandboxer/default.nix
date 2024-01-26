# N.B.: landlock is a relatively new thing as of 2024/01;
# `pkgs.linux` is kinda old.
# may want to use `linux_latest`, here and everywhere, if you find landlock to be lacking.
{ stdenv
, linux
}:
stdenv.mkDerivation rec {
  pname = "landlock-sandboxer";
  version = linux.version;
  src = linux.src;

  sourceRoot = "linux-${version}/samples/landlock";
  makeFlags = [ "sandboxer" ];
  installPhase = ''
    mkdir -p $out/bin
    install -m755 sandboxer $out/bin
  '';

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
