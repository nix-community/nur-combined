{ 
  rustPlatform, lib, fetchgit, pkgs
}:
rustPlatform.buildRustPackage rec {
  
  pname = "para-audit";
  version = "0.1.11";

  cargoHash = "sha256-sso1OF+n+UrRUTaXveYi5EbUI65X3NkeYEdx7nNRQKE=";

  nativeBuildInputs = [ pkgs.pkg-config ];
  buildInputs = [ pkgs.openssl ];

  src = fetchgit {
    url = "https://github.com/jcranney/para-audit.git";
    tag = version;
    hash = "sha256-tOfq/lkvdaTKzyQY0mQjbRLloE2udQAqgdIPYJBzfDg=";
  };

  meta = with lib; {
    description = "A tool for auditing/organising/interacting with my para system.";
    homepage = https://github.com/jcranney/para-audit;
    license = licenses.unlicense;
    platforms = platforms.all;
    mainProgram = "para";
  };
}