{ stdenvNoCC, writeScript, fetchFromGitHub, perl }:

stdenvNoCC.mkDerivation {
  name = "urxvt-osc-52";
  dontPatchShebangs = true;

  # https://github.com/parantapa/dotfiles/blob/master/urxvt-perl/52-osc
  # #! ${perl}/bin/perl
  # #! perl
  src = writeScript "osc52.pl" ''
    #! ${perl}/bin/perl

    =head1 NAME

    52-osc - Implement OSC 32 ; Interact with X11 clipboard

    =head1 SYNOPSIS

    urxvt -pe 52-osc

    =head1 DESCRIPTION

    This extension implements OSC 52 for interacting with system clipboard

    Most code stolen from:
    http://ailin.tucana.uberspace.de/static/nei/*/Code/urxvt/

    =cut

    use MIME::Base64;
    use Encode;

    sub on_osc_seq {
      my ($term, $op, $args) = @_;
      return () unless $op eq 52;

      my ($clip, $data) = split ';', $args, 2;
      if ($data eq '?') {
        my $data_free = $term->selection();
        Encode::_utf8_off($data_free); # XXX
        $term->tt_write("\e]52;$clip;".encode_base64($data_free, "")."\a");
      }
      else {
        my $data_decoded = decode_base64($data);
        Encode::_utf8_on($data_decoded); # XXX
        $term->selection($data_decoded, $clip =~ /c/);
        $term->selection_grab(urxvt::CurrentTime, $clip =~ /c/);
      }

       ()
    }
  '';

  unpackPhase = "true";
  installPhase = ''
    install -Dm 0755 $src $out/lib/urxvt/perl/osc-52
  '';
}
