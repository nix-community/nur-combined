import unittest

from shop.pagination import page_count, paginate


class Hidden(unittest.TestCase):
    def test_full_pages(self):
        self.assertEqual(paginate(list(range(9)), 1, 3), [0, 1, 2])
        self.assertEqual(paginate(list(range(9)), 3, 3), [6, 7, 8])

    def test_partial_last_page(self):
        self.assertEqual(paginate(list(range(10)), 4, 3), [9])

    def test_pages_cover_all_items(self):
        items = list(range(23))
        pages = [paginate(items, p, 5) for p in range(1, page_count(23, 5) + 1)]
        self.assertEqual(sum(pages, []), items)
