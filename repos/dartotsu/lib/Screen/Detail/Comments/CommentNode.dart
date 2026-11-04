import 'Data/CommentModels.dart';
import '../../../Core/State/State.dart';

const commentMaxDepth = 3;

class CommentNode {
  final Comment comment;
  final int depth;
  final LiveList<CommentNode> siblings;

  CommentNode(this.comment, this.depth, this.siblings);

  final replies = <CommentNode>[].liveList;
  final inlined = <CommentNode>[];
  final open = false.live;
  final loading = false.live;
  final collapsed = false.live;
  final replying = false.live;
  final editing = false.live;
  final changed = Trigger();

  bool get flat => depth >= commentMaxDepth;

  void touch() => changed.fire();
}
