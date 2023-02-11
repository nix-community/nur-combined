self: super:
{
  vivaldi = super.vivaldi.override {
    commandLineArgs = "--force-dark-mode=enabled";
  };
}
