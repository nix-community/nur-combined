{
  lib,
  stdenv,
  fetchurl,
}:
let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  suffix =
    {
      x86_64-linux = "x86_64";
      x86_64-darwin = "macos-x86_64";
    }
    .${system} or throwSystem;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "pvs-studio";
  version = "7.35.89253.317";

  src = fetchurl {
    url = "https://cdn.pvs-studio.com/pvs-studio-${finalAttrs.version}-${suffix}.tgz";
    hash =
      {
        x86_64-linux = "sha256-pnrRriufaRPwZzAFKHRDFbyg1LEi9rUs31LwKdJj96M=";
        x86_64-darwin = "sha256-HRJMF+ETqjDTXZx7qzX9mmdRiH9jHSL1RXBQA4CNkYE=";
      }
      .${system} or throwSystem;
  };

  installPhase = "sh ./install.sh $out";

  meta = {
    description = "Static code analyzer for C, C++";
    homepage = "https://www.viva64.com/en/pvs-studio/";
    license = lib.licenses.unfree;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = [
      "x86_64-linux"
      "x86_64-darwin"
    ];
    skip.ci = true;
  };
})
