{ source, nixfmt }:
nixfmt.overrideAttrs (
  finalAttrs: prevAttrs: {
    version = "${prevAttrs.version}-rfc-${source.date}";
    name = "${prevAttrs.pname}-${finalAttrs.version}";
    inherit (source) src;
  }
)
