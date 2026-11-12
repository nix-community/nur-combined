{
  lib,
  buildGoModule,
  callPackage,

  sources,
  source ? sources.artex,
}:

buildGoModule (finalAttrs: {
  inherit (source)
    pname
    version
    src
    vendorHash
    ;

  # Keep signing keys outside the Nix store and browsable workspace.
  patches = [ ./jwt-key-dir.patch ];

  subPackages = [ "cmd/artex" ];

  tags = [ "embedui" ];

  ldflags = [
    "-s"
    "-X main.version=${finalAttrs.version}"
  ];

  preBuild = ''
    rm -rf server/webui/dist
    mkdir -p server/webui
    cp -r ${finalAttrs.passthru.frontend} server/webui/dist
    chmod -R u+w server/webui/dist
  '';

  postInstall = ''
    mkdir -p $out/share/artex
    cp -r skills $out/share/artex/skills
    install -Dm644 config.example.json $out/share/artex/config.example.json
  '';

  # Tests need a running PostgreSQL
  doCheck = false;

  passthru = {
    frontend = callPackage ./frontend.nix {
      inherit source;
      meta = lib.removeAttrs finalAttrs.meta [ "mainProgram" ];
    };
  };

  meta = {
    description = "AI autonomous penetration testing system";
    homepage = "https://github.com/RuoJi6/ARTEX";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "artex";
  };
})
