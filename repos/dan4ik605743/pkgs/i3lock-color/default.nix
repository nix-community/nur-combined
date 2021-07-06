{ stdenv, lib, fetchFromGitHub, autoreconfHook, pkgconfig, libxcb,
  xcbutilkeysyms , xcbutilimage, pam, libX11, libev, cairo, libxkbcommon,
  libxkbfile, libjpeg_turbo, xcbutilxrm
}:

stdenv.mkDerivation rec {
  version = "2.12.c.5";
  pname = "i3lock-color";

  src = fetchFromGitHub {
    owner = "PandorasFox";
    repo = "i3lock-color";
    rev = version;
    sha256 = "10h50a6p9ivqjz8hd5pn9l03vz6y9dxdx68bprqssfzdkzqnzaiv";
  };

  patches = [ ./patches/numlock-fix.patch ./patches/white-screen-fix.patch ];

  nativeBuildInputs = [ autoreconfHook pkgconfig ];

  buildInputs = [ libxcb xcbutilkeysyms xcbutilimage pam libX11
    libev cairo libxkbcommon libxkbfile libjpeg_turbo xcbutilxrm ];

  makeFlags = [ "all" ];

  preInstall = ''
    mkdir -p $out/share/man/man1
  '';

  installFlags = [ "PREFIX=\${out}" "SYSCONFDIR=\${out}/etc" "MANDIR=\${out}/share/man" ];

  postInstall = ''
    mv $out/bin/i3lock $out/bin/i3lock-color
    mv $out/share/man/man1/i3lock.1 $out/share/man/man1/i3lock-color.1
    sed -i 's/\(^\|\s\|"\)i3lock\(\s\|$\)/\1i3lock-color\2/g' $out/share/man/man1/i3lock-color.1
  '';

  meta = with lib; {
    description = "A simple screen locker like slock, enhanced version with extra configuration options (With patches)";
    homepage = "https://github.com/PandorasFox/i3lock-color";
    license = licenses.bsd3;
    maintainers = with maintainers; [ dan4ik605743 ];
    platforms = platforms.x86;
  };
}
