{ ... }:
{
  sane.programs.passff-host = {
    sandbox.method = null;  #< TODO: enable sandboxing
    sandbox.extraHomePaths = [
      ".config/sops"
      "knowledge/secrets/accounts"
    ];

    # TODO: env.PASSWORD_STORE_DIR only needs to be present within the browser session.
    # alternative to PASSWORD_STORE_DIR:
    # fs.".password-store".symlink.target =  "knowledge/secrets/accounts";
    env.PASSWORD_STORE_DIR = "/home/colin/knowledge/secrets/accounts";
  };
}
