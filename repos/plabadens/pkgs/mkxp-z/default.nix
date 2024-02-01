{
  stdenv, lib, fetchFromGitHub,
  cmake, pkg-config,
  ruby,
}:

stdenv.mkDerivation rec {
  pname = "mkxp-z";
  version = "2023-08-23";

  src = fetchFromGitHub {
    owner = "mkxp-z";
    repo = "mkxp-z";
    rev = "4c0620ce4ecdd233c2a48f696ae202a8ab8a8f9c";
    sha256 = "sha256-xO4iJqWUU9am7/fEiw4HCflRgsEIUXejPdX9HRJL0ws=";
  };

  buildInputs = [ ruby  ];

  nativeBuildInputs = [ pkg-config ];

  postPatch = ''
    substituteInPlace FastQSP.pro gui/gui.pro qsp/qsp.pro \
      --replace "/O2 /GL" "-O2"
    substituteInPlace qsp/qsp.pro \
      --replace 'DESTDIR = $$BUILDDIR/bin' "DESTDIR = $out/lib"
    substituteInPlace gui/gui.pro \
      --replace 'DESTDIR = $$BUILDDIR/bin' "DESTDIR = $out/bin" \
      --replace 'LIBS += -L$$DESTDIR -lqsp -lonig' "LIBS += -L$out/lib -lqsp -lonig"
  '';

  meta = with lib; {
    description = "Graphs the disk IO in a linux terminal";
    homepage = "https://github.com/stolk/diskgraph";
    license = licenses.mit;
    maintainers = with maintainers; [ plabadens ];
  };
}
