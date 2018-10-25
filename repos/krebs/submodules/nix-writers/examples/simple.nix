let
  pkgs = import <nixpkgs> { overlays = [ (import ../pkgs) ]; };
in {
  bash = pkgs.writeBash "simple.sh" ''
   if [[ "test" == "test" ]]; then echo "bash features"; fi
  '';
  # cc -L/nix/store/...blah/lib -I/nix/store/...blah/include
  dash = pkgs.writeDash "simple" ''
   test '~' = '~' && echo 'dash features'
  '';
  haskell = pkgs.writeHaskell "simple" [ "acme-cuteboy" ] ''
    import Acme.CuteBoy

    main :: IO ()
    main = print Rolf
  '';
  js = pkgs.writeJS "example-js" { deps = [ pkgs.nodePackages.uglify-js ]; } ''
    var UglifyJS = require("uglify-js");
    var code = "function add(first, second) { return first + second; }";
    var result = UglifyJS.minify(code);
    console.log(result.code);
  '';
  perl = pkgs.writePerl "simple.pl" { deps = [ pkgs.perlPackages.boolean ]; } ''
    use boolean;
    print "Howdy!\n" if true;
  '';
  python2 = pkgs.writePython2 "simple.py" { deps = [ pkgs.python2Packages.pyyaml ]; } ''
    import yaml

    print yaml.load("""
      - some
      - random
      - variables
    """)
  '';
  python3 = pkgs.writePython3 "simple.py" { deps = [ pkgs.python3Packages.pyyaml ]; } ''
    import yaml

    print(yaml.load("""
      - some
      - random
      - variables
    """))
  '';
  sed = pkgs.writeDash "sed-example" ''
    echo hello | ${pkgs.writeSed "hello-world" "s/hello/& world/"}
  '';
}
