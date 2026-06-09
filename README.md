# 100× 3 mL Vial Freezer Storage — Compact Stacking Trays

Smallest practical 3D-printable freezer storage for **100 lyophilized 3 mL vials**
(Ø16.51 × 37.74 mm), packed near-cube. Open/vented, PETG/PP, prints on a cheap 220 mm bed.

---

# ▶ CURRENT VERSION — Lidded Modular Tower  → [`current/`](current/)

**Every tray gets its own identical snap lid; the tower stacks `tray → lid → tray → lid …`,
so you can build any height and add layers any time.** Corner gap fixed (clean 45° chamfer),
directed lid drainage, all fits audited.

| | |
|---|---|
| **Footprint** | 106 × 119 mm (near-cube; top-cap lid ~114×127) |
| **Height** | +46.34 mm per layer → **3 layers (105 vials) = 142 mm**, 5 = 235, 10 = 466 |
| **Print per layer** | 1× `tray` + 1× `stacklid` (top layer can use the flush `lid`) |
| **Material** | **PETG or PP — not PLA** (PLA goes brittle at freezer temps) |
| **Verified** | `fit_audit.py` + `checks_lidded.py` all pass; all parts render manifold |

**Download the print files (current):**
- Tray ×N → https://github.com/Blazefit/vial-pack-100/raw/main/current/tray.stl
- Stacklid ×N → https://github.com/Blazefit/vial-pack-100/raw/main/current/stacklid.stl
- Flush top lid ×1 → https://github.com/Blazefit/vial-pack-100/raw/main/current/lid.stl
- Source + audits → [`current/`](current/)

> Print **one tray + one stacklid first** to test the snap + stack fit, tune
> `reg_clr` / `catch_step` / `bore_clear`, then run the rest.

---

# Iteration history → [`iterations/`](iterations/)

Each folder is a complete, self-contained snapshot of that design stage (reconstructed
from git history). Newest last.

| # | Folder | What it was | Why it changed |
|---|--------|-------------|----------------|
| 1 | [`iterations/1-bundle-cube`](iterations/1-bundle-cube) | Dense honeycomb cube, vials stacked 3-deep in shared bores | Rule added: every vial needs its **own** holder |
| 2 | [`iterations/2-trays-sleeve-v1`](iterations/2-trays-sleeve-v1) | Individual pockets in stacking trays + outer sleeve | First individual-holder design |
| 3 | [`iterations/3-trays-sleeve-v2`](iterations/3-trays-sleeve-v2) | +15 improvements: snap lid, stacking grooves, push-hole, relief holes, corner key, checks | Hardened the tray/sleeve system |
| 4 | [`iterations/4-sleeveless-tower-v3`](iterations/4-sleeveless-tower-v3) | **Dropped the sleeve** — trays interlock directly; thin-wall tube cups | Cut filament ~52% (~1050 g → ~514 g); fixed bottom-layer access |
| 5 | [`iterations/5-lidded-stack-v4`](iterations/5-lidded-stack-v4) | **= CURRENT.** Per-tray lids, modular any-height, directed drainage, corner gap fixed | Modular height + sealed-per-layer + corner fix |

## Design facts (all versions)
- Vials are sealed by their own crimp + septum → the container never needs to seal the
  powder. **Open/vented is correct for a freezer** (no condensation trap; meltwater drains).
- Hexagonal close-packing; ~0.9 L of vials → ~1.0–1.3 L container depending on features.
- All parts print flat, no supports, on a 220 mm bed.

## Note on OpenSCAD part files
Render each part via its `*_part.scad` wrapper. The dispatcher uses a **read-only**
`part_sel` selector — never re-assign `PART`, or OpenSCAD's last-assignment hoisting
silently renders the default part for every wrapper.
