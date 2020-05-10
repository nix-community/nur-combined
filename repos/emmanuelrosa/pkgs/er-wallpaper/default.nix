{ mkDerivation, fetchFromGitHub, base, stdenv, turtle, pywal, betterlockscreen }:
mkDerivation rec {
  pname = "er-wallpaper";
  version = "0.1.0.0";

  src = fetchFromGitHub {
    owner = "emmanuelrosa";
    repo = pname;
    rev = "d7b6a907bf009da1ecb379877f523c40a33d2e8d";
    sha256 = "0nypg1b8xhxar059bbnw1ii57jvm8my4rlpjaw55mysvyrjsn44x";
  };

  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [ base turtle ];
  homepage = "https://github.com/emmanuelrosa/er-wallpaper";
  description = "A script for changing wallpaper and setting color schemes, for Linux";
  license = stdenv.lib.licenses.mit;

  postConfigure = ''
    substituteInPlace Main.hs \
      --replace _ER_PATH_WAL_ \""${pywal}/bin/wal"\" \
      --replace _ER_PATH_BETTERLOCKSCREEN_ \""${betterlockscreen}/bin/betterlockscreen"\"
  '';
}
