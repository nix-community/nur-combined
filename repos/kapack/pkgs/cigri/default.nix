{ stdenv, lib, pkgs, fetchFromGitHub, bundlerEnv, ruby, bash, perl }:
let
  rubyEnv = bundlerEnv rec {
  name = "cigri-env";
  inherit ruby;
  # gemdir  = ./.;
  gemfile = ./Gemfile;
  lockfile = ./Gemfile.lock;
  gemset = ./gemset.nix;
  #groups = [ "default" "unicorn" "test" ]; # TODO not used
};
  in
    stdenv.mkDerivation rec {
  name = "cigri-3.2.2";
  src = fetchFromGitHub {
    owner = "oar-team";
    repo = "cigri";
    rev = "3.2.2";
    sha256 = "sha256-qeDTT9Ca1Pd2Amg08J3PwuG+OfqxJkGQJCZIz8LcLA0=";
  };
  
  buildInputs = [
    rubyEnv rubyEnv.wrappedRuby rubyEnv.bundler
    bash perl
  ];
  
  buildPhase = ''
    # TODO warning /var/cigri/state can be overriden /modules/services/cigri.nix configuration 
    substituteInPlace modules/almighty.rb \
    --replace /var/run/cigri/almighty.pid /var/cigri/state/home/pidsalmighty.pid

    mkdir -p $out/bin  $out/sbin
    make PREFIX=$out SHELL=${bash}/bin/bash \
    install-cigri-libs install-cigri-modules \
    install-cigri-server-tools install-cigri-user-cmds \
    install-cigri-api
    # generate well located newcluster
    echo -e "#!/bin/bash\nCIGRICONFFILE=/etc/cigri.conf CIGRIDIR=$out/share/cigri \
    $out/share/cigri/sbin/newcluster "'"$@"' > $out/sbin/newcluster
    chmod 755 $out/sbin/newcluster
  '';
    
  postInstall = ''
    cp -r database $out
  '';

  # Allow rubyEnv to be use in modules/services/cigri configuration
  passthru = {
    inherit rubyEnv;
  };
  
  meta = with lib; {
    homepage = "https://github.com/oar-team/cigri";
    description = "CiGri: a Lightweight Grid Middleware";
    license = licenses.lgpl3;
    longDescription = ''
    '';
    # broken = true;
  };
}
