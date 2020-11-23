{ stdenv, fetchfromgh, undmg }:

stdenv.mkDerivation rec {
  pname = "wireguard-statusbar";
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

  sourceRoot = "WireGuardStatusbar.app";

  installPhase = ''
    mkdir -p $out/Applications/WireGuardStatusbar.app
    cp -R . $out/Applications/WireGuardStatusbar.app
  '';

  meta = with stdenv.lib; {
    description = "macOS menubar icon for WireGuard/wg-quick";
    homepage = "https://github.com/aequitas/macos-menubar-wireguard";
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = [ "x86_64-darwin" ];
    skip.ci = true;
  };
}
