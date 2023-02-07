{ config, pkgs, osConfig, ... }: {
  programs.git = {
    enable = true;
    difftastic = {
      enable = true;
      background = "dark";
      color = "auto";
    };
    lfs = {
      enable = true;
      skipSmudge = true;
    };
    userEmail = "jay@rovacsek.com";
    userName = "jayrovacsek";

    # TODO: make the below optional for settings in which we don't want to 
    # deploy git signing keys
    extraConfig = {
      commit.gpgsign = true;
      gpg = {
        format = "ssh";
        ssh.allowedSignersFile =
          config.home.file.".ssh/allowed_signers".source.outPath;
      };
      user.signingkey = osConfig.age.secrets."git-signing-key.pub".path;
    };
  };
}
