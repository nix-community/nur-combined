import '../helper.dart';

// ignore_for_file: public_member_api_docs

final Transforms rfcTransforms = Transforms(121, 167, 50)
  ..unpack(
    "# #s #, #e #.# the #.com/#\u00C2\u00A0# of # and # in # to #\"#\">#\n#]# for # a # that #. # with #'# from # by #. The # on # as # is #ing #\n\t#:#ed #(# at #ly #=\"# of the #. This #,# not #er #al #='#ful #ive #less #est #ize #ous #",
    "     !! ! ,  *!  &!  \" !  ) *   * -  ! # !  #!*!  +  ,\$ !  -  %  .  / #   0  1 .  \"   2  3!*   4%  ! # /   5  6  7  8 0  1 &   \$   9 +   :  ;  < '  !=  >  ?! 4  @ 4  2  &   A *# (   B  C& ) %  ) !*# *-% A +! *.  D! %'  & E *6  F  G% ! *A *%  H! D  I!+!  J!+   K +- *4! A  L!*4  M  N +6  O!*% +.! K *G  P +%(  ! G *D +D  Q +# *K!*G!+D!+# +G +A +4!+% +K!+4!*D!+K!*K",
  );

class Transforms {
  final int numTransforms;
  final List<int> triplets;
  final List<int> params;
  final List<int> prefixSuffixStorage;
  final List<int> prefixSuffixHeads;

  Transforms(this.numTransforms, int prefixSuffixLen, int prefixSuffixCount)
      : triplets = createInt32List(numTransforms * 3),
        params = createInt16List(numTransforms),
        prefixSuffixStorage = createInt8List(prefixSuffixLen),
        prefixSuffixHeads = createInt32List(prefixSuffixCount + 1);

  void unpack(
    String prefixSuffixSrc,
    String transformsSrc,
  ) {
    final n = prefixSuffixSrc.length;
    var index = 1;
    var j = 0;

    for (var i = 0; i < n; ++i) {
      final c = prefixSuffixSrc.codeUnitAt(i);

      if (c == 35) {
        prefixSuffixHeads[index++] = j;
      } else {
        prefixSuffixStorage[j++] = c;
      }
    }

    for (var i = 0; i < 363; ++i) {
      triplets[i] = transformsSrc.codeUnitAt(i) - 32;
    }
  }
}
