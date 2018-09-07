self: super:

{
  sudo = super.sudo.override {
    withInsults = true;
  };
}
