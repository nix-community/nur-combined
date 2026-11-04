import 'Media.dart';

class NewsItem {
  final int id;
  final String title;
  final String url;
  final String source;
  final String? author;
  final DateTime? published;
  final List<Media> series;

  const NewsItem({
    required this.id,
    required this.title,
    required this.url,
    required this.source,
    this.author,
    this.published,
    this.series = const [],
  });

  static const placeholder = NewsItem(
    id: 0,
    title: 'Loading news headline for the placeholder row',
    url: '',
    source: 'source',
  );
}

class NewsPage {
  final List<NewsItem> items;
  final bool hasNext;

  const NewsPage(this.items, this.hasNext);
}
