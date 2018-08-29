self: super: {

  inherit (import ../. { pkgs = self; }).skhd;

}
