# Assumptions and interpretations (Phase 1)

Anything below that affects pay can be changed on the **Payroll rules** page, or needs the owner's decision.

## Payroll-related interpretations (please confirm)

1. **How short hours are measured.** Short hours = required hours (9) − (last punch − first punch) on a paid present day,
   and extra hours = worked hours − 9. Arriving 30 minutes late but staying 30 minutes longer therefore gives **no** shortfall.
   Section 7 mentions both "late arrival / early departure" and "hours = last − first", so there is a setting
   (*How short hours are measured*) to switch to "late minutes + early minutes" instead.
2. **Late grace period** (default 0). Once someone is later than the grace period, the *whole* lateness counts, not just the minutes after the grace.
   This only matters for the "late + early" setting and the "Late" column.
3. **Days eSSL calls "Absent" but that have two or more punches** (for example ID 19 on 6 Aug: 14:22–15:25) are treated as
   **present with short hours** (7:57 short), as section 7 says. The half-day rule is off. If the owner prefers half or unpaid days, turn on the half-day rule.
4. **Half-day rule (off by default).** When on, a present day below the threshold counts as 0.5 unpaid day with **no** hourly deduction for that day, so it is never deducted twice.
5. **Leave allowance "per year"** means the calendar year (January–December). Paid-leave days are used up in date order. Carry-forward is stored as a setting but **not built**.
6. **Money rounding.** Rates are kept at full precision. Each deduction and the final amount are rounded to 2 decimals (paise), not to whole rupees.
7. **Weekly off = Sunday only** (confirmed by the owner). It is set per employee and is the default for new employees.
   The portal follows its own pattern, not eSSL's: eSSL marks many Saturdays as "WeeklyOff" / "WeeklyOff Present" and
   puts Saturday hours under "OT". The portal treats Saturday as a normal working day (9 hours required, short/extra counted).
8. **Single punch on a weekly off** is shown for information only. It is not an issue and has no pay effect.
9. **A reason that also has punches** (for example leave set on a day with punches) keeps the admin's reason, and a warning is shown.
   Hours worked on holidays are shown but are not counted as extra hours.
10. **Salary changes** apply to all months that are not locked. There is no "effective from" date yet. Locked months keep their approved snapshot.
11. **Partial months** (joining or leaving date inside the month): days outside employment are not deducted and not paid extra.
    The month is flagged, and the admin must add an adjustment if needed and mark it resolved with a note. No proration formula was assumed.
12. **Employees in payroll** for a month: all employees except "Inactive" ones, unless an inactive employee has a leaving date in or after that month.

13a. **Extra hours cover short hours** from any day of the same month, before or after, and never across months.
    For display, short days are covered in date order. The total deducted is always max(0, short − extra).
13b. **Work on weekly offs / holidays** counts as extra hours only if the rule "Work on weekly off / holiday" is set to
    "Count as extra hours" on the Payroll rules page. The default is still "Rule pending", which means it does not count.
13c. **Editing a leave range** deactivates the old day records (kept in history) and creates new ones. Editing in/out
    times creates correction records. The original machine punches are never changed.

## Import interpretations

13. **"Day in progress"**: if the report's print date falls inside its date range, that date is the unfinished day
    (Sep report: 29 Sep). Its single punches are not treated as issues, and it blocks payroll as "attendance incomplete".
14. When a later file completes a day that was "in progress", and the new punches **include** all the old ones, the day is
    updated automatically. This is audited and shown as "Replaced an unfinished (day in progress) row". Any other difference is a **conflict** for the admin to resolve.
15. A **re-upload of the exact same file** (same SHA-256 fingerprint) is refused with a warning. A cancelled import can be uploaded again.
16. **Duplicate rows inside one file**: identical copies are ignored. Different copies: the first one is imported and the day is marked CONFLICT.
17. **Employee names equal to their code** (IDs 9 and 18) are flagged "not properly registered in eSSL". In this demo they are unknown IDs and skipped.
18. **Name mismatch** between eSSL and the portal is only a warning. Matching is always by attendance ID.
19. **Days with no imported data** (e.g. the month is not finished yet) are shown as "No data imported", never as absence, and they block approval.

## Things that are placeholders or not built

- **Excel import**: `EsslExcelParser` is a stub. The *Column mappings* screen and model exist and are ready for when a sample Excel file arrives.
- **Weekly-off / holiday work pay, overtime pay, comp-off**: not built. They are listed under "Rules to decide".
- **Leave carry-forward**: not built.
- **Bootstrap** is loaded from a CDN (internet needed). It can be bundled locally later.
- Only one user type (admin/staff). Additional admin users can be created with `python manage.py createsuperuser`.
