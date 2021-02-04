{ lib, stdenv, fetchgdrive, unzip, wxGTK30
, makeWrapper, libredirect
, pname, version, id, sha256, description, homepage }:

stdenv.mkDerivation {
  inherit pname version;

  src = fetchgdrive {
    inherit id sha256;
    name = "${pname}_linux64.zip";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ makeWrapper unzip ];

  dontStrip = true;
  dontPatchELF = true;

  installPhase = ''
    [ -f ${pname} ] && install -Dm755 ${pname} -t $out/bin
    [ -f ${pname}_linux ] && install -Dm755 ${pname}_linux $out/bin/${pname}
    install -Dm644 libTdhCairo.so -t $out/lib
    install -Dm644 *.{pdf,txt} -t $out/share/doc/${pname}
    install -dm755 $out/share/${pname}
    cp -r *_Structure $out/share/${pname}
  '';

  postFixup = with lib; ''
    patchelf --replace-needed "./libTdhCairo.so" libTdhCairo.so $out/bin/${pname}

    patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
      --set-rpath "$out/lib:${makeLibraryPath [ stdenv.cc.cc.lib wxGTK30 ]}" \
      $out/bin/${pname}

    wrapProgram $out/bin/${pname} \
      --set LD_PRELOAD "${libredirect}/lib/libredirect.so" \
      --set NIX_REDIRECTS "$out/bin/${pname}_Structure=$out/share/${pname}/${pname}_Structure"
  '';

  preferLocalBuild = true;

  meta = with lib; {
    inherit description homepage;
    license = licenses.cc-by-nc-sa-40;
    maintainers = with maintainers; [ sikmir ];
    platforms = [ "x86_64-linux" ];
    skip.ci = true;
  };
}
