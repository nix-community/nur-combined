---
status: approved
commits: none
---

# Invoice email

## Summary

Customers get a plain-text invoice email built from formatted money amounts. Three dependent tasks: money formatting, invoice text that uses it, and the email body that embeds the invoice text. Effort: Short. Main risk: none beyond formatting regressions. Decisions made for the user: the exact text layout below.

## Goal

Produce the invoice email text so the notification job can send it.

## Context

- `shop/money.py` has `round_money` (half-up to cents) and `apply_tax`.
- `shop/invoice.py` has `invoice_total(lines, tax_rate)`; a line is `{"amount": "<text>"}`.
- Tests use `unittest`; run `python3 -I -m unittest` from the repository root.

## Decisions

- Currency symbol defaults to `$`; amounts always show two decimals and comma thousands separators.
- Negative amounts put the sign before the symbol: `-$1,234.50`.

## Scope

- In: the three functions below and their tests.
- Out: sending email, other currencies, localization.

## Tasks

### T1 — `format_money`

Add `format_money(amount, symbol="$")` to `shop/money.py`. It rounds with `round_money` and returns the symbol, comma-grouped integer part, and two decimals. Add tests in `tests/test_format_money.py`.

Acceptance: `format_money(Decimal("1234.5"))` → `"$1,234.50"`; `format_money("0.005")` → `"$0.01"`; `format_money(Decimal("-1234.5"))` → `"-$1,234.50"`; `format_money(1, "€")` → `"€1.00"`.

Depends on: none.

### T2 — `invoice_text`

Add `invoice_text(lines, tax_rate)` to `shop/invoice.py`. One row per line, `"<n>. <formatted taxed line amount>"` numbered from 1, then a final row `"Total: <formatted invoice_total>"`, joined with `"\n"`, no trailing newline. Add tests in `tests/test_invoice_text.py`.

Acceptance: `invoice_text([{"amount": "1,000.00"}, {"amount": "5.00"}], "0.10")` → `"1. $1,100.00\n2. $5.50\nTotal: $1,105.50"`.

Depends on: T1.

### T3 — `email_body`

Create `shop/notify.py` with `email_body(customer, lines, tax_rate)` returning `"Hello <customer>,\n\nYour invoice:\n<invoice_text>\n\nThank you."`. Add tests in `tests/test_notify.py`.

Acceptance: `email_body("Ada", [{"amount": "5.00"}], "0")` → `"Hello Ada,\n\nYour invoice:\n1. $5.00\nTotal: $5.00\n\nThank you."`.

Depends on: T2.

## Dependencies

T1 → T2 → T3. No parallel group.

## QA and evidence

Each task: its new test file passes and the full suite passes (`python3 -I -m unittest`).

## Final verification

- Plan compliance: every acceptance example above holds.
- Code quality: no duplication of rounding logic; `round_money` is reused.
- Real-surface QA: print `email_body` for a two-line invoice and compare with the T3 format.
- Scope fidelity: only `shop/money.py`, `shop/invoice.py`, `shop/notify.py`, and the three new test files change.
