/*
  https://github.com/vroad/gclient2nix/blob/master/gclient2nix.nix
*/

{ lib
, stdenv
, fetchFromGitHub
, jq
, makeWrapper
, gclient
}:

stdenv.mkDerivation rec {
  pname = "gclient2nix";
  version = "unstable-2021-04-17";

  src = fetchFromGitHub {
    owner = "vroad";
    repo = "gclient2nix";
    rev = "94ed19349ff630ca0c7376a2fc9d28ec5df0e34e";
    hash = "sha256-e0FQimVtSwgnZ6KmpQ+76ovsNIBhKd+qJE9HCiKe+XM=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase = ''
    mkdir $out
    cp -r $src/src $out/bin
    chmod -R +w $out/bin
    wrapProgram $out/bin/gclient2nix \
      --prefix PATH : ${lib.makeBinPath [
        jq
        gclient
      ]}
  '';

  meta = with lib; {
    description = "Generate Nix expressions for projects using the Google Gn build tool";
    homepage = "https://github.com/vroad/gclient2nix";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
