{ stdenv, curl, file, coreutils, sources }:
let
  pname = "supload";
  date = stdenv.lib.substring 0 10 sources.supload.date;
  version = "unstable-" + date;
in
stdenv.mkDerivation {
  inherit pname version;
  src = sources.supload;

  buildInputs = [ curl file ];

  dontBuild = true;
  dontConfigure = true;

  prePatch = ''
    substituteInPlace supload.sh \
      --replace '`which curl`' '${curl}/bin/curl' \
      --replace '`which file`' '${file}/bin/file' \
      --replace '`which md5sum`' '${coreutils}/bin/md5sum'
  '';

  installPhase = ''
    install -Dm755 supload.sh $out/bin/supload
  '';

  meta = with stdenv.lib; {
    inherit (sources.supload) description homepage;
    license = licenses.gpl3;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
