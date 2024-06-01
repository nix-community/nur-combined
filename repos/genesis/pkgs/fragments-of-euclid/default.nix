{ lib
, pkgs
, stdenv
, requireFile
, unzip
, autoPatchelfHook
, makeWrapper
, gtk2
, gdk-pixbuf
, glib
, gobject-introspection
, libX11
, libXrandr
, libXcursor
, mesa
, mesa_glu
, mono
}:

# unity3d

let

  version = "2017-03-03";

in
stdenv.mkDerivation rec {
  pname = "fragments-of-euclid";
  inherit version;

  src = requireFile {
    name = "fragments-of-euclid-linux.zip";
    message = ''
      This nix expression requires that fragments-of-euclid-linux.zip is
      already part of the store. Find the file on ${meta.downloadPage}
      and add it to the nix store with nix-store --add-fixed sha256 <FILE>.
    '';
    sha256 = "23ae44556efd4e73e96cd4fb0eb9511d15263fedcdcc7ed0b07e3469c9cc34e5";
  };

  nativeBuildInputs = [ autoPatchelfHook makeWrapper unzip ];
  buildInputs = [ gtk2 glib gdk-pixbuf gobject-introspection libXcursor libXrandr libX11 mesa mesa_glu mono ];

  #phases = [ "unpackPhase" "installPhase" ];
  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/{bin,Data}
    cp -a ./FragmentsOfEuclid_Data/* $out/Data
    install -Dm755 ./FragmentsOfEuclid.x86_64 $out/bin/${pname}-unwrapped

    makeWrapper $out/bin/${pname}-unwrapped "$out/bin/${pname}" \
          --run "cd $out"
  '';

  meta = with lib; {
    broken = true; # I don't have a sufficient GPU to achieve it.
    description = "exploring and solving puzzle in a mind-bending environment inspired by M.C. Escher";
    homepage = "https://nusan.itch.io/fragments-of-euclid";
    downloadPage = meta.homepage;
    license = licenses.unfree;
    maintainers = with maintainers; [ genesis ];
    platforms = [ "x86_64-linux" ];
  };
}
