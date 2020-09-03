{ lib
, stdenv
, pkgs
}:



let 
  jar = pkgs.fetchurl {
    name = "burpsuite.jar";
    url = "https://portswigger.net/burp/releases/download?product=community&version=2020.8.1&type=Jar";
    sha256 = "13wk94az1a7rpvgw4vr6vm686zdcg5f6l2w4sj31p6iapiyvcfah";
  };
  launcher = ''
      #!${pkgs.runtimeShell}
      exec ${pkgs.jdk11}/bin/java -jar ${jar} "$@"
  '';
in
  pkgs.burpsuite.overrideAttrs (oldAttrs: { 
    version = "2020.8.1";
    buildCommand = ''
      mkdir -p $out/bin
      echo "${launcher}" > $out/bin/burpsuite
      chmod +x $out/bin/burpsuite
    '';
  })
