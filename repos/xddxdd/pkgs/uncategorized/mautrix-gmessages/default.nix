{
  sources,
  lib,
  buildGoModule,
  olm,
  # This option enables the use of an experimental pure-Go implementation of
  # the Olm protocol instead of libolm for end-to-end encryption. Using goolm
  # is not recommended by the mautrix developers, but they are interested in
  # people trying it out in non-production-critical environments and reporting
  # any issues they run into.
  withGoolm ? false,
}:

buildGoModule (finalAttrs: {
  inherit (sources.mautrix-gmessages) pname version src;

  vendorHash = "sha256-6Zwi/6VWDTXtzhWt8dfNoTp//2Tco72b88Mf/tBhasg=";

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

  meta = {
    changelog = "https://github.com/mautrix/gmessages/releases/tag/v${finalAttrs.version}";
    homepage = "https://github.com/mautrix/gmessages";
    description = "Matrix-Google Messages puppeting bridge";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ xddxdd ];
    mainProgram = "mautrix-gmessages";
  };
})
