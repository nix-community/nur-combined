{
  mySources,
  lib,
  stdenvNoCC,
  cmake,
}:
stdenvNoCC.mkDerivation {
  inherit (mySources.manpager) pname version src;

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    homepage = "https://github.com/Freed-Wu/manpager";
    description = "Colorize `man XXX`";
    license = licenses.gpl3;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
}
