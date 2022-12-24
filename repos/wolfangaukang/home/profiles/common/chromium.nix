{ pkgs, ... }:

{
  programs.chromium = {
    enable = true;
    package = pkgs.brave;
    extensions = [
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
      "pkehgijcmpdhfbdbbnkijodmdjhbjlgp" # Privacy Badger
      "pmcmeagblkinmogikoikkdjiligflglb" # Privacy Redirect
      "gcbommkclmclpchllfjekcdonpmejbdp" # HTTPS Everywhere
      "hjdoplcnndgiblooccencgcggcoihigg" # Terms of Service; Didn’t Read
    ];
  };
}
