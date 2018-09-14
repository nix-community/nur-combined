{ lib, checkoutNixpkgs }:

lib.runTests {

  testNixpkgsCheckout = {
    expr = lib.fileContents "${((checkoutNixpkgs { channel = "18.09"; }).invoke {}).path}/.version";
    expected = "18.09";
  };

  testCheckoutWithOverlays = {
    expr = "1";
    expected = let overlays = [ (self: super: { testValue = "1"; }) ];
               in (((checkoutNixpkgs { channel = "18.09"; inherit overlays; }).invoke {}).testValue);
  };

}
