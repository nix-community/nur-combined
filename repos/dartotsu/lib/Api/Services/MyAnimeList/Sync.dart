import '../../../Screen/Settings/Sync/Data/SyncAdapter.dart';
import '../../../Screen/Settings/Sync/Data/SyncModels.dart';
import 'Client.dart';
import 'Data/Mapper.dart';
import 'Mutations.dart';
import 'Queries.dart';

class MalSync extends SyncAdapter {
  final MalQueries queries;
  final MalMutations mutations;

  MalSync(this.queries, this.mutations);

  @override
  String get key => SyncKey.mal;

  @override
  bool supports({required bool anime}) => true;

  @override
  List<SyncLimit> get limits => const [SyncLimit(40, Duration(minutes: 1))];

  @override
  Future<List<SyncItem>> library({required bool anime}) async {
    try {
      final media = await queries.syncLibrary(anime: anime);
      return [
        for (final m in media)
          if (parseMalMediaId(m.id) case (_, final id))
            SyncItem.fromMedia(m, {SyncKey.mal: id}),
      ];
    } on MalException catch (e) {
      throw syncError(e, status: e.status);
    }
  }

  @override
  String? targetId(int native, {required bool anime}) =>
      '${anime ? 'anime' : 'manga'}/$native';

  @override
  int? nativeId(String id) => parseMalMediaId(id)?.$2;

  @override
  Future<int> write(List<SyncOp> batch, {required bool anime}) async {
    try {
      for (final op in batch) {
        await mutations.saveEntry(
          op.want.toMedia(anime: anime, idOverride: op.targetId),
          exists: op.existsHint,
        );
      }
    } on MalException catch (e) {
      throw syncError(e, status: e.status);
    }
    return batch.length;
  }

  @override
  Future<void> finish() async => queries.invalidateLibrary();
}
