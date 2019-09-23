{ stdenv, fetchFromGitHub, asciidoc, libxml2, libxslt, docbook_xml_dtd_45, docbook_xsl, libcap }:

stdenv.mkDerivation rec {
  pname = "isolate";
  version = "1.8.1";

  src = fetchFromGitHub {
    owner = "ioi";
    repo = pname;
    rev = "refs/tags/v${version}";
    sha256 = "1396wp6g9j3hp4p6gh4l51cz2qh1a43f4f159md57bp01mj2k5db";
  };

  nativeBuildInputs = [ asciidoc libxml2 libxslt docbook_xml_dtd_45 docbook_xsl ];
  buildInputs = [ libcap ];

  postPatch = ''
    # 1) Respect PREFIX if user sets it (as we do, below)
    # 2) Don't attempt to create /var during install
    # 3) Don't attempt to set SUID bit on installed binary
    substituteInPlace Makefile \
      --replace "PREFIX =" "PREFIX ?=" \
      --replace 'install -d $(BINDIR) $(BOXDIR) $(CONFIGDIR)' \
                'install -d $(BINDIR) $(CONFIGDIR)' \
      --replace 'install -m 4755' 'install -m 755'
  '';

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  installTargets = [ "install" "install-doc" ];

  meta = with stdenv.lib; {
    description = "Sandbox for securely executing untrusted programs";
    homepage = "https://github.com/ioi/isolate";
    license = licenses.gpl2Plus;
    longDescription = ''
      Isolate is a sandbox built to safely run untrusted executables,
      offering them a limited-access environment and preventing them from
      affecting the host system. It takes advantage of features specific to
      the Linux kernel, like namespaces and control groups.
    '';
    maintainers = with maintainers; [ dtzWill ];
  };
}
