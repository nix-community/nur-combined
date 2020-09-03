{ stdenv, fetchgit, fetchurl, lang ? "en-US" }:
let
  version = "80.0.1";

  firefox = fetchurl {
    url = "https://download-installer.cdn.mozilla.net/pub/firefox/releases/${version}/mac/${lang}/Firefox%20${version}.dmg";
    sha256 = "1l3gkkmxbgzjn72ncvbpk2br2j08sgvzrmlgcvv0hdn9rwnbnb18";
    name = "Firefox.dmg";
  };
in
stdenv.mkDerivation {
  pname = "librewolf";
  inherit version;

  src = fetchgit {
    url = "https://gitlab.com/librewolf-community/browser/macos";
    rev = "3fcf44663ff1fb4e180fb3cdb26620abe7284b53";
    sha256 = "0p517ixkgp3sl7b26mdjr9mwv6155xx8ah85fgpwqnpryr64xs3d";
  };

  postPatch = ''
    substituteInPlace package.sh \
      --replace "codesign" "/usr/bin/codesign" \
      --replace "cp" "/bin/cp" \
      --replace "hdiutil" "/usr/bin/hdiutil" \
      --replace "out_dir=" "out_dir=. #"
  '';

  buildPhase = ''
    # Use fresh FF dmgs for each build.
    cp ${firefox} Firefox.dmg
    ./package.sh Firefox.dmg
  '';

  installPhase = ''
    /usr/bin/hdiutil mount -nobrowse -mountpoint librewolf-mnt LibreWolf.dmg
    mkdir -p $out/Applications
    cp -r ./librewolf-mnt/LibreWolf.app $out/Applications
    /usr/bin/hdiutil unmount librewolf-mnt
  '';

  meta = with stdenv.lib; {
    description = "A fork of Firefox, focused on privacy, security and freedom";
    homepage = "https://librewolf-community.gitlab.io/";
    license = licenses.mpl20;
    maintainers = [ maintainers.sikmir ];
    platforms = [ "x86_64-darwin" ];
    skip.ci = true;
  };
}
