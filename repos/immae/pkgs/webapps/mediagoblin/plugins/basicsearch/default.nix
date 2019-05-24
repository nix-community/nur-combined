{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation rec {
  name = "mediagoblin-plugin-basicsearch-${version}";
  version = "ba0a154-master";
  src = fetchFromGitHub {
    owner = "ayleph";
    repo = "mediagoblin-basicsearch";
    rev = "ba0a1547bd24ebaf363227fe17644d38c6ce8a6b";
    sha256 = "0d4r7xkf4gxmgaxlb264l44xbanis77g49frwfhfzsflxmdwgncy";
  };
  phases = "unpackPhase installPhase";
  installPhase = ''
    cp -R ./basicsearch $out
    '';
  passthru = {
    pluginName = "basicsearch";
  };
}
