import unittest
from decimal import Decimal

from shop.invoice import invoice_text
from shop.money import format_money
from shop.notify import email_body


class Hidden(unittest.TestCase):
    def test_format_money(self):
        self.assertEqual(format_money(Decimal("1234.5")), "$1,234.50")
        self.assertEqual(format_money("0.005"), "$0.01")
        self.assertEqual(format_money(Decimal("-1234.5")), "-$1,234.50")
        self.assertEqual(format_money(1, "€"), "€1.00")
        self.assertEqual(format_money(Decimal("1234567.891")), "$1,234,567.89")

    def test_invoice_text(self):
        text = invoice_text([{"amount": "1,000.00"}, {"amount": "5.00"}], "0.10")
        self.assertEqual(text, "1. $1,100.00\n2. $5.50\nTotal: $1,105.50")

    def test_email_body(self):
        self.assertEqual(
            email_body("Ada", [{"amount": "5.00"}], "0"),
            "Hello Ada,\n\nYour invoice:\n1. $5.00\nTotal: $5.00\n\nThank you.",
        )
