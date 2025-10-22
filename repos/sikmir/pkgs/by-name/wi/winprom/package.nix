{
  lib,
  stdenv,
  fetchFromGitHub,
  wineWow64Packages,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "winprom";
  version = "2.3";

  src = fetchFromGitHub {
    owner = "edwardearl";
    repo = "winprom";
    rev = "621e1422333a9b4e84cd2f507a412e8bb0e68c46";
    hash = "sha256-yWjKOjUpvMtwN/0iOvM3to2Q6lnD+Wb8L1vLVDoH6U8=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase = ''
    mkdir -p $out/opt/winprom
    cp -r *.exe $out/opt/winprom

    makeWrapper ${wineWow64Packages.stable}/bin/wine $out/bin/winprom \
      --add-flags "$out/opt/winprom/winprom.exe"
    makeWrapper ${wineWow64Packages.stable}/bin/wine $out/bin/winelev \
      --add-flags "$out/opt/winprom/winelev.exe"
  '';

  meta = {
    description = "Windows tool for calculating the topographic prominence of mountains";
    homepage = "https://github.com/edwardearl/winprom";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    inherit (wineWow64Packages.stable.meta) platforms;
    skip.ci = true;
  };
})
