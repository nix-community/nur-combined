import unittest
from decimal import Decimal

from shop.catalog import rename_item
from shop.invoice import split_invoice
from shop.money import split_amount
from shop.report import sales_by_sku

D = Decimal


class Hidden(unittest.TestCase):
    def test_split_amount(self):
        self.assertEqual(split_amount("10.00", 3), [D("3.34"), D("3.33"), D("3.33")])
        self.assertEqual(split_amount("0.05", 3), [D("0.02"), D("0.02"), D("0.01")])
        self.assertEqual(split_amount("-10.00", 3), [D("-3.34"), D("-3.33"), D("-3.33")])
        self.assertEqual(split_amount("7", 1), [D("7.00")])
        for parts in (3, 6, 7):
            self.assertEqual(sum(split_amount("100.00", parts)), D("100.00"))
        with self.assertRaises(ValueError):
            split_amount("1", 0)

    def test_split_invoice(self):
        self.assertEqual(split_invoice([{"amount": "10.00"}], "0", 3), [D("3.34"), D("3.33"), D("3.33")])

    def test_rename_item(self):
        original = {"name": "pen", "tags": ["a"]}
        renamed = rename_item(original, "  ink ")
        self.assertEqual(renamed, {"name": "ink", "tags": ["a"]})
        self.assertEqual(original, {"name": "pen", "tags": ["a"]})
        self.assertIsNot(renamed["tags"], original["tags"])
        with self.assertRaises(ValueError):
            rename_item(original, "   ")

    def test_sales_by_sku(self):
        totals = sales_by_sku("sku,amount\nA,1.00\nB,2.00\nA,3.50\n")
        self.assertEqual(totals, {"A": D("4.50"), "B": D("2.00")})
        self.assertEqual(list(totals), ["A", "B"])
