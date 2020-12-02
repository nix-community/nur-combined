{ stdenv, lib, pkgs, makeWrapper, nodejs, xcodebuild }:
let
  nodePackages = import ./node-composition.nix {
    inherit pkgs nodejs;
    inherit (stdenv.hostPlatform) system;
  };
in
nodePackages.matrix-appservice-irc.override {
  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ nodePackages.node-gyp-build ]
    ++ lib.optional stdenv.isDarwin xcodebuild;

  postInstall = ''
    makeWrapper '${nodejs}/bin/node' "$out/bin/matrix-appservice-irc" \
      --add-flags "$out/lib/node_modules/matrix-appservice-irc/app.js"
  '';

  meta = with lib; {
    description = "Node.js IRC bridge for Matrix";
    homepage = "https://github.com/matrix-org/matrix-appservice-irc";
    license = licenses.asl20;
    maintainers = with maintainers; [ AluisioASG ];
    platforms = platforms.all;
  };
}
