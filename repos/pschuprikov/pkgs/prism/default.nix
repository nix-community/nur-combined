{ stdenv, fetchFromGitHub, jdk, coreutils }:
stdenv.mkDerivation rec {
  pname = "prism";
  version = "4.7";
  src = fetchFromGitHub {
    owner = "prismmodelchecker";
    repo = "prism";
    rev = "v${version}";
    sha256 = "ivZshLRtje9B+8RiG0jhGX8YkLvMCz62+I25ycR5dQs=";
  };
  prePatch = ''
    substituteInPlace prism/install.sh \
      --replace "/bin/mv" "${coreutils}/bin/mv"
  '';
  makeFlags = ["-Cprism" "JAVA_DIR=${jdk.home}"];
  buildInputs = [ jdk ];
  enableParallelBuilding = true;
  installPhase = ''
    install -d $out/bin
    install -d $out/classes
    install -d $out/lib

    cp -r prism/bin/* $out/bin
    cp -r prism/classes/* $out/classes
    cp -r prism/lib/* $out/lib
  '';

  preFixup = ''
    sed -E "s|PRISM_DIR=\".*\"|PRISM_DIR=\"$out\"|" -i $out/bin/prism $out/bin/xprism 
  '';
}
