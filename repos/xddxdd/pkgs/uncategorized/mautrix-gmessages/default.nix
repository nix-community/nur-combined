{
  fetchFromGitHub,
  lib,
  buildGoModule,
  nix-update-script,
  olm,
  # This option enables the use of an experimental pure-Go implementation of
  # the Olm protocol instead of libolm for end-to-end encryption. Using goolm
  # is not recommended by the mautrix developers, but they are interested in
  # people trying it out in non-production-critical environments and reporting
  # any issues they run into.
  withGoolm ? false,
}:

buildGoModule (finalAttrs: {
  pname = "mautrix-gmessages";
  version = "0.2608.0";
  src = fetchFromGitHub {
    owner = "mautrix";
    repo = "gmessages";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wqjc074zKHkgqFcnBPFmR36xE5CVzRvupF3AdlQ0Lwk=";
  };
  vendorHash = "sha256-UL7YxLF/DMwkGP8TEaN48wYGrlfBYHSZQqc7UqdhDKE=";

  buildInputs = lib.optional (!withGoolm) olm;
  tags = lib.optional withGoolm "goolm";

  preBuild = ''
    export MAUTRIX_VERSION=$(cat go.mod | grep 'maunium.net/go/mautrix ' | awk '{ print $2 }')
    ldflags=("''$ldflags[@]" "-X maunium.net/go/mautrix.GoModVersion=$MAUTRIX_VERSION")
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.Tag=v${finalAttrs.version}"
    "-X main.Commit=0000000000000000000000000000000000000000"
    "-X main.BuildTime=0"
  ];

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/mautrix/gmessages/releases/tag/v${finalAttrs.version}";
    homepage = "https://github.com/mautrix/gmessages";
    description = "Matrix-Google Messages puppeting bridge";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ xddxdd ];
    mainProgram = "mautrix-gmessages";
  };
})
