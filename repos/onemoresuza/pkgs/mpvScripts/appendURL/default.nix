{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  xclip,
}:
stdenvNoCC.mkDerivation rec {
  pname = "appendURL";
  version = "unstable-20230506";

  src = fetchFromGitHub {
    owner = "jonniek";
    repo = "mpv-scripts";
    rev = "8fc6ea015f7a2e5fead0b963549c48e63f89387f";
    sha256 = "sha256-AICic+q3hvQODY0PGaLNJdLg/EVkYyIibbWyBwDDWjY=";
  };

  dontBuild = true;

  postPatch = ''
    substituteInPlace ${pname}.lua \
        --replace "'xclip'" "'${xclip}/bin/xclip'" \
        --replace "local platform = nil" "local platform = 'linux'"
  '';

  installPhase = ''
    mkdir -p $out/share/mpv/scripts
    cp ${pname}.lua $out/share/mpv/scripts/
  '';

  passthru.scriptName = "${pname}.lua";

  meta = with lib; {
    description = "Appends url from clipboard to the playlist";
    homepage = "https://github.com/jonniek/mpv-scripts/";
    license = licenses.isc;
    #
    # Since pbpaste is not packaged, no Darwin.
    #
    platforms = platforms.linux;
  };
}
