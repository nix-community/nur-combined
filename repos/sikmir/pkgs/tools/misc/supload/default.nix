{ stdenv, curl, file, coreutils, sources }:

stdenv.mkDerivation {
  pname = "supload-unstable";
  version = stdenv.lib.substring 0 10 sources.supload.date;

  src = sources.supload;

  buildInputs = [ curl file ];


  prePatch = ''
    substituteInPlace supload.sh \
      --replace '`which curl`' '${curl}/bin/curl' \
      --replace '`which file`' '${file}/bin/file' \
      --replace '`which md5sum`' '${coreutils}/bin/md5sum'
  '';

  installPhase = "install -Dm755 supload.sh $out/bin/supload";

  meta = with stdenv.lib; {
    inherit (sources.supload) description homepage;
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
