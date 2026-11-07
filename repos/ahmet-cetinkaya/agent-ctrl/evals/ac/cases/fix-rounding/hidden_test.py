import unittest
from decimal import Decimal

from shop.money import apply_tax, round_money


class Hidden(unittest.TestCase):
    def test_halves_round_up(self):
        for raw, expected in [("2.675", "2.68"), ("0.125", "0.13"), ("1.005", "1.01"), ("2.665", "2.67")]:
            self.assertEqual(round_money(Decimal(raw)), Decimal(expected), raw)

    def test_negative_half_away_from_zero(self):
        self.assertEqual(round_money(Decimal("-0.125")), Decimal("-0.13"))

    def test_tax(self):
        self.assertEqual(apply_tax(Decimal("10.05"), "0.05"), Decimal("10.55"))
