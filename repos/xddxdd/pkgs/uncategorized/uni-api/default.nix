{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "uni-api";
  version = "1.7.276-unstable-2026-10-15";
  src = fetchFromGitHub {
    owner = "yym68686";
    repo = "uni-api";
    rev = "fdff9271159942db3f4a9fc6507f8a1934f77fd1";
    hash = "sha256-py/ipOj097R+cRH39E3HCewaaTzqzSr8PLP0sOaK2FQ=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  cargoHash = "sha256-1JMVILW74iJbq0QJl3CJp9+SdQ1XuF2JxYgIfhWPuYY=";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Unifies the management of LLM APIs across multiple backend services";
    homepage = "https://github.com/yym68686/uni-api";
    license = lib.licenses.unfree;
    mainProgram = "uni-api-front";
  };
})
