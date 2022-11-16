{ sources, stdenv, lib, gzip }:

stdenv.mkDerivation rec {
  inherit (sources.vlmcsd) pname version src;

  buildPhase = ''
    make

    pushd man
    ${gzip}/bin/gzip -fk *.[0-9]
    popd
  '';

  installPhase = ''
    pushd bin
    for bin in vlmcs{d,}; do
      install -Dm755 $bin "$out/bin/$bin"
    done
    popd

    pushd man
    for manpage in *.[0-9]; do
      section=''${manpage##*.}
      install -Dm644 "$manpage.gz" "$out/share/man/man$section/$manpage.gz"
    done
    popd
  '';

  meta = with lib; {
    description = "KMS Emulator in C";
    homepage = "https://github.com/Wind4/vlmcsd";
    maintainers = with maintainers; [ yinfeng ];
  };
}
