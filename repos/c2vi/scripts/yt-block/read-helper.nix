{stdenv
, ...
}: let
in stdenv.mkDerivation {
  name = "read-helper";

  src = ./.;

  # Use $CC as it allows for stdenv to reference the correct C compiler
  # i cant get this to not trigger buffer oferflow protection on the read() call with the pid
  # so let mod the kernel module, to be able to 'echo $pid > /dev/unkillable'
  buildPhase = ''
    gcc -fno-stack-protector -D_FORTIFY_SOURCE=0 read-helper.c -o read-helper
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp read-helper $out/bin
  '';
}
