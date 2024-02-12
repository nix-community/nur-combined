{ pkgs, ... }: {
  programs = {
    password-store = {
      enable = true;
      package =
        pkgs.pass-wayland.withExtensions (p: with p; [ pass-otp pass-import ]);
    };
    git.extraConfig.credential.helper =
      [ "!${pkgs.pass-git-helper}/bin/pass-git-helper $@" ];
  };
}
