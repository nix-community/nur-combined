{
  # Add your overlays here
  #
  # my-overlay = import ./my-overlay;
  pendingPR = self: super:
  { 
  };

  fonts = self: super:
  {
    century-gothic = super.callPackage ../pkgs/century-gothic { };
    trace-font = super.callPackage ../pkgs/data/fonts/trace { };
  };
}

