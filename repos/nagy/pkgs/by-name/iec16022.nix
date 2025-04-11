{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  popt,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "iec16022";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "rdoeffinger";
    repo = "iec16022";
    rev = "v${finalAttrs.version}";
    hash = "sha256-3JqHouk8RMliewtCKnpqbceIsCE+43MKQPmxha9XwEc=";
  };

  nativeBuildInputs = [ autoreconfHook ];

  buildInputs = [ popt ];

  meta = {
    description = "DataMatrix 2D barcode generator";
    homepage = "https://github.com/rdoeffinger/iec16022";
    changelog = "https://github.com/rdoeffinger/iec16022/blob/v${finalAttrs.version}/ChangeLog";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "iec16022";
    platforms = lib.platforms.all;
  };
})
