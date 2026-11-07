import unittest
from decimal import Decimal

from shop.invoice import invoice_total
from shop.money import parse_money


class Hidden(unittest.TestCase):
    def test_parse(self):
        self.assertEqual(parse_money(" 1,234,567.25 "), Decimal("1234567.25"))

    def test_invoice(self):
        self.assertEqual(invoice_total([{"amount": "1,234.50"}], "0"), Decimal("1234.50"))
