{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
  gdb,
}:

stdenvNoCC.mkDerivation rec {
  name = "gdb-prompt";
  src = fetchFromGitHub {
    owner = "Freed-Wu";
    repo = name;
    rev = "b837d39b40c5f9cf4bacff547d2c9e35ddfcc80e";
    hash = "sha256-ojqOXtCkhjko6tBaGAPB4XTIyFaVYFljCUJSdmLfkSY=";
  };

  dontConfigure = true;
  dontBuild = true;

  buildInputs = [ gdb ];
  installPhase = ''
    install -D gdb-prompt -t $out/bin
    install -Dm644 gdb-hook.py -t $out/share/gdb
  '';

  meta = with lib; {
    homepage = "https://github.com/Freed-Wu/gdb-prompt";
    description = "GDB plugin for powerlevel10k style prompt";
    license = licenses.gpl3;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
}
