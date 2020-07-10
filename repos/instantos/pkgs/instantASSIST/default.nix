{ lib
, stdenv
, fetchFromGitHub
, fetchurl
, Paperbash
, spotify-adblock
}:
stdenv.mkDerivation rec {

  pname = "instantASSIST";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "instantOS";
    repo = "instantASSIST";
    rev = "bfab219afae675db309d4e7a035a75abd5e103ea";
    sha256 = "0syd4nm3msia2xlgxycwwmlml92r32fvmknqhaq1i0sscphbb55a";
  };

  patches = [ ./spotify-git-install.patch ];

  postPatch = ''
    substituteInPlace install.sh \
      --replace /usr/bin /bin \
      --replace /usr/share/paperbash "${Paperbash}/share/paperbash" \
      --replace path/to/spotify-adblock.so "${spotify-adblock}/lib/spotify-adblock.so"
    substituteInPlace dm/b.sh \
      --replace /usr/bin/dash /bin/sh
    substituteInPlace dm/p.sh \
      --replace /usr/bin/dash /bin/sh
    substituteInPlace instantassist \
      --replace "/usr/bin/env dash" /bin/sh \
      --replace "/opt/instantos/menus" "$out/opt/instantos/menus"
    substituteInPlace instantdoc \
      --replace "/usr/bin/env dash" /bin/sh \
      --replace "/opt/instantos/menus" "$out/opt/instantos/menus"

    substituteInPlace dm/rm.sh \
      --replace /opt/instantos/menus "$out/opt/instantos/menus"
    substituteInPlace dm/f.sh \
      --replace /opt/instantos/menus "$out/opt/instantos/menus"
    substituteInPlace dm/k.sh \
      --replace /opt/instantos/menus "$out/opt/instantos/menus"
    substituteInPlace dm/b.sh \
      --replace /opt/instantos/menus "$out/opt/instantos/menus"
    substituteInPlace dm/tb.sh \
      --replace /opt/instantos/menus "$out/opt/instantos/menus"
    substituteInPlace dm/p.sh \
      --replace /opt/instantos/menus "$out/opt/instantos/menus"
    substituteInPlace dm/tw.sh \
      --replace /opt/instantos/menus "$out/opt/instantos/menus"
    substituteInPlace dm/m.sh \
      --replace /opt/instantos/menus "$out/opt/instantos/menus" \
      --replace /opt/instantos/spotify-adblock.so "${spotify-adblock}/lib/spotify-adblock.so"

    patchShebangs install.sh
  '';

  installPhase = ''
    install -Dm 555 instantassist.desktop "$out/share/applications/instantassist.desktop"
    export ASSISTPREFIX="$out"
    ./install.sh
  '';

  propagatedBuildInputs = [ Paperbash spotify-adblock ];

  meta = with lib; {
    description = "instantOS Utils";
    license = licenses.mit;
    homepage = "https://github.com/instantOS/instantASSIST";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
