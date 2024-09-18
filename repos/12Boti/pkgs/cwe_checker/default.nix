{
  fetchFromGitHub,
  rustPlatform,
  ghidra,
  makeWrapper,
}:
rustPlatform.buildRustPackage rec {
  pname = "cwe_checker";
  version = "master";
  src = fetchFromGitHub {
    owner = "fkie-cad";
    repo = "cwe_checker";
    rev = "270b4d4e0c9256abb63e7ca5b114481653b60691";
    hash = "sha256-Tao4sb82aXhjDcWRH3FNwefmlZIn72AEZIqZJa6jxww=";
  };
  cargoHash = "sha256-NZj3N4Y80CnmYxJX8oXGjj1W3skcwwSGFmzklI6JXTc=";
  postInstall = ''
    mkdir -p $out/share/cwe_checker
    cp -r ${src}/src/ghidra $out/share/cwe_checker/ghidra
    cp ${src}/src/config.json $out/share/cwe_checker
    echo '{"ghidra_path":"${ghidra}/lib/ghidra"}' > $out/share/cwe_checker/ghidra.json
    wrapProgram $out/bin/cwe_checker \
      --set XDG_CONFIG_HOME $out/share \
      --set XDG_DATA_HOME $out/share
  '';
  nativeBuildInputs = [ makeWrapper ];
}
