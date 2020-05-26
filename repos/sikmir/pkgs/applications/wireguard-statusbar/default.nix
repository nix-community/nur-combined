{ stdenv, fetchurl, undmg }:

stdenv.mkDerivation rec {
  pname = "wireguard-statusbar";
  version = "1.24";

  src = fetchurl {
    url = "https://github.com/aequitas/macos-menubar-wireguard/releases/download/${version}/WireGuardStatusbar-${version}-117.dmg";
    sha256 = "0zwd4wfxilify660vrcnniyxd0mr1df78n46xbij5mx2nyca2pbj";
  };

  preferLocalBuild = true;

  buildInputs = [ undmg ];

  installPhase = ''
    mkdir -p "$out/Applications/WireGuardStatusbar.app"
    cp -R . "$out/Applications/WireGuardStatusbar.app"
  '';

  meta = with stdenv.lib; {
    description = "macOS menubar icon for WireGuard/wg-quick";
    homepage = "https://github.com/aequitas/macos-menubar-wireguard";
    license = licenses.gpl3;
    maintainers = with maintainers; [ sikmir ];
    platforms = [ "x86_64-darwin" ];
    skip.ci = true;
  };
}
