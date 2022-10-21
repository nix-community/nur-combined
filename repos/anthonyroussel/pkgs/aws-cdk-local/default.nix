{ pkgs, stdenv, lib, makeWrapper }:

let
  myNodePackages = import ./node-composition.nix {
    inherit pkgs;
    inherit (stdenv.hostPlatform) system;
  };

in myNodePackages.aws-cdk-local.override {
  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    wrapProgram "$out/bin/cdklocal" \
      --prefix NODE_PATH : ${pkgs.nodePackages.aws-cdk}/lib/node_modules
  '';

  meta = with lib; {
    description = "CDK Toolkit for use with LocalStack";
    license = licenses.asl20;
    homepage = "https://github.com/localstack/aws-cdk-local";
    maintainers = with maintainers; [ anthonyroussel ];
    platforms = platforms.unix;
  };
}
