{
  fetchFromGitHub,
  buildGoModule,
  gnupg,
}:
buildGoModule rec {
  pname = "mnemonikey";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "kklash";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-x3HP9n5K71TjN+UDKft/fMnFU32vD4RC0G/WWweI7e4=";
  };

  nativeCheckInputs = [gnupg];

  vendorHash = "sha256-mEJEuHHV4t8S8PLBoxg/iPwAjCiqnG7A/t++ypFFYLE=";
}
