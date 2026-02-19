self: _prev:
{
  transmission_4 = self.callPackage ./transmission_4.nix {
    fmt = self.fmt_9;
    libutp = self.libutp_3_4;
  };
}
