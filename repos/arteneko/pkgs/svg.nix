{
  fetchFromSourcehut,
  stdenv,
  lib,

  meson,
  ninja,

  SDL2,
}:
let
  name = "svg";
  ref = "714c8e8";
  version = "dev-${ref}";
  hash = "sha256-HmNd/zQj/EsOOvZ9gcf23D8QdcpFjDQEamR+PXCPCRk=";
in stdenv.mkDerivation {
  pname = name;
  version = version;
  name = "${name}-${version}";

  src = fetchFromSourcehut {
    owner = "~artemis";
    repo = name;
    rev = ref;
    sha256 = hash;
  };

  nativeBuildInputs = [ ninja meson ];
  buildInputs = [ SDL2 ];

  configurePhase = ''
  meson build
  '';

  buildPhase = ''
  meson compile -C build
  '';

  installPhase = ''
  install -Dm755 build/svg $out/bin/svg
  '';

  meta = with lib; {
    description = "a small svg viewer for SVG file creation, with auto-reload";
    homepage = "https://git.sr.ht/~artemis/svg";
    license = "CNPLv6";
    platforms = platforms.all;
  };
}
