{ source, nixfmt }:
nixfmt.overrideAttrs (
  finalAttrs: prevAttrs: {
    version = "${prevAttrs.version}-rfc-${source.date}";
    name = "${prevAttrs.pname}-${finalAttrs.version}";
    inherit (source) src;

    meta = prevAttrs.meta // {
      description = "nixfmt adoped rfc101/166 style";
      homepage = "https://github.com/NixOS/nixfmt";
    };
  }
)
