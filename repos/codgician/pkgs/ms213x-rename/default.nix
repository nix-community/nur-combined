{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:

buildGoModule rec {
  pname = "ms213x-rename";
  version = "0.0.2-unstable-2025-01-14";

  src = fetchFromGitHub {
    owner = "Starainrt";
    repo = pname;
    rev = "bfc980961999f4fa03bd960882296fef18853d38";
    hash = "sha256-jcSQpEhw+9waOCVePKDjOg7uj1eUoZ6pnC3lgwltbfw=";
  };

  vendorHash = "sha256-hocnLCzWN8srQcO3BMNkd2lt0m54Qe7sqAhUxVZlz1k=";

  passthru.updateScript = nix-update-script { 
    extraArgs = [
      "--version"
      "branch=master"
    ];
  };

  meta = {
    description = "A tool that helps you modify the basic EDID information in the MS213X collector firmware, such as the display name, serial number etc.";
    homepage = "https://github.com/Starainrt/ms213x-rename";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ codgician ];
  };
}
