{ lib
, _common

, buildGoModule
, buildNpmPackage

, font-awesome
, nodejs

, ots-cli
}:
buildGoModule rec {
  pname = "ots";
  inherit (_common) version src;

  frontend = buildNpmPackage {
    pname = "${pname}-frontend";
    inherit version src;

    npmDepsHash = "sha256-YecKxMy6Jtz+wZ5TBRzGVC+ekLn7wU3cf4EeELgyYWE=";

    inherit nodejs;

    buildPhase = ''
      node ci/build.mjs
    '';

    installPhase = ''
      cp -Tr frontend $out
    '';
  };

  vendorHash = "sha256-IA6d+LP3kImwkQV3cUsUuVcGbdq6lWlvS8Jrb8cR1ZQ=";

  ldflags = [
    "-X main.version=${version}"
  ];
  subPackages = [ "." ];

  preBuild = ''
    rm -rf frontend
    cp -Tr ${frontend} frontend
    chmod +w frontend

    for d in css js webfonts; do
      cp -Tr ${font-awesome.src}/$d frontend/$d
    done
  '';

  passthru = {
    cli = ots-cli;
  };

  meta = with lib; {
    homepage = "https://ots.fyi";
    description = "One-Time-Secret sharing platform with a symmetric 256bit AES encryption in the browser";
    license = licenses.asl20;
    mainProgram = "ots";
  };
}
