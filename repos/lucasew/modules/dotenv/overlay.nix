self: super:
rec {
  dotenv = super.callPackage ./package.nix {};
  wrapDotenv = file: script:
    let
        dotenvFile = builtins.toString (<dotfiles/secrets> + "/${file}");
      command = super.writeShellScript "dotenv-wrapper" script;
    in "${dotenv}/bin/dotenv @${dotenvFile} -- ${command} $*";
}
