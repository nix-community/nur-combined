---
status: approved
commits: none
---

# Split billing

## Summary

Customers can split an invoice into equal parts that add up to the exact total, the catalog can rename items safely, and the report can total sales per SKU. One dependent pair (split amount, then split invoice) and two independent tasks. Effort: Short. Main risk: cent remainders not adding up. Decisions made for the user: remainder cents go to the first parts.

## Goal

Support split payments and two small catalog and report helpers needed alongside them.

## Context

- `shop/money.py` has `round_money` (half-up to cents).
- `shop/invoice.py` has `invoice_total(lines, tax_rate)`.
- `shop/catalog.py` has `new_item`; an item is `{"name": str, "tags": list}`.
- `shop/report.py` has `sales_summary(csv_text)`; `shop/csvio.py` has `load_rows`; `shop/money.py` has `parse_money`.
- Tests use `unittest`; run `python3 -I -m unittest` from the repository root.

## Decisions

- Splits work in whole cents on the absolute value; leftover cents go one each to the first parts; the sign is applied to every part.
- `rename_item` never mutates its input.

## Scope

- In: the four functions below and their tests.
- Out: persisting splits, currency conversion.

## Tasks

### T1 — `split_amount`

Add `split_amount(amount, parts)` to `shop/money.py`, returning a list of `parts` Decimals per the split decision that sums exactly to `round_money(amount)`. Raise `ValueError` when `parts < 1`. Tests in `tests/test_split_amount.py`.

Acceptance: `("10.00", 3)` → `[3.34, 3.33, 3.33]`; `("0.05", 3)` → `[0.02, 0.02, 0.01]`; `("-10.00", 3)` → `[-3.34, -3.33, -3.33]`; `("7", 1)` → `[7.00]`; `("1", 0)` raises `ValueError`.

Depends on: none.

### T2 — `split_invoice`

Add `split_invoice(lines, tax_rate, parts)` to `shop/invoice.py`, returning `split_amount(invoice_total(lines, tax_rate), parts)`. Tests in `tests/test_split_invoice.py`.

Acceptance: `split_invoice([{"amount": "10.00"}], "0", 3)` → `[3.34, 3.33, 3.33]`.

Depends on: T1.

### T3 — `rename_item`

Add `rename_item(item, name)` to `shop/catalog.py`. Strip whitespace from `name`; raise `ValueError` if the result is empty; return a new item with the new name and a copy of the tags. Tests in `tests/test_rename_item.py`.

Acceptance: renaming `{"name": "pen", "tags": ["a"]}` to `"  ink "` returns `{"name": "ink", "tags": ["a"]}`, the original is unchanged, and the tag lists are different objects; `"   "` raises `ValueError`.

Depends on: none.

### T4 — `sales_by_sku`

Add `sales_by_sku(csv_text)` to `shop/report.py`, returning a dict of SKU to total `Decimal` amount, keys in order of first appearance. Tests in `tests/test_sales_by_sku.py`.

Acceptance: `"sku,amount\nA,1.00\nB,2.00\nA,3.50\n"` → `{"A": Decimal("4.50"), "B": Decimal("2.00")}` with keys in the order `A`, `B`.

Depends on: none.

## Dependencies

T1 → T2. T3 and T4 are independent of each other and of T1–T2; all write sets except T1/T2 are disjoint.

## QA and evidence

Each task: its new test file passes and the full suite passes (`python3 -I -m unittest`).

## Final verification

- Plan compliance: every acceptance example above holds.
- Code quality: `split_invoice` reuses `split_amount` and `invoice_total`.
- Real-surface QA: print `split_invoice` for a 100.00 invoice in 3, 6, and 7 parts and check each sums to the total.
- Scope fidelity: only `shop/money.py`, `shop/invoice.py`, `shop/catalog.py`, `shop/report.py`, and the four new test files change.
