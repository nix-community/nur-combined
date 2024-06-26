{ pkgs
, ...
}:

let
  inherit (pkgs.python3Packages) python-lsp-server;

in {
  # Will avoid using a keyring
  #env.PYTHON_KEYRING_BACKEND = "keyring.backends.null.Keyring";

  # https://devenv.sh/packages/
  packages = [
    python-lsp-server
  ];

  languages = {
    python = {
      enable = true;
      poetry = {
        enable = true;
        #activate.enable = true;
      };
    };
    nix.enable = true;
  };
}
