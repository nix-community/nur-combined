{ jq, expect, stdenv, fetchFromGitHub, _1password, gnused, makeWrapper, lib}:
stdenv.mkDerivation rec {
  pname = "dcreemer-1pass";
  version = "1.2";
  src = fetchFromGitHub {
    rev = "v${version}";
    owner = "dcreemer";
    repo = "1pass";
    sha256 = "0lchx4rcs8sb17jxfm7mqwlsfq3ip87am2wl7sb04g9c6r2gsg3p";
  };
  nativeBuildInputs = [ makeWrapper ];
  installPhase = ''
    mkdir -p $out/bin
    cp 1pass $out/1pass_unwrapped
    makeWrapper $out/1pass_unwrapped $out/bin/1pass \
      --prefix PATH : ${lib.makeBinPath [ expect jq _1password gnused ]}
  '';
}
