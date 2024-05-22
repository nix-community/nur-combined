{ lib

, fetchFromGitHub

, rustPlatform

, bash
}:
rustPlatform.buildRustPackage rec {
  pname = "amber-lang";
  version = "0.3.1-alpha";

  src = fetchFromGitHub {
    owner = "Ph0enixKM";
    repo = "Amber";
    rev = version;
    hash = "sha256-VSlLPgoi+KPnUQJEb6m0VZQVs1zkxEnfqs3fAp8m1o4=";
  };

  cargoHash = "sha256-NzcyX/1yeFcI80pNxx/OTkaI82qyQFJW8U0vPbqSU7g=";

  postPatch = ''
    substituteInPlace src/compiler.rs \
      --replace-warn "/bin/bash" "${bash}/bin/bash"
  '';

  # FIXME: For weird reasons some tests fails
  doCheck = false;

  checkFlags = [
    "--skip=tests::validity::infinite_loop"
  ];

  meta = with lib; {
    description = "Amber the programming language compiled to bash";
    homepage = "https://amber-lang.com";
    license = licenses.gpl3;
    mainProgram = "amber";
  };
}
