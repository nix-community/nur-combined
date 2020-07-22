{ lib, wine, wineBuild, pkgsCross, fetchFromGitHub }:

(wine.overrideAttrs (attrs: rec {
  name = "wine-eac";
  version = "a50880e";

  nativeBuildInputs =
    attrs.nativeBuildInputs
    ++ lib.optional (wineBuild == "wine32" || wineBuild == "wineWow")
      pkgsCross.mingw32.windows.crossThreadsStdenv.cc
    ++ lib.optional (wineBuild == "win64" || wineBuild == "wineWow")
      pkgsCross.mingwW64.windows.crossThreadsStdenv.cc;

  # Fixes "Compiler cannot create executables" building with wineWow
  strictDeps = true;

  # Fixes -Werror=format-security
  hardeningDisable = [ "format" ];

  src = fetchFromGitHub {
    owner = "Guy1524";
    repo = "wine";
    rev = version;
    sha256 = "0ssfqdln1hl89ypsivyyzprjcvw0bxr9ijkzax3h6yd2rkls8rf6";
  };

  meta = with lib; {
    description = "A custom fork of Wine to support games with Easy Anti-Cheat";
    homepage = "https://github.com/Guy1524/wine";
    maintainer = with maintainers; [ metadark ];
  };
})).override {
  inherit wineBuild;
}
