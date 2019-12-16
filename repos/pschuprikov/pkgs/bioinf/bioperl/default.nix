{ stdenv, fetchurl, perlPackages, DataStag, XMLDOMXPath, TestWeaken }:
with perlPackages;
buildPerlPackage rec {
  pname = "BioPerl";
  version = "1.7.7";
  src = fetchurl {
    url = "mirror://cpan/authors/id/C/CJ/CJFIELDS/${pname}-${version}.tar.gz";
    sha256 = "730e2bd38b7550bf6bbd5bca50d019a70cca514559702c1389d770ff69cff1bb";
  };
  buildInputs = [ TestMemoryCycle TestWeaken TestWarn TestDeep 
    TestDifferences TestException ];
  propagatedBuildInputs = [ DBFile DataStag Error Graph HTTPMessage IOString 
    IOStringy IPCRun LWP ListMoreUtils ModuleBuild SetScalar TestMost 
    TestRequiresInternet URI XMLDOM XMLDOMXPath XMLLibXML XMLSAX XMLSAXBase 
    XMLSAXWriter XMLTwig XMLWriter YAML libxml_perl ];
  meta = {
    homepage = https://metacpan.org/release/BioPerl;
    description = "Perl modules for biology";
    license = with stdenv.lib.licenses; [ artistic1 gpl1Plus ];
  };
}
