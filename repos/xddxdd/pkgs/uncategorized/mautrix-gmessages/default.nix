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

buildGoModule rec {
  inherit (sources.mautrix-gmessages) pname version src;

  vendorHash = "sha256-8KexkPsRqzlVeYMF0dVgDMS38zQ3i+erQgsdgHDOCF0=";

  buildInputs = lib.optional (!withGoolm) olm;
  tags = lib.optional withGoolm "goolm";

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/mautrix/gmessages";
    description = "Matrix-Google Messages puppeting bridge";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ xddxdd ];
    mainProgram = "mautrix-gmessages";
  };
}
