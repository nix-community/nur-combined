{ stdenv, fetchurl, perlPackages, parallel, buildPerlPackage, couchdb, wordnet, poppler_utils, tesseract }:
with perlPackages; 
rec {
  inherit perl;

  AIMicroStructure =
    let 
      external = [ couchdb wordnet poppler_utils tesseract ];
    in buildPerlPackage rec {
    pname = "AI-MicroStructure";
    version = "0.20";
    src = fetchurl {
      url = "mirror://cpan/authors/id/S/SA/SANTEX/${pname}-${version}.tar.gz";
      sha256 = "bb9d056fdddddb669fa501ae7325f709175ef565b5e592fe0b51ca608b6fd05e";
    };
    buildInputs = [ ModuleBuild ] ++ external;
    propagatedBuildInputs = [ AICategorizer AlgorithmBaumWelch AnyEventSubprocess CacheMemcachedFast ClassContainer ConfigAuto DataPrinter DigestSHA1 FileHomeDir HTMLSimpleLinkExtor HTMLStrip HTTPMessage IOAsync JSON JSONXS LWP LinguaStopWords Mojolicious NetAsyncWebSocket ParallelIterator ParamsValidate SearchContextGraph StatisticsBasic StatisticsContingency StatisticsDescriptive StatisticsDistributionsAncova StatisticsMVABayesianDiscrimination StatisticsMVAHotellingTwoSample StorableCouchDB SysadmInstall  ];
    meta = {
      homepage = http://active-memory.de:2323;
      description = "AI::MicroStructure   Creates Concepts for words";
      license = with stdenv.lib.licenses; [ artistic1 gpl1Plus ];
    };
    prePatch = "
      rm t/t/007.t
      rm t/t/0010.t
      rm t/t/0011.t
    ";
  };

  AICategorizer = buildPerlPackage rec {
    pname = "AI-Categorizer";
    version = "0.09";
    src = fetchurl {
      url = "mirror://cpan/authors/id/K/KW/KWILLIAMS/${pname}-${version}.tar.gz";
      sha256 = "24d8adec512e7be76e99c224b60205a164a14d8889557b6876c9b6e8ef8f8590";
    };
    buildInputs = [ ModuleBuild ];
    propagatedBuildInputs = [ ClassContainer LinguaStem ParamsValidate StatisticsContingency ];
    meta = {
      description = "Automatic Text Categorization";
      license = with stdenv.lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  AlgorithmBaumWelch = buildPerlPackage rec {
    pname = "Algorithm-BaumWelch";
    version = "v0.0.2";
    src = fetchurl {
      url = "mirror://cpan/authors/id/D/DS/DSTH/${pname}-${version}.tar.gz";
      sha256 = "78c22a2b93f13017d797f6f6858eb2f5c54c42ffed8741426299aa4d1157dbb9";
    };
    buildInputs = [ ModuleBuild ];
    propagatedBuildInputs = [ MathCephes TextSimpleTable ];
    meta = {
      description = "Baum-Welch Algorithm for Hidden Markov Chain parameter estimation";
      license = with stdenv.lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  AnyEventSubprocess = buildPerlPackage rec {
    pname = "AnyEvent-Subprocess";
    version = "1.102912";
    src = fetchurl {
      url = "mirror://cpan/authors/id/J/JR/JROCKWAY/${pname}-${version}.tar.gz";
      sha256 = "a14490710b093644333bdbf7477f4ae58f3bf4553a554bdcde7936ca4c7e53f5";
    };
    buildInputs = [ TestException TestSimple ];
    propagatedBuildInputs = [ AnyEvent EV EventJoin IOTty JSON Moose MooseXClone MooseXRoleParameterized MooseXStrictConstructor MooseXTypes MooseXTypesSignal SubExporter TryTiny namespaceautoclean namespaceclean ];
    meta = {
      description = "Flexible, OO, asynchronous process spawning and management";
      license = with stdenv.lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  ConfigAuto = buildPerlPackage rec {
    pname = "Config-Auto";
    version = "0.44";
    src = fetchurl {
      url = "mirror://cpan/authors/id/B/BI/BINGOS/${pname}-${version}.tar.gz";
      sha256 = "e960e04df995852aba275cf83ac6f947e44a4139de156858c01f0cec7f7ab53f";
    };
    propagatedBuildInputs = [ ConfigIniFiles IOString YAML ];
    meta = {
      description = "Magical config file parser";
      license = with stdenv.lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  ContextualReturn = buildPerlPackage rec {
    pname = "Contextual-Return";
    version = "0.004014";
    src = fetchurl {
      url = "mirror://cpan/authors/id/D/DC/DCONWAY/${pname}-${version}.tar.gz";
      sha256 = "09fe1415e16e49a69e13c0ef6e6a4a3fd8b856f389d3f3e624d7ab3b71719f78";
    };
    propagatedBuildInputs = [ Want ];
    meta = {
      description = "Create context-sensitive return values";
      license = with stdenv.lib.licenses; [ artistic1 gpl1Plus ];
    };
  };
 
  CouchDBClient = buildPerlPackage rec {
    pname = "CouchDB-Client";
    version = "0.09";
    src = fetchurl {
      url = "mirror://cpan/authors/id/M/MA/MAVERICK/${pname}-${version}.tar.gz";
      sha256 = "3485ed32ff5906690415c27dd9d1fea2ef7f2967659ae9f254bd7ced602ef322";
    };
    propagatedBuildInputs = [ HTTPMessage JSONAny LWP URI ];
    buildInputs = [ JSON ];
    meta = {
      homepage = http://github.com/maverick/couchdb-client;
      description = "Simple, correct client for CouchDB";
      license = with stdenv.lib.licenses; [ artistic1 gpl1Plus ];
    };
    prePatch = ''
      rm t/00-load.t
      rm t/12-small-things.t
      rm t/15-client.t
    '';
  };
  
  EventJoin = buildPerlPackage rec {
    pname = "Event-Join";
    version = "0.06";
    src = fetchurl {
      url = "mirror://cpan/authors/id/J/JR/JROCKWAY/${pname}-${version}.tar.gz";
      sha256 = "a8202215d11c20a7906286bd8d2337d3f0b5ae6b41370d2ba00b9b8d15b8ff3c";
    };
    buildInputs = [ TestException TestSimple ];
    propagatedBuildInputs = [ Moose ];
    meta = {
      description = "Join multiple "events" into one";
      license = with stdenv.lib.licenses; [ artistic1 gpl1Plus ];
    };
  };
  
  
  HTMLSimpleLinkExtor = buildPerlPackage rec {
    pname = "HTML-SimpleLinkExtor";
    version = "1.272";
    src = fetchurl {
      url = "mirror://cpan/authors/id/B/BD/BDFOY/${pname}-${version}.tar.gz";
      sha256 = "502cf53992edaa0e164d7d3bdb37a745891e7225f79dfaf17a92c635ff4598c7";
    };
    buildInputs = [ TestOutput ];
    propagatedBuildInputs = [ HTMLParser LWP URI ];
    meta = {
      homepage = https://github.com/CPAN-Adoptable-Modules/html-simplelinkextor;
      description = "Extract links from HTML";
      license = stdenv.lib.licenses.artistic2;
    };
  };
  HTMLStrip = buildPerlPackage rec {
    pname = "HTML-Strip";
    version = "2.10";
    src = fetchurl {
      url = "mirror://cpan/authors/id/K/KI/KILINRAX/${pname}-${version}.tar.gz";
      sha256 = "2af30a61f1ecc0bea983043c8078e48380ccb0319388a74483e09aa782f1ccfa";
    };
    propagatedBuildInputs = [ TestException ];
    meta = {
      description = "Perl extension for stripping HTML markup from text";
      license = with stdenv.lib.licenses; [ artistic1 gpl1Plus ];
    };
  };
  
  LinguaStopWords = buildPerlPackage rec {
    pname = "Lingua-StopWords";
    version = "0.09";
    src = fetchurl {
      url = "mirror://cpan/authors/id/C/CR/CREAMYG/${pname}-${version}.tar.gz";
      sha256 = "c8734359b82a0838e440bd4739c6c75d7f362ac38d82b1429ee2d41eafcc6d35";
    };
    meta = {
      description = "Stop words for several languages";
    };
  };
  
  MathCephes = buildPerlPackage rec {
    pname = "Math-Cephes";
    version = "0.5305";
    src = fetchurl {
      url = "mirror://cpan/authors/id/S/SH/SHLOMIF/${pname}-${version}.tar.gz";
      sha256 = "561a800a4822e748d2befc366baa4b21e879a40cc00c22293c7b8736caeb83a1";
    };
    meta = {
      description = "Perl interface to the math cephes library";
      license = with stdenv.lib.licenses; [ artistic1 gpl1Plus ];
    };
  };
  
  MathMatrixReal = buildPerlPackage rec {
    pname = "Math-MatrixReal";       
    version = "2.13";
    src = fetchurl {
      url = "mirror://cpan/authors/id/L/LE/LETO/${pname}-${version}.tar.gz";
      sha256 = "4f9fa1a46dd34d2225de461d9a4ed86932cdd821c121fa501a15a6d4302fb4b2";
    };
    buildInputs = [ ModuleBuild TestMost TestException TestDifferences TestWarn TestDeep ];
    meta = {
      description = "Manipulate NxN matrices of real numbers";
      license = with stdenv.lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  
  MooseXTypesSignal = buildPerlPackage rec {
    pname = "MooseX-Types-Signal";
    version = "1.101932";
    src = fetchurl {
      url = "mirror://cpan/authors/id/J/JR/JROCKWAY/${pname}-${version}.tar.gz";
      sha256 = "ab0e3714a8876b56429108f761833b3a5da1c73c045d598b34eeb5fd8cf4c3ec";
    };
    buildInputs = [ Moose TestException ];
    propagatedBuildInputs = [ MooseXTypes ];
    meta = {
      description = "A type to represent valid UNIX or Perl signals";
      license = with stdenv.lib.licenses; [ artistic1 gpl1Plus ];
    };
  };
  
  NetAsyncWebSocket = buildPerlModule rec {
    pname = "Net-Async-WebSocket";
    version = "0.13";
    src = fetchurl {
      url = "mirror://cpan/authors/id/P/PE/PEVANS/${pname}-${version}.tar.gz";
      sha256 = "0dac8342d3c78a2feccabd4667145dd5add4fb8cd18d156d297a1e69dfe11600";
    };
    buildInputs = [ ModuleBuild ];
    propagatedBuildInputs = [ IOAsync ProtocolWebSocket URI ];
    meta = {
      description = "Use WebSockets with C<IO::Async>";
      license = with stdenv.lib.licenses; [ artistic1 gpl1Plus ];
    };
  };
  
  ParallelIterator = buildPerlPackage rec {
    pname = "Parallel-Iterator";
    version = "1.00";
    src = fetchurl {
      url = "mirror://cpan/authors/id/A/AN/ANDYA/${pname}-${version}.tar.gz";
      sha256 = "e8495095cf5746a14e154037b11b0d911da2a32283b77291abb37bf6311345f4";
    };
    meta = {
      description = "Simple parallel execution";
      license = with stdenv.lib.licenses; [ artistic1 gpl1Plus ];
    };
  };
  
  
  Perl6Form = buildPerlPackage rec {
    pname = "Perl6-Form";
    version = "0.090";
    src = fetchurl {
      url = "mirror://cpan/authors/id/D/DC/DCONWAY/${pname}-${version}.tar.gz";
      sha256 = "c60a3433aa70853008e49068f80cc33656e774221c1de568736bdfb567b01c74";
    };
    propagatedBuildInputs = [ Perl6Export ];
    meta = {
      description = "Implements the Perl 6 'form' built-in";
    };
  };

  Perl6Export = buildPerlPackage rec {
    pname = "Perl6-Export";
    version = "0.07";
    src = fetchurl {
      url = "mirror://cpan/authors/id/D/DC/DCONWAY/${pname}-${version}.tar.gz";
      sha256 = "88ed486cf0d468ffa98fc533df4cb54dd749b89a8a07841756b9f4059d5f7c10";
    };
    meta = {
    };
  };
  SearchContextGraph = buildPerlPackage rec {
    pname = "Search-ContextGraph";
    version = "0.15";
    src = fetchurl {
      url = "mirror://cpan/authors/id/M/MC/MCEGLOWS/${pname}-${version}.tar.gz";
      sha256 = "d90c107cbffb8b8ce7a770d3b97314ddc7adbf81125ad7f697580d19b2e9f418";
    };
    propagatedBuildInputs = [ MLDBM DBFile ];
    prePatch = "
      rm t/invariance.t
    ";
  };
 
  StatisticsContingency = buildPerlPackage rec {
    pname = "Statistics-Contingency";
    version = "0.09";
    src = fetchurl {
      url = "mirror://cpan/authors/id/K/KW/KWILLIAMS/${pname}-${version}.tar.gz";
      sha256 = "4b50621c4974937564ce76b523e9073db50e67de6f5bfae92f088b3ae22975bf";
    };
    buildInputs = [ ModuleBuild ];
    propagatedBuildInputs = [ ParamsValidate ];
    meta = {
      description = "Calculate precision, recall, F1, accuracy, etc";
      license = with stdenv.lib.licenses; [ artistic1 gpl1Plus ];
    };
  };
  
  StatisticsDistributionsAncova = buildPerlPackage rec {
    pname = "Statistics-Distributions-Ancova";
    version = "0.32.2";
    src = fetchurl {
      url = "mirror://cpan/authors/id/D/DS/DSTH/${pname}-${version}.tar.gz";
      sha256 = "8263fd394e46e724691c8e2d043c19c96f1c12c868ea882e810345435365bca3";
    };
    propagatedBuildInputs = [ MathCephes ContextualReturn Perl6Form StatisticsDistributions ];
  };
  
  StatisticsMVA = buildPerlPackage {
    pname = "Statistics-MVA";
    version = "0.0.2";
    src = fetchurl {
      url = mirror://cpan/authors/id/D/DS/DSTH/Statistics-MVA-0.0.2.tar.gz;
      sha256 = "8e61dd269b2317c8246b7a74913d5afbb6edb186eadf20e42ce9c1ba4b8ab5d8";
    };
    propagatedBuildInputs = [ MathMatrixReal ];
  };
  
    StatisticsMVABayesianDiscrimination = buildPerlPackage rec {
    pname = "Statistics-MVA-BayesianDiscrimination";
    version = "0.0.2";
    src = fetchurl {
      url = "mirror://cpan/authors/id/D/DS/DSTH/${pname}-${version}.tar.gz";
      sha256 = "c0d60c5f055613973cc40e95a75dc9a886cbd51e8277d0fad7ee10158f48349b";
    };
    propagatedBuildInputs = [ MathCephes StatisticsMVA TextSimpleTable ];
    meta = {
      description = "Two-Sample Linear Discrimination Analysis with Posterior Probability Calculation";
    };
  };
  
    StatisticsMVAHotellingTwoSample = buildPerlPackage rec {
    pname = "Statistics-MVA-HotellingTwoSample";
    version = "0.0.2";
    src = fetchurl {
      url = "mirror://cpan/authors/id/D/DS/DSTH/${pname}-${version}.tar.gz";
      sha256 = "ba648be7268ab18723a27079c5a6f7367aec04b6991b24d239c5733c96d4cea9";
    };
    propagatedBuildInputs = [ MathCephes StatisticsDistributions ];
  };
  
  StorableCouchDB = buildPerlPackage rec {
    pname = "Storable-CouchDB";
    version = "0.04";
    src = fetchurl {
      url = "mirror://cpan/authors/id/M/MR/MRDVT/${pname}-${version}.tar.gz";
      sha256 = "43b15c33e462a77d180da3bb80f1a3cf0bbf6951cba61d732d831623592d111a";
    };
    propagatedBuildInputs = [ JSONAny CouchDBClient ];
    buildInputs = [ JSON ];
    meta = {
      description = "Persistences for Perl data structures in Apache CouchDB";
    };
    doCheck = false;                             # FIXME: JSON miss
  };
  
  SysadmInstall = buildPerlPackage rec {
    pname = "Sysadm-Install";
    version = "0.48";
    src = fetchurl {
      url = "mirror://cpan/authors/id/M/MS/MSCHILLI/${pname}-${version}.tar.gz";
      sha256 = "ffdf1c4291dae94650a728e251beba8e6fcd2e5c697bcde0d791b5fb9c6b8c99";
    };
    propagatedBuildInputs = [ FileWhich LWP LogLog4perl TermReadKey ];
    meta = {
      description = "Typical installation tasks for system administrators";
    };
  };
 ### XXX Problem to use nixos repo
   IOAsync = buildPerlModule {
    pname = "IO-Async";
    version = "0.75";
    src = fetchurl {
      url = mirror://cpan/authors/id/P/PE/PEVANS/IO-Async-0.75.tar.gz;
      sha256 = "1mi6gfbl11rimvzgzyj8kiqf131cg1w9nwxi47fwm9sbs0x6rkjb";
    };
    propagatedBuildInputs = [ Future StructDumb ];
    buildInputs = [ TestFatal TestIdentity TestRefcount ];
    meta = {
      description = "Asynchronous event-driven programming";
      license = with stdenv.lib.licenses; [ artistic1 gpl1Plus ];
    };
  };
  TestIdentity = buildPerlModule {
    pname = "Test-Identity";
    version = "0.01";
    src = fetchurl {
      url = mirror://cpan/authors/id/P/PE/PEVANS/Test-Identity-0.01.tar.gz;
      sha256 = "08szivpqfwxnf6cfh0f0rfs4f7xbaxis3bra31l2c5gdk800a0ig";
    };
    meta = {
      description = "assert the referential identity of a reference";
      license = with stdenv.lib.licenses; [ artistic1 gpl1Plus ];
    };
  };
  TestRefcount = buildPerlModule {
    pname = "Test-Refcount";
    version = "0.10";
    src = fetchurl {
      url = mirror://cpan/authors/id/P/PE/PEVANS/Test-Refcount-0.10.tar.gz;
      sha256 = "1chf6zizi7x128l3qm1bdqzwjjqm2j4gzajgghaksisn945c4mq4";
    };
    meta = {
      description = "assert reference counts on objects";
      license = with stdenv.lib.licenses; [ artistic1 gpl1Plus ];
    };
  };
  Future = buildPerlModule {
    pname = "Future";
    version = "0.43";
    src = fetchurl {
      url = mirror://cpan/authors/id/P/PE/PEVANS/Future-0.43.tar.gz;
      sha256 = "191qvn3jz5pk5zxykwsg1i17s45kc82rfd6kgzsv9nki1c04dzaf";
    };
    buildInputs = [ TestFatal TestIdentity TestRefcount ];
    meta = {
      description = "represent an operation awaiting completion";
      license = with stdenv.lib.licenses; [ artistic1 gpl1Plus ];
    };
  };


}
