{ lib, stdenvNoCC, fetchurl, gnutar, zstd, autoPatchelfHook }:

stdenvNoCC.mkDerivation rec {
  ### Name this program with this name bc edit already exist (not the same program)
  pname = "msedit";
  version = "1.2.0";

  src = fetchurl {
    url = "https://github.com/microsoft/edit/releases/download/v${version}/edit-${version}-x86_64-linux-gnu.tar.zst";
    sha256 = "sha256-runy8h68kMwdv7IO6T06oD0yUSeo4/f5HdAsWp4KeyU=";
  };
  
  ### stdenv options
  dontUnpack = true;
  dontBuild = true;
  dontConfigure = true;
  sourceRoot = ".";

  nativeBuildInputs = [
    ### tools for decompression
    gnutar
    zstd

    ### Auto-patch program
    autoPatchelfHook
  ];

  installPhase = ''
    ### Create directory and move binary
    mkdir -p $out/bin
    
    ### Move program to $out/bin/
    tar --use-compress-program=unzstd -xf $src -C $out/bin/
    
    ### Rename edit to msedit (from the archive)
    mv $out/bin/edit $out/bin/${pname}

    ### Make this program executable
    chmod +x $out/bin/${pname}
  '';

  meta = with lib; {
    description = "A simple editor for simple needs.";
    homepage = "https://github.com/microsoft/edit";
    license = licenses.mit;
    mainProgram = "msedit";
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [ minegameYTB ];
  };
}

