{ stdenv, pkgs, fetchFromGitHub, bundlerEnv, ruby, bash, perl }:
let
  rubyEnv = bundlerEnv rec {
  name = "cigri-env";
  inherit ruby;
  gemdir  = ./.;
  #groups = [ "default" "unicorn" "test" ]; # TODO not used
};
  in
    stdenv.mkDerivation rec {
  name = "cigri-3.0.0";
  src = fetchFromGitHub {
    owner = "oar-team";
    repo = "cigri";
    rev = "eeadb6b34c9d1365762a6b7d6f5598ad4bc68a21";
    sha256 = "1l9jpnzph4kal5950x2x8nzbqhdfk0f6jjbs79wznnkxqra5n9qc";
  };
  
  buildInputs = [ rubyEnv rubyEnv.wrappedRuby rubyEnv.bundler bash perl ];
  
  buildPhase = ''
    # TODO warning /var/cigri/state can be overriden /modules/services/cigri.nix configuration 
    substituteInPlace modules/almighty.rb \
    --replace /var/run/cigri/almighty.pid /var/cigri/state/home/pidsalmighty.pid

    mkdir -p $out/bin $out/sbin
    make PREFIX=$out SHELL=${bash}/bin/bash \
    install-cigri-libs install-cigri-modules \
    install-cigri-server-tools install-cigri-user-cmds \
    install-cigri-api
  '';

  postInstall = ''
    cp -r database $out
  '';
  
  passthru = {
    inherit rubyEnv;
  };
  
  meta = with stdenv.lib; {
    homepage = "https://github.com/oar-team/cigri";
    description = "CiGri: a Lightweight Grid Middleware";
    license = licenses.lgpl3;
    longDescription = ''
    '';
  };
}
