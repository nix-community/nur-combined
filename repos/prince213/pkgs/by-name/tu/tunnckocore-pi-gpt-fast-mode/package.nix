{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "tunnckocore-pi-gpt-fast-mode";
  version = "0.4.0-unstable-2026-09-08";

  __structuredAttrs = true;
  strictDeps = true;

  # https://github.com/tunnckoCore/pi-gpt-fast-mode/pull/3
  src = fetchFromGitHub {
    owner = "alexanderkreidich";
    repo = "pi-gpt-fast-mode";
    rev = "0904bebaddeeaf529fdca876a32b0149356bac7a";
    hash = "sha256-gibz8nJ70JQFVh30hixOhrXaVuy3IWhww65k3UXsGZw=";
  };

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r src package.json $out

    runHook postInstall
  '';

  meta = {
    description = "Toggle GPT Fast mode for the Pi coding agent";
    homepage = "https://github.com/tunnckoCore/pi-gpt-fast-mode";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
  };
}
