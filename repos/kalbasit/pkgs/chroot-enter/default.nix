{ stdenv }:

stdenv.mkDerivation rec {
  name = "chroot-enter-${version}";
  version = "0.0.1";

  src = ./.;

  installPhase = ''
    install -Dm755 $src/chroot-enter.sh $out/bin/chroot-enter
    install -Dm755 $src/os-enter.sh $out/bin/os-enter
  '';
}
