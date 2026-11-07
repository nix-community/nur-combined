import unittest
from decimal import Decimal

from shop.catalog import add_tag, has_tag, new_item, remove_tag
from shop.pagination import page_window
from shop.pricebook import PriceBook


class Hidden(unittest.TestCase):
    def test_page_window(self):
        self.assertEqual(page_window(1, 10), [1, 2, 3, 4, 5])
        self.assertEqual(page_window(5, 10), [3, 4, 5, 6, 7])
        self.assertEqual(page_window(10, 10), [6, 7, 8, 9, 10])
        self.assertEqual(page_window(2, 3), [1, 2, 3])
        self.assertEqual(page_window(4, 10, width=4), [2, 3, 4, 5])
        for current in range(1, 11):
            window = page_window(current, 10)
            self.assertEqual(len(window), 5)
            self.assertIn(current, window)

    def test_page_window_rejects(self):
        for args in [(0, 10), (11, 10), (1, 10, 0)]:
            with self.assertRaises(ValueError):
                page_window(*args)

    def test_tags(self):
        item = add_tag(new_item("pen"), "sale")
        self.assertTrue(has_tag(item, "sale"))
        self.assertFalse(has_tag(item, "Sale"))
        self.assertIs(remove_tag(item, "missing"), item)
        remove_tag(item, "sale")
        self.assertEqual(item["tags"], [])

    def test_price_with_tax(self):
        book = PriceBook({"A": "20.00"})
        book.set_discount("A", "0.25")
        self.assertEqual(book.price_with_tax("A", "0.10"), Decimal("16.50"))
