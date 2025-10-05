{
  lib,
  stdenv,
  fetchFromGitHub,
  gfortran,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rtklib";
  version = "2.4.3-b34";

  src = fetchFromGitHub {
    owner = "tomojitakasu";
    repo = "rtklib";
    tag = "v${finalAttrs.version}";
    hash = "sha256-d9hpvmIdSZ3BervVZVvfRTc+q7wUWoWLF81TAsMGe68=";
  };

  nativeBuildInputs = [ gfortran ];

  buildPhase = ''
    make -C lib/iers/gcc
    make -C app/consapp
  '';

  installPhase = ''
    install -Dm755 app/consapp/pos2kml/gcc/pos2kml -t $out/bin
    install -Dm755 app/consapp/str2str/gcc/str2str -t $out/bin
    install -Dm755 app/consapp/rnx2rtkp/gcc/rnx2rtkp -t $out/bin
    install -Dm755 app/consapp/rtkrcv/gcc/rtkrcv -t $out/bin
    install -Dm755 app/consapp/convbin/gcc/convbin -t $out/bin

    install -Dm644 app/consapp/rnx2rtkp/gcc/*.conf -t $out/share/rtklib/rnx2rtkp
  '';

  meta = {
    description = "An Open Source Program Package for GNSS Positioning";
    homepage = "http://www.rtklib.com/";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
