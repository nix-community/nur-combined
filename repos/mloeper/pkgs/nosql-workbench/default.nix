{ stdenv
, fetchurl
, lib
, appimageTools
}:
appimageTools.wrapType2
{
  name = "nosql-workbench";
  version = "3.11.0";

  src = fetchurl {
    url = "https://dy9cqqaswpltd.cloudfront.net/NoSQL_Workbench.AppImage";
    sha256 = "sha256-cDOSbhAEFBHvAluxTxqVpva1GJSlFhiozzRfuM4MK5c=";
  };

  meta = with lib; {
    homepage = "https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/workbench.html";
    description = "A cross-platform, client-side GUI application for working with DynamoDB.";
    platforms = [ "x86_64-linux" ];
    mainProgram = "NoSQL_Workbench.AppImage";
  };
}
