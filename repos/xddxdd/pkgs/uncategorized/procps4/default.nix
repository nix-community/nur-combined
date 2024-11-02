{
  stdenv,
  sources,
  lib,
  pkg-config,
  ncurses,
}:
stdenv.mkDerivation rec {
  inherit (sources.procps4) pname version src;
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ ncurses ];

  configureFlags = [ "--disable-modern-top" ];

  meta = {
    mainProgram = "ps";
    maintainers = with lib.maintainers; [ xddxdd ];
    homepage = "https://gitlab.com/procps-ng/procps";
    description = "Utilities that give information about processes using the /proc filesystem";
    priority = 11; # less than coreutils, which also provides "kill" and "uptime"
    license = lib.licenses.gpl2Only;
  };
}
