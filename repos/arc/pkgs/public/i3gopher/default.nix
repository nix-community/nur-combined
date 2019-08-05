{ buildGoPackage, fetchFromGitHub, makeWrapper, lib, i3 }: lib.drvExec "bin/i3gopher" (buildGoPackage rec {
  pname = "i3gopher";
  version = "0.1.0";
  goPackagePath = "github.com/quite/i3gopher";
  src = fetchFromGitHub {
    owner = "quite";
    repo = "i3gopher";
    rev = "v${version}";
    sha256 = "1c22hxfspgg3dx1yr52spw8vpw3h170yb81d2lwx9jfnydpf1krl";
  };

  goDeps = ./deps.nix;

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ i3 ];
  i3Path = lib.makeBinPath [ i3 ];
  preFixup = ''
    wrapProgram $bin/bin/i3gopher --prefix PATH : $i3Path
  '';

  meta = {
    platforms = i3.meta.platforms;
  };
})
