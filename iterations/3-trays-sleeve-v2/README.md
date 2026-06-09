# 100× 3 mL Vials — Individual-Holder Stacking Trays (v2)

Each vial in its **own pocket on its own floor**. Three identical 5×7 hex trays (35 pockets each, 105 total) stack inside a sleeve with a **snap lid** → near-cube.

![cutaway](cutaway.png)

| | |
|---|---|
| **Vial** | Ø16.51 × 37.74 mm (standard 3 mL serum vial) |
| **Assembled envelope** | **118 × 131 × 136 mm** (near-cube, aspect 1.15) |
| **Print** | `tray.stl` ×3, `sleeve.stl` ×1, `lid.stl` ×1 |
| **Verified** | `checks.py` (16 dimensional checks) + all parts render manifold |

## v2 — 15 improvements over v1

1. **Vial height clearance** — explicit 3 mm gap above every vial; stacked trays never crush them
2. **Stacking grooves** — tongue on top rim / groove on bottom rim interlock trays (anti-shift)
3. **Snap lid** — friction skirt + catch lip that clicks under the sleeve's top bead
4. **Bottom-layer removal** — Ø30 mm push-hole in the sleeve base shoves the stack up
5. **Side windows** — short-end openings so any tray (incl. the bottom) is grabbable
6. **Pocket lead-in chamfer** — vials self-center on insertion
7. **Relief/push hole** — Ø6 mm at each pocket bottom: poke a vial out, frost drains
8. **Corner key** — rib in sleeve / notch in tray; trays only seat one orientation
9. **Lead-in chamfer** on the tray bottom edge — drops into the sleeve cleanly
10. **Finger scallops** on tray long sides
11. **Lid grip recess** on top
12. **Tuned clearances** — tongue/groove 0.4 mm, tray-in-sleeve 0.5 mm, lid friction 0.3 mm
13. **Top-edge chamfers** for handling + printability
14. **Dimensional self-check** (`checks.py`) — verifies all 16 fits close
15. **Re-verified** all parts render manifold; corner-key fixed from cosmetic to functional rib

## Print

- **Trays & lid:** flat, pockets/skirt up → no supports. **Sleeve:** open-end up.
- PETG (freezer-friendly), 0.4 mm nozzle, 3 perimeters.
- Print **one tray first** to fit-test with your real vials; tune `bore_clear` if needed.

## Files

| File | Purpose |
|---|---|
| `vial_trays.scad` | Parametric source (tray / sleeve / lid / assembly) |
| `tray.stl` / `sleeve.stl` / `lid.stl` | Print files |
| `checks.py` | Dimensional verification |
| `*_part.scad` | Render wrappers |
| `cutaway.png` / `exploded.png` / `tray.png` | Renders |

## Tuning

```bash
python3 checks.py                                    # verify dims
openscad -o tray.stl --export-format=binstl tray_part.scad
```

Key params at the top of `vial_trays.scad`: `bore_clear`, `v_clear`, `reg_h`/`tongue_t`/`reg_clr` (grooves), `catch_step` (snap), `slide_clr`, `push_hole_d`.

> Render each part via its `*_part.scad` wrapper. The dispatcher uses a read-only
> `part_sel` selector — never re-assign `PART`, or OpenSCAD's last-assignment hoisting
> silently renders the default part for every wrapper.

> ⚠️ Verified in software only. Print one tray + the lid-to-sleeve snap as a fit-test
> before committing to all three trays.
