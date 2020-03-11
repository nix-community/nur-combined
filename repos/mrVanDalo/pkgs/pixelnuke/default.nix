{ stdenv, fetchgit, libevent, glew, glfw, ... }:

stdenv.mkDerivation rec {
  version = "2019-05-19";
  name = "pixelnuke-${version}";

  src = fetchgit {
    url = "https://github.com/defnull/pixelflut.git";
    rev = "3458157a242ba1789de7ce308480f4e1cbacc916";
    sha256 = "03dp0p00chy00njl4w02ahxqiwqpjsrvwg8j4yi4dgckkc3gbh40";
  };

  buildInputs = [ libevent glew glfw ];
  buildPhase = ''
    cd pixelnuke
    make
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp ./pixelnuke $out/bin/
  '';

  meta = with stdenv.lib; {
    description = "Multiplayer canvas";
    homepage = "https://cccgoe.de/wiki/Pixelflut";
    license = licenses.unlicense;
    platforms = platforms.linux;
    maintainers = with maintainers; [ mrVanDalo ];
  };
}
