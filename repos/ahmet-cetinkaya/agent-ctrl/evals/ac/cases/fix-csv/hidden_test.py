import unittest
from decimal import Decimal

from shop.csvio import load_rows
from shop.report import sales_summary


class Hidden(unittest.TestCase):
    def test_loader_without_trailing_newline(self):
        self.assertEqual(load_rows("sku,amount\nA,1.00\nB,2.00"), [{"sku": "A", "amount": "1.00"}, {"sku": "B", "amount": "2.00"}])

    def test_loader_with_trailing_newline(self):
        self.assertEqual(len(load_rows("sku,amount\nA,1.00\n")), 1)

    def test_summary(self):
        self.assertEqual(sales_summary("sku,amount\nA,1.00\nB,2.00"), (2, Decimal("3.00")))
