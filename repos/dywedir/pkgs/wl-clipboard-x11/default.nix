{ stdenv, fetchFromGitHub, makeWrapper, bash, wl-clipboard }:

stdenv.mkDerivation rec {
  pname = "wl-clipboard-x11";
  version = "3";

  src = fetchFromGitHub {
    owner = "brunelli";
    repo = pname;
    rev = "v${version}";
    sha256 = "0map1kqygjdavcbvsgjlnhqy7rmly7cfn6i9cf881h59rp846453";
  };

  pathAdd = stdenv.lib.makeSearchPath "bin" [ wl-clipboard ];

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ bash ];
  dontBuild = true;

  makeFlags = [ "PREFIX=$(out)" ];

  postInstall = ''
    wrapProgram "$out/share/wl-clipboard-x11/wl-clipboard-x11" --prefix PATH : $pathAdd
  '';

  meta = with stdenv.lib; {
    description = "A wrapper to use wl-clipboard as a drop-in replacement to X11 clipboard tools";
    longDescription = ''
      wl-clipboard-x11 is a very simple script that allows using wl-clipboard in lieu of X11
      clipboard tools (xclip and xsel).

      It  tries  to translate positional arguments to equivalent ones in wl-clipboard, using
      argv[0] (calling command) to determine if it's emulating xclip or xsel
    '';
    homepage = https://github.com/brunelli/wl-clipboard-x11;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ dywedir ];
    platforms = platforms.linux;
  };
}
