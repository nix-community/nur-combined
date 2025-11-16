{ 
  rustPlatform, lib, fetchgit, pkgs
}:
rustPlatform.buildRustPackage rec {
  
  pname = "para-audit";
  version = "v0.1.14";

  cargoHash = "sha256-4QjnsSzo3jwZIY0uZ7pjnoMGjrO/eaw09WLMw6jh7Ns=";

  nativeBuildInputs = [ pkgs.pkg-config ];
  buildInputs = [ pkgs.openssl ];

  src = fetchgit {
    url = "https://github.com/jcranney/para-audit.git";
    tag = version;
    hash = "sha256-G1/EBY0QB79gNhugU28miJCjxmDHKhCBiAQXqRE8NJQ=";
  };

  meta = with lib; {
    description = "A tool for auditing/organising/interacting with my para system.";
    homepage = https://github.com/jcranney/para-audit;
    license = licenses.unlicense;
    platforms = platforms.all;
    mainProgram = "para";
  };
}