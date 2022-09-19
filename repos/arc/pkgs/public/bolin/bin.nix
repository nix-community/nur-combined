{ stdenvNoCC
, requireFile
, unzip
, makeWrapper
, callPackage
}: stdenvNoCC.mkDerivation (attrs: {
  pname = "bolin-bin";
  version = "2022-08-13";

  src = requireFile {
    url = "https://bolinlang.com/download";
    name = "bolin.zip";
    sha256 = "97d8435805e6d31ec3ef801537d3f64afdf3d797b0348c0d1ab1880c24bd0439";
  };

  nativeBuildInputs = [ unzip makeWrapper ];

  outputs = [ "out" "lib" ];

  unpackPhase = ''
    runHook preUnpack

    unzip $src -d src
    sourceRoot=src

    runHook postUnpack
  '';

  buildPhase = ":";

  installPhase = ''
    runHook preInstall

    install -d $out/bin $lib/lib/bolin $out/share/licenses
    mv bolin $out/bin/
    mv *.o standard $lib/lib/bolin/
    mv eula.txt $out/share/licenses/bolin.txt

    runHook postInstall
  '';

  wrapperCmd = ''
    ln -sf ${placeholder "lib"}/lib/bolin/* ./
  '';

  postInstall = ''
    wrapProgram $out/bin/bolin --run "$wrapperCmd"
  '';

  passthru.ci.skip = true;
})
