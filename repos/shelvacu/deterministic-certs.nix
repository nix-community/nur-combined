{
  nixpkgs ? import <nixpkgs>,
}:
let
  pkgs = nixpkgs;
  lib = nixpkgs.lib;
  defaultCertTemplate = {
    serial = 1;
    activation_date = "1970-01-01 00:00:00 UTC";
    expiration_date = "2500-01-01 00:00:00 UTC";
  };
  keyValToConfigLines = (
    key: value:
    if (builtins.isString value) || (builtins.isPath value) then
      ''${key} = "${value}"''
    else if builtins.isInt value then
      "${key} = ${builtins.toString value}"
    else if builtins.isList value then
      map (innerValue: keyValToConfigLines key innerValue)
    else if builtins.isBool value then
      (if value then "${key}" else "# no ${key}")
    else
      throw "don't know how to handle ${builtins.typeOf value}"
  );
  mkTemplateConfig =
    config:
    lib.concatStringsSep "\n" (
      lib.lists.flatten (lib.attrsets.mapAttrsToList keyValToConfigLines config)
    );
  privKeyFile =
    name:
    let
      keySizeBits = 256;
      keySizeHex = builtins.toString (keySizeBits / 4);
    in
    pkgs.runCommand "deterministic-privkey-${name}.pem" { } ''
      seed=$(printf '%s' ${lib.escapeShellArg (builtins.toJSON name)} | ${pkgs.ruby}/bin/ruby -rjson -e 'name = JSON.parse(STDIN.gets); print name.unpack("H*")[0].ljust(${keySizeHex}, "0")')
      ${pkgs.gnutls}/bin/certtool --generate-privkey --outfile="$out" --key-type=rsa --sec-param=high --seed=$seed
    '';
  generateCert =
    {
      name,
      config,
      args,
      preCommands ? "",
    }:
    let
      deriv = pkgs.runCommand "deterministic-cert-${name}" { } ''
        mkdir -p "$out"
        cd "$out"
        ln -s ${privKeyFile name} privkey.pem
        ln -s ${
          pkgs.writeText "${name}-template.cfg" (mkTemplateConfig (defaultCertTemplate // config))
        } template.cfg
        ${preCommands}
        ${pkgs.gnutls}/bin/certtool ${lib.escapeShellArgs args} --load-privkey=privkey.pem --outfile=cert.pem --template=template.cfg
      '';
    in
    deriv
    // {
      privateKeyPath = "${deriv}/privkey.pem";
      certificatePath = "${deriv}/cert.pem";
    };

in
{
  inherit privKeyFile;
  selfSigned =
    name: config:
    generateCert {
      inherit name config;
      args = [ "--generate-self-signed" ];
    };
  caSigned =
    name: ca: config:
    generateCert {
      inherit name config;
      preCommands = ''
        ln -s ${ca.privateKeyPath} ca-privkey.pem
        ln -s ${ca.certificatePath} ca-cert.pem
      '';
      args = [
        "--generate-certificate"
        "--load-ca-certificate=ca-cert.pem"
        "--load-ca-privkey=ca-privkey.pem"
      ];
    };
}
