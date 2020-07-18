{ lib
, stdenv
, fetchFromGitHub
, Paperbash
, spotify-adblock
}:
stdenv.mkDerivation {

  pname = "instantAssist";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "instantOS";
    repo = "instantAssist";
    rev = "99f9700a1439e9c5d9311811390d167fd1616c09";
    sha256 = "0nfgq2s2114r8mcsz2x248fz4yzpyxr6k1qycwbzai8nw0rcd0w9";
    name = "instantOS_instantAssist";
  };

  patches = [ ./spotify-git-install.patch ];

  postPatch = ''
    substituteInPlace install.sh \
      --replace /usr/bin /bin \
      --replace /usr/share/paperbash "${Paperbash}/share/paperbash" \
      --replace path/to/spotify-adblock.so "${spotify-adblock}/lib/spotify-adblock.so"
    substituteInPlace dm/b.sh \
      --replace /usr/bin/dash /bin/sh \
      --replace /opt/instantos/menus "$out/opt/instantos/menus"
    substituteInPlace dm/p.sh \
      --replace /usr/bin/dash /bin/sh \
      --replace /opt/instantos/menus "$out/opt/instantos/menus"
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
    description = "Handy menu to access lots of features of instantOS";
    license = licenses.mit;
    homepage = "https://github.com/instantOS/instantASSIST";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
