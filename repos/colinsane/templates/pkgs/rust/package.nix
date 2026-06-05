{
  fetchFromGitHub,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "elfcat";
  version = "0.1.8";

  src = fetchFromGitHub {
    owner = "ruslashev";
    repo = "elfcat";
    rev = version;
    hash = "sha256-NzFKNCCPWBj/fhaEJF34nyeyvLMeQwIcQgTlYc6mgYo=";
  };

  cargoHash = "sha256-Dc+SuLwbLFcNSr9RiNSc7dgisBOvOUEIDR8dFAkC/O0=";

  meta = {
    description = "TODO: FILLME";
    longDescription = ''
      TODO: FILLME
    '';
    homepage = "https://github.com/ruslashev/elfcat";
    # license = lib.licenses.zlib;
    maintainers = with lib.maintainers; [ colinsane ];
  };
}
