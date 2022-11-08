{ pkgs, fetchFromGitHub }:

pkgs.crystal.buildCrystalPackage rec {
  pname = "dmnd-bot";
  version = "0.2.3";
  src = fetchFromGitHub {
    owner = "ZerataX";
    repo = pname;
    rev = "v${version}";
    sha256 = "1p6f647a4f61wjmjy1p0xn5p8wxr9n8ji33kx1d5kzw1v9shfq3d";
  };

  format = "shards";

  shardsFile = ./shards.nix;

  buildInputs = [
    pkgs.openssl
  ];

  checkInputs = [
    pkgs.openssl
    pkgs.syncplay
  ];

  postPatch = ''
    substituteInPlace spec/syncplay_bot_spec.cr \
        --replace 'syncplay' '${pkgs.syncplay}/bin/syncplay'
  '';
  
  preCheck = ''                   
    echo "creating test certs..." 
    pushd spec/test_certs/        
    bash create_certs.sh          
    popd                          
    echo "done!"                  
  '';                             
}
