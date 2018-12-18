{ stdenv, fetchzip }:

# https://github.com/source-foundry/Hack/pull/427

fetchzip {
  name = "hack-font-4pre";
  url = https://github.com/source-foundry/Hack/files/2498307/build-3a85a7679.zip;

  postFetch = ''
    mkdir -p $out/share/fonts
    unzip -j $downloadedFile \*.ttf -d $out/share/fonts/hack
  '';

  sha256 = "05y4pmn9rrijymlx1csv4fnm8zal5b5ajaqjxny1m7p4daf47zv8";

  meta = with stdenv.lib; {
    description = "A typeface designed for source code";
    longDescription = ''
      Hack is hand groomed and optically balanced to be a workhorse face for
      code. It has deep roots in the libre, open source typeface community and
      expands upon the contributions of the Bitstream Vera & DejaVu projects.
      The face has been re-designed with a larger glyph set, modifications of
      the original glyph shapes, and meticulous attention to metrics.
    '';
    homepage = https://sourcefoundry.org/hack/;

    /*
     "The font binaries are released under a license that permits unlimited
      print, desktop, and web use for commercial and non-commercial
      applications. It may be embedded and distributed in documents and
      applications. The source is released in the widely supported UFO format
      and may be modified to derive new typeface branches. The full text of
      the license is available in LICENSE.md" (From the GitHub page)
    */
    license = licenses.free;
    maintainers = with maintainers; [ dtzWill ];
    platforms = platforms.all;
  };
}
