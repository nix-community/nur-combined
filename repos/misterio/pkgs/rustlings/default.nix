{ lib, stdenv, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "rustlings";
  version = "4.6.0";

  src = fetchFromGitHub {
    owner = "rust-lang";
    repo = pname;
    rev = version;
    sha256 = "sha256-ORoahvjTMkd0ylwlNslUlm0nveVLyrHBwR5ejfkjBss=";
  };

  cargoHash = lib.fakeHash;

  meta = with lib; {
    description = "Small exercises to get you used to reading and writing Rust code!";
    homepage = "https://github.com/rust-lang/${pname}";
    changelog = "https://github.com/rust-lang/${pname}/releases/tag/${version}";
    license = licenses.mit;
    broken = true;
  };
}
