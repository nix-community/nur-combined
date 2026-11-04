import '../../../../Core/Services/MediaService.dart';
import '../../../../Core/Services/Model/News.dart';
import '../Auth.dart';

class MangaBakaNewsView extends NewsScreenView {
  @override
  Future<NewsPage> news({int page = 1}) =>
      mangaBakaAuth.community.news(page: page);
}
