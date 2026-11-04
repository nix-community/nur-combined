import '../helper.dart';
import 'input_stream.dart';

// ignore_for_file: public_member_api_docs

class State {
  List<int> ringBuffer = createInt8List(0);
  List<int> contextModes = createInt8List(0);
  List<int> contextMap = createInt8List(0);
  List<int> distContextMap = createInt8List(0);
  List<int> distExtraBits = createInt8List(0);
  List<int> output = createInt8List(0);
  List<int> byteBuffer = createInt8List(0);
  List<int> intBuffer = createInt32List(0);
  List<int> rings = createInt32List(10);
  List<int> blockTrees = createInt32List(0);
  List<int> literalTreeGroup = createInt32List(0);
  List<int> commandTreeGroup = createInt32List(0);
  List<int> distanceTreeGroup = createInt32List(0);
  List<int> distOffset = createInt32List(0);

  int accumulator = 0;

  int runningState = 0;
  int nextRunningState = 0;
  int bitOffset = 0;
  int halfOffset = 0;
  int tailBytes = 0;
  int endOfStreamReached = 0;
  int metaBlockLength = 0;
  int inputEnd = 0;
  int isUncompressed = 0;
  int isMetadata = 0;
  int literalBlockLength = 0;
  int numLiteralBlockTypes = 0;
  int commandBlockLength = 0;
  int numCommandBlockTypes = 0;
  int distanceBlockLength = 0;
  int numDistanceBlockTypes = 0;
  int pos = 0;
  int maxDistance = 0;
  int distRbIdx = 0;
  int trivialLiteralContext = 0;
  int literalTreeIdx = 0;
  int commandTreeIdx = 0;
  int j = 0;
  int insertLength = 0;
  int contextMapSlice = 0;
  int distContextMapSlice = 0;
  int contextLookupOffset1 = 0;
  int contextLookupOffset2 = 0;
  int distanceCode = 0;
  int numDirectDistanceCodes = 0;
  int distancePostfixBits = 0;
  int distance = 0;
  int copyLength = 0;
  int maxBackwardDistance = 0;
  int maxRingBufferSize = 0;
  int ringBufferSize = 0;
  int expectedTotalSize = 0;
  int outputOffset = 0;
  int outputLength = 0;
  int outputUsed = 0;
  int ringBufferBytesWritten = 0;
  int ringBufferBytesReady = 0;
  int isEager = 0;
  int isLargeWindow = 0;

  // Compound dictionary
  int cdNumChunks = 0;
  int cdTotalSize = 0;
  int cdBrIndex = 0;
  int cdBrOffset = 0;
  int cdBrLength = 0;
  int cdBrCopied = 0;
  List<List<int>> cdChunks = [];
  List<int> cdChunkOffsets = [];
  int cdBlockBits = 0;
  List<int> cdBlockMap = [];

  InputStream? input;

  State() {
    rings[0] = 16;
    rings[1] = 15;
    rings[2] = 11;
    rings[3] = 4;
  }
}
