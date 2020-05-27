# To generate:
# nix run nixpkgs.nodePackages_13_x.node2nix -c node2nix -c package.nix --strip-optional-dependencies -13 -d -l

{ pkgs
, nodejs
}:

let
  results = import ./package.nix { inherit pkgs nodejs; };
  aurora = results.package;
in aurora.override (old: {
  src = pkgs.fetchFromGitHub {
    owner = "GRarer";
    repo = "Aurora";
    rev = "5156458df38b2c5620f18074dc145f03e51388b7";
    sha256 = "0fg0w5q9sl6li6d7avir0yky8jaqhq9nx27z2lbn7yi9ir1988jq";
  };

  nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.makeWrapper ];
  # Run the build and make a live-server wrapper
  postInstall = (old.postInstall or "") + ''
    cd "$out/lib/node_modules/aurora"
    ${pkgs.nodejs-13_x}/bin/npm run build
    cd -

    mkdir -p "$out/bin"
    makeWrapper \
      ${pkgs.nodePackages.live-server}/bin/live-server \
      "$out/bin/aurora" \
      --add-flags "$out/lib/node_modules/aurora"
  '';

  meta = with pkgs.stdenv.lib; {
    description = "Spring 2020 VGDev Game";
    homepage = "https://github.com/GRarer/Aurora";
    platforms = platforms.all;
    license = licenses.mit;
  };
})
