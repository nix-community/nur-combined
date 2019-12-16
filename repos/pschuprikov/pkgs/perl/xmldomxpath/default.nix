{ stdenv, fetchurl, perlPackages }:
with perlPackages;
buildPerlPackage rec {
  pname = "XML-DOM-XPath";
  version = "0.14";
  src = fetchurl {
    url = "mirror://cpan/authors/id/M/MI/MIROD/${pname}-${version}.tar.gz";
    sha256 = "0173a74a515211997a3117a47e7b9ea43594a04b865b69da5a71c0886fa829ea";
  };
  patchPhase = ''
    substituteInPlace t/test_non_ascii.t \
      --replace "use encoding 'utf8';" "use utf8;"
  '';
  propagatedBuildInputs = [ XMLDOM XMLXPathEngine ];
  meta = {
    description = "Perl extension to add XPath support to XML::DOM, using XML::XPath engine";
  };
}
