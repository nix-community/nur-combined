{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  pkg-config,
  cairo,
}:

buildGoModule (finalAttrs: {
  pname = "mapillary-render";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "wladich";
    repo = "mapillaryRender";
    tag = finalAttrs.version;
    hash = "sha256-B2yDjbvpaa9zjPG9yF64s0tJ/bPAH0sOYqY74+f/TYE=";
  };

  vendorHash = "sha256-kRu8UST1gVnQ8WyIaVw/gFs3BXFNBQFJMmjul+x7fgs=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ cairo ];

  postInstall = ''
    mv $out/bin/{cli,mapillary-render-cli}
    mv $out/bin/{server,mapillary-render-server}
  '';

  meta = {
    description = "Mapillary render";
    homepage = "https://github.com/wladich/mapillaryRender";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
