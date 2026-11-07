import unittest
from decimal import Decimal

from shop.pricebook import PriceBook


class Hidden(unittest.TestCase):
    def test_bulk_update_after_view(self):
        book = PriceBook({"A": "10.00", "B": "5.00"})
        book.price("A"), book.price("B")
        book.bulk_update({"A": "12.00", "B": "6.00"})
        self.assertEqual((book.price("A"), book.price("B")), (Decimal("12.00"), Decimal("6.00")))

    def test_set_base_and_discount_still_work(self):
        book = PriceBook({"A": "10.00"})
        book.price("A")
        book.set_base("A", "20.00")
        book.set_discount("A", "0.5")
        self.assertEqual(book.price("A"), Decimal("10.00"))
