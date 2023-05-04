{ lib
, rustPlatform
, fetchFromGitHub
}:

rustPlatform.buildRustPackage rec {
  pname = "elfcat";
  version = "0.1.8";

  src = fetchFromGitHub {
    owner = "ruslashev";
    repo = pname;
    rev = version;
    hash = "sha256-NzFKNCCPWBj/fhaEJF34nyeyvLMeQwIcQgTlYc6mgYo=";
  };

  cargoHash = "sha256-Dc+SuLwbLFcNSr9RiNSc7dgisBOvOUEIDR8dFAkC/O0=";

  meta = with lib; {
    description = "TODO: FILLME";
    homepage = "https://github.com/ruslashev/elfcat";
    license = licenses.zlib;
    maintainers = with maintainers; [ colinsane ];
  };
}
