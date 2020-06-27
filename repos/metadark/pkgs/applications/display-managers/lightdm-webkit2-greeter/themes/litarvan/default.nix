# FIXME: Transparent bars using background blur on HiDPI screen (webkit2 bug):

{ stdenvNoCC, fetchFromGitHub
, nodejs }:

let
  pname = "lightdm-webkit2-theme-litarvan";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "Litarvan";
    repo = "lightdm-webkit-theme-litarvan";
    rev = "v${version}";
    sha256 = "00q5wsrsk7s2brpzk8bky650gj4hskhaap7qbqk3nybcwd9bvfgm";
  };

  node_modules = stdenvNoCC.mkDerivation {
    pname = "${pname}-node_modules";
    inherit version src;

    buildInputs = [ nodejs ];
    buildPhase = "HOME=. npm install";
    installPhase = ''
      mkdir -p $out
      cp -r node_modules $out
    '';

    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "0kr5a45wpfpmargzf2c9x216893wx6s6swxi7pphxsvp3zrh3hjp";
  };
in stdenvNoCC.mkDerivation {
  inherit pname version src;

  buildInputs = [ nodejs ];
  buildPhase = ''
    mkdir -p node_modules
    cp -r ${node_modules} node_modules
    npm run build
  '';

  installPhase = ''
    mkdir -p $out
    cp -r dist $out
  '';
}
