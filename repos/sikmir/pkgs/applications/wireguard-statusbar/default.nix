{ lib, stdenv, fetchfromgh, undmg }:

stdenv.mkDerivation rec {
  pname = "wireguard-statusbar-bin";
  version = "1.24";

  src = fetchfromgh {
    owner = "aequitas";
    repo = "macos-menubar-wireguard";
    name = "WireGuardStatusbar-${version}-117.dmg";
    sha256 = "0zwd4wfxilify660vrcnniyxd0mr1df78n46xbij5mx2nyca2pbj";
    inherit version;
  };

  preferLocalBuild = true;

  nativeBuildInputs = [ undmg ];

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/Applications
    cp -r *.app $out/Applications
  '';

  meta = with lib; {
    description = "macOS menubar icon for WireGuard/wg-quick";
    inherit (src.meta) homepage;
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = [ "x86_64-darwin" ];
    skip.ci = true;
  };
}
