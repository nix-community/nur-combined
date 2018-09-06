{ stdenv, glib, libglvnd, xlibs, fontconfig, dbus, fetchzip, autoPatchelfHook }: 

stdenv.mkDerivation {
  name = "binary-ninja";

  src = fetchzip {
    url = "https://cdn.binary.ninja/installers/BinaryNinja-demo.zip";
    sha256 = "1yq3as1mw681zh1if2nkxc7677lwqca82vhacb267hh8j91svjf4";
  };

  installPhase = ''
    mkdir -p $out/share/binary-ninja
    cp -r * $out/share/binary-ninja
  '';

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [
    stdenv.cc.cc glib fontconfig dbus libglvnd
    xlibs.libX11 xlibs.libXi xlibs.libXrender
  ];
}
