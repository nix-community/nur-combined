{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, gzip
, zlib
}:

stdenv.mkDerivation rec {
  pname = "codeium";
  version = "1.1.62";

  src = fetchurl {
    url = "https://github.com/Exafunction/codeium/releases/download/language-server-v${version}/language_server_linux_x64.gz";
    hash = "sha256-MDGA65qWx1YIDGIj2stn30+qki88DUMkIQtuQnM8XBk=";
  };

  meta = with lib; {
    description = "Language model code completion";
    homepage = "https://codeium.com/";
    license = licenses.unfree;
    maintainers = with maintainers; [ dschrempf ];
    platforms = platforms.linux;
  };

  nativeBuildInputs = [ autoPatchelfHook gzip zlib ];

  sourceRoot = ".";

  unpackPhase = ''
    cp ${src} ./codeium-v${version}.gz
    ${gzip}/bin/gunzip codeium-v${version}.gz
  '';

  installPhase = ''
    install -m755 -D codeium-v${version} $out/bin/codeium
  '';
}
