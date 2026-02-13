{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule (finalAttrs: {
  pname = "hugomods-fuse-js";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "hugomods";
    repo = "fuse-js";
    rev = "v${finalAttrs.version}";
    hash = "sha256-tyHO48tzm87IHHgynxkydPOPjEn8EgVI8uO44JkoFkk=";
  };

  vendorHash = "sha256-662NC1KMMHnCxwUxBCYsjC0+wQyiAXCEJ+wRZYlNbxE=";

  ldflags = [ "-s" "-w" ];
  
  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/hugomods/fuse-js
    cp -r . $out/share/hugomods/fuse-js

    runHook postInstall
  '';

  meta = {
    description = "Mag: Hugo Fuse.js Module";
    homepage = "https://github.com/hugomods/fuse-js.git";
    maintainers =
      let m = lib.maintainers or {};
      in lib.optionals (m ? szanko) [ m.szanko ];
    license = lib.licenses.mit;
    #mainProgram = "hugomods-fuse-js";
  };
})
