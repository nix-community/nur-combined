{ buildGoModule, fetchFromGitHub, makeWrapper, lib, i3 }: lib.drvExec "bin/i3gopher" (buildGoModule rec {
  pname = "i3gopher";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "quite";
    repo = "i3gopher";
    rev = "v${version}";
    sha256 = "03zlzd7v1n3nkjwyjsm2xc324jqpz6f93ksq19qqmnbyqqahphxy";
  };

  modSha256 = "1c4qx7ig59qqflmbkxi6bm97z38jcy9nsf6nj8j8w3fgc1f36r1g";
  vendorSha256 = "0nbzm5j8vvdgddzd13qk87pamiw30i0a02sn6i1myx7rxcbi9vgm";

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ i3 ];
  i3Path = lib.makeBinPath [ i3 ];
  preFixup = ''
    wrapProgram $out/bin/i3gopher --prefix PATH : $i3Path
  '';

  meta = {
    platforms = i3.meta.platforms;
    broken = lib.isNixpkgsStable;
  };
})
