{ stdenv, fetchFromGitHub, libxml2, udev }:

stdenv.mkDerivation rec {
  pname = "qdl";
  version = "unstable-2019-04-30";

  src = fetchFromGitHub {
    owner = "andersson";
    repo = pname;
    rev = "760b3dffb03d2b7dfb82c6eac652a092f51c572d";
    sha256 = "1kdvv51bb9lcg4in3n6valm67pmvfap4jc1m66hzhw4rg7g295na";
  };

  buildInputs = [ libxml2 udev ];

  prePatch = ''
    # set prefixes
    substituteInPlace Makefile \
    --replace 'install -D -m 755 $< $(DESTDIR)$(prefix)/bin/$<' "install -D -m 755 $< $out/bin/$<" \
  '';

  meta = with stdenv.lib; {
    description = "A flasher for Qualcomm's Emergency Download (EDL) mode";
    homepage = "https://github.com/andersson/qdl/";
    license = licenses.bsd3;
    maintainers = with maintainers; [ joshuafern ];
    platforms = platforms.unix;
  };
}
