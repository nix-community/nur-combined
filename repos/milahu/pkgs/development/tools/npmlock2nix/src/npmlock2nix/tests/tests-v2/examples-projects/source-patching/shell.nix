{ npmlock2nix }:
npmlock2nix.v2.shell {
  src = ./.;
  node_modules_attrs = {
    sourceOverrides = {
      custom-hello-world = sourceInfo: drv: drv.overrideAttrs (old: {
        patches = builtins.toFile "custom-hello-world.patch" ''
          diff --git a/lib/index.js b/lib/index.js
          index 1f66513..64391a7 100644
          --- a/lib/index.js
          +++ b/lib/index.js
          @@ -21,7 +21,7 @@ function generateHelloWorld({ comma, exclamation, lowercase }) {
             if (comma)
               helloWorldStr += ',';
             
          -  helloWorldStr += ' World';
          +  helloWorldStr += ' Nix';
           
             if (exclamation)
               helloWorldStr += '!';
        '';
      });
    };
  };
}
