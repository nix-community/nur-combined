{ rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage {
  pname = "rust-synapse-compress-state";
  version = "unstable-2020-02-20";

  src = fetchFromGitHub {
    owner = "matrix-org";
    repo = "rust-synapse-compress-state";
    rev = "1aac27ebb63b4f4d97460e888cfbbbb75e3ec586";
    sha256 = "15jvkpbq6pgdc91wnni8fj435yqlwqgx3bb0vqjgsdyxs5lzalfh";
  };

  cargoSha256 = "1kzb24yn3fxxwfqkbawd3b4rcphy2fihm6w351rf3gkrjdw4idzw";
}
