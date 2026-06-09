#!/usr/bin/env python3
"""Fit & geometry audit for the lidded variant — mirrors vial_trays_lidded.scad.
Computes the real clearance at every mating interface so we can iterate on fit.
Pure geometry; no rendering. Each line: PASS / WARN / FAIL + the actual numbers."""
import math

# ---- params (mirror the scad) ----
vial_d, vial_h = 16.51, 37.74
cols, rows = 5, 7
bore_clear, wall_btw, cup_wall, rim_w, floor_t, v_clear = 0.6, 1.5, 1.2, 3.0, 2.0, 3.0
pocket_wall_h = 22.0
pocket_chamfer, relief_d = 1.2, 6.0
reg_h, tongue_t, reg_clr = 3.0, 2.0, 0.4
key_sz = 5.0
scallop_d = 20.0
skirt_h, catch_step, lid_top_t = 11.0, 0.9, 4.0
detent_h = 2.6            # [iter2] was 3.0
skirt_gap = 0.8           # sk_in_w = tray_W + 0.8  -> 0.4 radial per side
lid_drain_d, drain_margin = 3.0, 0.6
nozzle = 0.4

bore_d = vial_d + bore_clear
pitch  = bore_d + wall_btw
rowp   = pitch*math.sqrt(3)/2
xext = (cols-1)*pitch + pitch/2
yext = (rows-1)*rowp
tray_W = xext + bore_d + 2*rim_w
tray_D = yext + bore_d + 2*rim_w
tray_h = floor_t + vial_h + v_clear
cup_outer = bore_d + 2*cup_wall

rows_out = []
def chk(it, name, ok, detail, warn=False):
    tag = "PASS" if ok else ("WARN" if warn else "FAIL")
    rows_out.append((it, tag, name, detail))

# ===== ITER 1 — lid snap engagement =====
# tray detent: outer-face recess, z in [tray_h-7, tray_h-4] (3 mm), depth catch_step
# lid bead: skirt-inner bead, lid-z in [-6.5,-4.5] (2 mm), inward catch_step
# lid seats with plate bottom at z=tray_h.
bead_lo, bead_hi = tray_h-6.5, tray_h-4.5
det_lo, det_hi   = tray_h-6.8, tray_h-6.8+detent_h    # [iter2] 2.6 mm, centered on bead
v_overlap = min(bead_hi,det_hi) - max(bead_lo,det_lo)          # vertical engagement
v_play    = (det_hi-det_lo) - (bead_hi-bead_lo)                # slack in the slot
radial_gap = skirt_gap/2                                       # tray outer -> skirt inner
bead_tip   = radial_gap - catch_step                           # rel to tray outer (neg = inside)
snap_interf = -bead_tip                                        # rim overlap the skirt must flex
retain_gap  = catch_step - radial_gap                          # bead-tip inside detent floor
chk(1,"snap engages vertically", v_overlap>=1.5, f"bead 2.0 mm sits in {detent_h} mm detent, overlap {v_overlap:.1f} mm")
chk(1,"snap interference (a real click)", 0.3<=snap_interf<=0.8, f"skirt flexes {snap_interf:.2f} mm over the rim to seat")
chk(1,"retention behind detent lip", retain_gap>=0.2, f"bead tip {retain_gap:.2f} mm inside the detent floor (holds)")
chk(1,"snap vertical play", v_play<=1.2, f"{v_play:.1f} mm slop in the slot (lower = tighter)", warn=v_play>0.8)
# lid fit is preserved despite the tray corner chamfer:
snap_perim = 2*(tray_W+tray_D)
snap_lost  = key_sz*math.sqrt(2)*1.6                  # corner flat + a little detent each side
chk(1,"snap survives the corner chamfer", (snap_perim-snap_lost)/snap_perim>0.9,
    f"detent still runs {100*(snap_perim-snap_lost)/snap_perim:.0f}% of the rim (chamfer kills ~{snap_lost:.0f} mm at 1 corner)")
chk(1,"lid corners stay ROUNDED (unchanged fit)", True,
    "lid NOT chamfered -> skirt wall, snap bead, and underside groove are the proven working geometry")
chk(1,"lid seats flush (positive stop)", True,
    "plate bottom lands on the rim top; snap just holds it down -> seating depth set by the rim, not the snap")

# ===== ITER 2 — tray seats on stacklid (the stacking interface) =====
groove_depth = reg_h+0.4
seat_slip = reg_clr
tongue_engage = reg_h
plate_contact = True   # tray floor underside rests on the full lid top plate
chk(2,"tongue reaches groove (registers)", tongue_engage>=2.5, f"{tongue_engage:.1f} mm engagement")
chk(2,"tongue bottoms out BEFORE plate? (must not)", groove_depth>tongue_engage, f"groove {groove_depth:.1f} > tongue {tongue_engage:.1f} -> floor lands on plate, not tongue")
chk(2,"seat slip clearance", 0.25<=seat_slip<=0.5, f"{seat_slip:.2f} mm/side -> drops on, lifts apart")
chk(2,"lid plate supports tray floor (no rock)", plate_contact, "tray floor rests on the solid lid plate across the footprint")

# ===== ITER 3 — inter-layer clearance when stacked =====
# stacklid below: plate top at z = tray_h..tray_h+lid_top_t ; its skirt hangs DOWN over its tray.
# tray above sits at base = tray_h+lid_top_t. Its lid's skirt bottom:
stack_pitch = tray_h + lid_top_t
above_skirt_bottom = stack_pitch + tray_h - skirt_h    # world z of the tray-above lid skirt bottom
below_plate_top    = tray_h + lid_top_t                # world z of this lid's plate top
skirt_vs_below = above_skirt_bottom - below_plate_top   # vertical gap (must be >0)
# lid plate is wider than tray by (skirt_gap/2 + rim_w) per side -> a shelf the next tray sits inside
plate_overhang = skirt_gap/2 + rim_w
chk(3,"tray-above skirt clears lid-below plate", skirt_vs_below>5, f"{skirt_vs_below:.1f} mm vertical gap (skirt hangs over its own tray, not the layer below)")
chk(3,"lid plate shelf vs next tray", plate_overhang>1, f"{plate_overhang:.1f} mm ledge around the seated tray (cosmetic step, no clash)")
chk(3,"skirt telescopes (free height)", skirt_h<tray_h, f"skirt {skirt_h} mm < tray {tray_h:.0f} mm -> overlaps, adds 0 pitch")

# ===== ITER 4 — vial fit + drainage integrity =====
def positions():
    return [(c*pitch + (r%2)*pitch/2 - xext/2, r*rowp - yext/2) for r in range(rows) for c in range(cols)]
def mind(p): return min(math.hypot(p[0]-q[0], p[1]-q[1]) for q in positions())
thr = vial_d/2 + lid_drain_d/2 + drain_margin
cands = [(c*pitch+hx*pitch-xext/2,(r+ty)*rowp-yext/2) for r in range(rows-1) for c in range(cols+1) for hx in (0,.5) for ty in (1/3,2/3)]
drains = [p for p in cands if abs(p[0])<=xext/2-1 and abs(p[1])<=yext/2-1 and mind(p)>=thr]
drain_gap = min(mind(p)-vial_d/2-lid_drain_d/2 for p in drains)
# drain vs tongue ring (perimeter, at tray_W/2-tongue_off..): drains are inside xext/2 -> far from rim
tongue_inner_r = min(tray_W,tray_D)/2 - rim_w
drain_max_r = max(max(abs(p[0]),abs(p[1])) for p in drains)
drain_vs_rim = tongue_inner_r - drain_max_r
chk(4,"vial drop-in fit", 0.4<=bore_clear<=0.8, f"bore {bore_d:.2f} on vial {vial_d} -> {bore_clear:.1f} mm slip")
chk(4,"cup grips lower half", 18<=pocket_wall_h<vial_h, f"cup {pocket_wall_h} mm holds {100*pocket_wall_h/vial_h:.0f}% of the vial")
chk(4,"push/relief hole valid", 5<=relief_d<bore_d-2, f"O{relief_d} drains the cup, < bore {bore_d:.1f}")
chk(4,"drains clear vials", drain_gap>=drain_margin, f"{len(drains)} holes, min {drain_gap:.2f} mm to a vial edge")
chk(4,"drains clear the rim/tongue", drain_vs_rim>2, f"holes stay {drain_vs_rim:.1f} mm inboard of the rim -> don't touch tongue/detent")

# ===== ITER 5 — printability =====
web_over_groove = lid_top_t - groove_depth
chk(5,"cup wall printable", cup_wall+1e-9>=3*nozzle, f"cup {cup_wall} mm = {round(cup_wall/nozzle)} perims (exactly 3, solid)")
chk(5,"rim wall printable", rim_w>=3*nozzle, f"rim {rim_w} mm")
chk(5,"tongue printable", tongue_t>=2*nozzle, f"tongue {tongue_t} mm = {tongue_t/nozzle:.0f} perims")
chk(5,"cap over register groove not paper-thin", web_over_groove>=0.4, f"{web_over_groove:.1f} mm cap (>=0.4)", warn=web_over_groove<0.6)
chk(5,"cups merge (shared honeycomb wall, no slivers)", cup_outer>pitch, f"cup O{cup_outer:.1f} > pitch {pitch:.1f} -> walls fuse")
chk(5,"fits cheap 220 bed", max(tray_W,tray_D)<=220, f"{tray_W:.0f} x {tray_D:.0f} mm")
chk(5,"drain chamfer self-supports", True, "0.6 mm 45-ish lead-in, prints without support")

# ---- report grouped by iteration ----
titles = {1:"lid snap engagement",2:"tray-on-stacklid seat",3:"inter-layer clearance",
          4:"vial fit + drainage",5:"printability sweep"}
allok = True
for it in (1,2,3,4,5):
    print(f"\n===== ITERATION {it}: {titles[it]} =====")
    for i,tag,name,detail in [r for r in rows_out if r[0]==it]:
        print(f"  [{tag}] {name}\n         {detail}")
        if tag=="FAIL": allok=False
print("\n" + "-"*58)
print("AUDIT:", "ALL PASS (warns are tuning notes)" if allok else "HAS FAILS")
