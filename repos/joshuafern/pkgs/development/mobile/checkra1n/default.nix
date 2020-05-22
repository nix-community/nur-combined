{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "checkra1n";
  version = "0.10.1";

  src = fetchurl {
    url = "https://assets.checkra.in/downloads/linux/cli/x86_64/b0edbb87a5e084caf35795dcb3b088146ad5457235940f83e007f59ca57b319c/checkra1n-x86_64";
    sha256 = "171igfjrrx87w21hz51mf92xashli2qb7p4mazrwm170ln3vpvdh";
  };

  dontUnpack = true;

  installPhase = ''
    install -dm755 "$out/bin"
    install -m755 $src $out/bin/${pname}
  '';

  meta = with stdenv.lib; {
    description = "Jailbreak for iPhone 5s though iPhone X, iOS 12.3 and up";
    homepage = "https://checkra.in/";
    license = licenses.unfreeRedistributable;
    maintainers = with maintainers; [ joshuafern ];
    platforms = platforms.linux;
  };
}
