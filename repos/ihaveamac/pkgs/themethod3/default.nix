{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "themethod3";
  version = "0-unstable-2025-05-26";

  src = fetchFromGitHub {
    owner = "DarkRTA";
    repo = pname;
    rev = "90385dec5034bf3ae341b01c2930548d1acb7095";
    sha256 = "sha256-MK3jb5NmMmqdCIvbNYUusVfdYu7QWHBeNHk/rzw9kho=";
  };

  cargoPatches = [
    ./add-Cargo.lock.patch
  ];

  cargoHash = "sha256-Qc7fIC6c9CDIt8ft+P67V5q9LWxH1V25kmFUWf8VUrk=";

  meta = with lib; {
    description = "Tool for decrypting all mogg files used by the Rock Band series";
    homepage = "https://github.com/DarkRTA/themethod3";
    license = licenses.gpl3;
    platforms = platforms.all;
    mainProgram = "themethod3";
  };
}
