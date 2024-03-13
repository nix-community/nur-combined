{ buildGoModule, anytype }:

buildGoModule {
  inherit (anytype) version src;

  pname = "anytype-nmh";
  sourceRoot = "${anytype.src.name}/go";
  vendorHash = null;

  postFixup = ''
    mv "$out/bin/go" "$out/bin/nativeMessagingHost"
  '';

  meta = anytype.meta // {
    description = "Native messaging host for the AnyType browser extension";
  };
}
