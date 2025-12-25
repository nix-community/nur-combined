{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
}:

stdenv.mkDerivation rec {
  pname = "3gxtool";
  version = "1.3";

  src = fetchFromGitLab {
    owner = "thepixellizeross";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-bT16YtCNqiAtkQ2+1eSDojN+WSHYG3nWlGlsGDYA5Kc=";
    fetchSubmodules = true;
  };

  patches = [ ./dont-force-static.patch ];

  nativeBuildInputs = [ cmake ];

  postPatch = ''
    # goddamn case sensitivity
    substituteInPlace extern/dynalo/include/dynalo/detail/windows/dynalo.hpp \
      --replace-warn Windows.h windows.h
  '';

  # the original installPhase will install the incorrect files
  installPhase = ''
    pwd
    mkdir -p $out/bin
    cp 3gxtool${stdenv.hostPlatform.extensions.executable} $out/bin
  '';

  cmakeFlags = [
    (lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.5")
  ];

  meta = with lib; {
    description = "An utility to generate 3GX plugins.";
    homepage = "https://gitlab.com/thepixellizeross/3gxtool";
    license = licenses.mit;
    # TODO: manually clone dynalo due to mac support in newer commits
    platforms = platforms.linux ++ platforms.windows;
    mainProgram = "3gxtool";
  };
}
