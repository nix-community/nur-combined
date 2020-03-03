{ stdenv, fetchFromGitHub, libxml2, udev }:

stdenv.mkDerivation rec {
  version = "760b3dffb03d2b7dfb82c6eac652a092f51c572d";
  pname = "qdl";

  src = fetchFromGitHub {
    owner = "andersson";
    repo = pname;
    rev = version;
    sha256 = "1kdvv51bb9lcg4in3n6valm67pmvfap4jc1m66hzhw4rg7g295na";
  };

  buildInputs = [libxml2 udev];

  prePatch = ''
    # set prefixes
    substituteInPlace Makefile \
    --replace 'install -D -m 755 $< $(DESTDIR)$(prefix)/bin/$<' "install -D -m 755 $< $out/bin/$<" \
  '';

  meta = with stdenv.lib; {
    description = "Qualcomm Download";
    homepage = "https://github.com/andersson/qdl/";
    license = licenses.bsd3;
    longDescription = ''
    This tool communicates with USB devices of id 05c6:9008 to upload a flash loader and use this to flash images.
    '';
    #maintainers = with maintainers; [  ];
    platforms = platforms.unix;
  };
}
