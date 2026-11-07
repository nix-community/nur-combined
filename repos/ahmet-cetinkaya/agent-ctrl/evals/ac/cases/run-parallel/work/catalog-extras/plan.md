---
status: approved
commits: none
---

# Catalog extras

## Summary

Three independent helpers for the storefront: a page-number window for the pager, tag removal and lookup, and a taxed price from the price book. The tasks touch disjoint files and can run in parallel. Effort: Short. Main risk: none. Decisions made for the user: the window centering rule below.

## Goal

Give the storefront the helpers it needs for its next release.

## Context

- `shop/pagination.py` has `paginate` and `page_count`.
- `shop/catalog.py` has `new_item` and `add_tag`; an item is `{"name": str, "tags": list}`.
- `shop/pricebook.py` has `PriceBook.price(sku)`; `shop/money.py` has `apply_tax(amount, rate)`.
- Tests use `unittest`; run `python3 -I -m unittest` from the repository root.

## Decisions

- The page window is centered on the current page when possible (start at `current - width // 2`), then shifted to stay inside `1..total_pages`.
- Tag operations are case-sensitive.

## Scope

- In: the helpers below and their tests.
- Out: UI changes, tag normalization.

## Tasks

### T1 — `page_window`

Add `page_window(current, total_pages, width=5)` to `shop/pagination.py`. Return consecutive page numbers, `min(width, total_pages)` long, containing `current`, following the centering decision. Raise `ValueError` when `width < 1` or `current` is outside `1..total_pages`. Tests in `tests/test_page_window.py`.

Acceptance: `(1, 10)` → `[1, 2, 3, 4, 5]`; `(5, 10)` → `[3, 4, 5, 6, 7]`; `(10, 10)` → `[6, 7, 8, 9, 10]`; `(2, 3)` → `[1, 2, 3]`; `(4, 10, width=4)` → `[2, 3, 4, 5]`; `(0, 10)` raises `ValueError`.

Depends on: none.

### T2 — `remove_tag` and `has_tag`

Add `remove_tag(item, tag)` (removes the tag if present, no error if absent, returns the item) and `has_tag(item, tag)` (bool) to `shop/catalog.py`. Tests in `tests/test_tag_helpers.py`.

Acceptance: after `add_tag(item, "sale")`, `has_tag(item, "sale")` is true and `has_tag(item, "Sale")` is false; `remove_tag(item, "sale")` leaves `item["tags"] == []`; removing an absent tag returns the item unchanged.

Depends on: none.

### T3 — `PriceBook.price_with_tax`

Add `price_with_tax(self, sku, rate)` to `PriceBook`, returning `apply_tax(self.price(sku), rate)`. Tests in `tests/test_price_with_tax.py`.

Acceptance: a book with `{"A": "20.00"}` and a `0.25` discount on `A` gives `price_with_tax("A", "0.10") == Decimal("16.50")`.

Depends on: none.

## Dependencies

None. T1, T2, and T3 form one parallel group; their write sets are disjoint.

## QA and evidence

Each task: its new test file passes and the full suite passes (`python3 -I -m unittest`).

## Final verification

- Plan compliance: every acceptance example above holds.
- Code quality: `price_with_tax` reuses `price` and `apply_tax`.
- Real-surface QA: print `page_window` for current pages 1 through 10 of 10 and check every window has five pages.
- Scope fidelity: only `shop/pagination.py`, `shop/catalog.py`, `shop/pricebook.py`, and the three new test files change.
