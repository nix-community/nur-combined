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

  meta = {
    changelog = "https://github.com/mautrix/gmessages/releases/tag/v${finalAttrs.version}";
    homepage = "https://github.com/mautrix/gmessages";
    description = "Matrix-Google Messages puppeting bridge";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ xddxdd ];
    mainProgram = "mautrix-gmessages";
  };
})
