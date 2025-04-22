{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  bzip2,
  nettle,
}:

rustPlatform.buildRustPackage rec {
  pname = "vanitygpg";
  #version = "0.3.2";
  version = "0.3.3"; # untagged

  src = fetchFromGitHub {
    owner = "redl0tus";
    repo = "vanitygpg";
    #rev = "v${version}";
    # fix: error: failed to run custom build command for `nettle-sys v2.1.0`
    rev = "4f6fcd4233d6b658b1b03622d8f6e768538ddf1c";
    hash = "sha256-mZWyIOdX+pP2xO+2kmmKc1bsCGTOvR/IezcDGzhka3Y=";
  };

  cargoHash = "sha256-B3csNTAL0k4K5ZyEFQpzRrhIA+WVN0ZLuW5M4nHesY8=";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    bzip2
    nettle
  ];

  meta = {
    description = "generate vanity GPG keys";
    homepage = "https://github.com/redl0tus/vanitygpg";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "vanity_gpg";
  };
}
