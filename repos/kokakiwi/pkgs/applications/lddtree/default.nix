{ lib

, fetchFromGitHub

, rustPlatform
}:
rustPlatform.buildRustPackage rec {
  pname = "lddtree";
  version = "0.3.7";

  src = fetchFromGitHub {
    owner = "messense";
    repo = "lddtree-rs";
    rev = "v${version}";
    hash = "sha256-aYU66OAV8CiweoilwDzgPw038a0qk/jlNhg3zvz1V/8=";
  };

  cargoHash = "sha256-BXOFmWQ7IhY88Yza9ySSv6+Kps8tFHPZ1KHPOwymeuA=";

  meta = with lib; {
    description = "Read the ELF dependency tree";
    homepage = "https://github.com/messense/lddtree-rs";
    license = licenses.mit;
    mainProgram = "lddtree";
  };
}
