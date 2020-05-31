{ pkgs ? import <nixpkgs> {} }:
let scope = pkgs.lib.makeScope pkgs.newScope (self: rec {
  perlPackages          = self.callPackage ./pkgs/perl-packages.nix	{
     inherit (pkgs) perlPackages; 
  } // pkgs.perlPackages // {
    recurseForDerivations = false;
  };
  inherit (perlPackages) AIMicroStructure AICategorizer AlgorithmBaumWelch
  	ContextualReturn CouchDBClient HTMLSimpleLinkExtor LinguaStopWords
	MathCephes MathMatrixReal MooseXTypesSignal NetAsyncWebSocket
	ParallelIterator Perl6Form Perl6Export SearchContextGraph
	StatisticsContingency StatisticsDistributionsAncova StatisticsMVA
	StatisticsMVABayesianDiscrimination StatisticsMVAHotellingTwoSample
	StorableCouchDB SysadmInstall; 
  portfolio-performance = self.callPackage ./portfolio-performance	{};
  realvnc               = self.callPackage ./realvnc 			{};
} ); 
in scope.packages scope
