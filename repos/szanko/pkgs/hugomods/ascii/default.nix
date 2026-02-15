{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hugomods-ascii";
  version = "unstable-2026-02-03";

  src = fetchFromGitHub {
    owner = "hugomods";
    repo = "ascii";
    rev = "76cd04d6ac3cc5b70b7fc7027bc903776ec32e99";
    hash = "sha256-pzeK+H7yymTVlRl38N14j1KyskVkeF75F8+w7ssOxfA=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/hugomods/ascii
    cp -r . $out/share/hugomods/ascii

    runHook postInstall
  '';

  meta = {
    description = "Hugo ASCII Module";
    homepage = "https://github.com/hugomods/ascii.git";
    changelog = "https://github.com/hugomods/ascii/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers =
      let m = lib.maintainers or {};
      in lib.optionals (m ? szanko) [ m.szanko ];
    platforms = lib.platforms.all;
  };
})
