{ stdenv, lib, makeWrapper, autoPatchelfHook, unzip,
  writeScriptBin, fetchurl, glibc, xorg, libGL, motif
} :

stdenv.mkDerivation rec {
  pname = "multiwfn";
  version = "3.7";

  # Only builds with Intel tooling. ifort is not available in Nix, therefore the binary package.
  src = fetchurl {
    url = "http://sobereva.com/multiwfn/misc/Multiwfn_${version}_bin_Linux.zip";
    sha256 = "1xv8kicc34c5fx1mddmm9a94j5nm7nr6yrsvfm5v59a0wgk76rbs";
  };

  nativeBuildInputs = [
    makeWrapper
    autoPatchelfHook
    unzip
  ];

  buildInputs = [
    xorg.libX11
    libGL
    motif
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin $out/share/multiwfn

    # Copy binary to $out
    chmod +x Multiwfn
    cp Multiwfn $out/bin/.

    # Copy examples and settings
    cp -r examples settings.ini $out/share/multiwfn/.

    # Symlink the settings.
    ln -s $out/share/multiwfn/settings.ini $out/bin/.
  '';

  meta = with lib; {
    description = "Multifunctional wave function analyser.";
    license = licenses.bsd3;
    homepage = "http://sobereva.com/multiwfn/index.html";
    platforms = [ "x86_64-linux" ];
  };
}
