{ lib
, stdenv
, fetchFromGitHub
, dash
, instantConf
, slop
, spotify-adblock
, youtube-dl
}:
stdenv.mkDerivation {

  pname = "instantAssist";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "instantOS";
    repo = "instantAssist";
    rev = "a38e6ea26726e35a0b6ffa14defa6bec3d1697c7";
    sha256 = "1hgvky7jcvb1vn1855gd1yr4ai9wzjnpds25znzcg0z2fqlq3pdf";
    name = "instantOS_instantAssist";
  };

  patches = [ ./spotify-git-install.patch ];

  postPatch = ''
    substituteInPlace install.sh \
      --replace "\"/usr/bin" "\"/bin" \
      --replace /usr/share /share \
      --replace path/to/spotify-adblock.so "${spotify-adblock}/lib/spotify-adblock.so"
    substituteInPlace instantassist \
      --replace "/usr/share/instantassist" "$out/share/instantassist"

    for fl in assists/s*.sh; do
    substituteInPlace "$fl" \
      --replace "slop " "${slop}/bin/slop "
    done

    for fl in assists/*.sh; do
    substituteInPlace "$fl" \
      --replace "/usr/share/instantassist" "$out/share/instantassist"
    done

    for fl in assists/*/*.sh; do
    substituteInPlace "$fl" \
      --replace "/usr/share/instantassist" "$out/share/instantassist"
    done

    patchShebangs install.sh
    patchShebangs cache.sh
  '';

  installPhase = ''
    install -Dm 555 instantassist.desktop "$out/share/applications/instantassist.desktop"
    export ASSISTPREFIX="$out"
    ./install.sh
  '';

  propagatedBuildInputs = [
    dash
    instantConf
    slop
    spotify-adblock
    youtube-dl
  ];

  meta = with lib; {
    description = "Handy menu to access lots of features of instantOS";
    license = licenses.gpl2;
    homepage = "https://github.com/instantOS/instantASSIST";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
