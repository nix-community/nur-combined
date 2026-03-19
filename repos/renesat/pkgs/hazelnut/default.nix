{
  fetchFromGitHub,
  rustPlatform,
  lib,
}:
rustPlatform.buildRustPackage rec {
  pname = "hazelnut";
  version = "0.2.49";

  src = fetchFromGitHub {
    owner = "ricardodantas";
    repo = "hazelnut";
    rev = "v${version}";
    hash = "sha256-u/995uyTWzuG0z6QAEdUU+CNiQtt5rZzAheVdhxZXxU=";
  };

  cargoHash = "sha256-qjfIChzzxkU1vEHCzNloCTD3is8O+k0OEEf+N6ppRsI=";

  meta = {
    description = "Terminal-based automated file organizer inspired by Hazel. Watch folders and organize files with rules.";
    homepage = "https://github.com/ricardodantas/hazelnut";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [renesat];
  };
}
