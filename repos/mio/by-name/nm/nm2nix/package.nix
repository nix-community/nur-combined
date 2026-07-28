{
  lib,
  stdenv,
  fetchFromGitHub,
  python3,
}:

stdenv.mkDerivation rec {
  pname = "nm2nix";
  version = "0-unstable-2026-03-31";

  src = fetchFromGitHub {
    owner = "janik-haag";
    repo = "nm2nix";
    rev = "6d018aaad4093097fd647f867425a15f294e483e";
    hash = "sha256-etI2VY39TIKl+W/MzraxTYE3eaqH9VYThe3YJzydV0E=";
  };

  buildInputs = [ python3 ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    echo "#!${python3}/bin/python3" > $out/bin/nm2nix
    cat nm2nix.py >> $out/bin/nm2nix
    chmod +x $out/bin/nm2nix

    runHook postInstall
  '';

  meta = with lib; {
    description = "Convert NetworkManager connections to nix";
    homepage = "https://github.com/janik-haag/nm2nix";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "nm2nix";
  };
}
