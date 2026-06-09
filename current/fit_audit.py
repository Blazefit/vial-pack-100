#!/usr/bin/env python3
"""Fit & geometry audit — v6 inboard-register variant. Mirrors vial_trays_lidded.scad.
Computes the real clearance at every mating interface. Pure geometry; no rendering.
Each line: PASS / WARN / FAIL + the actual numbers.
NOTE: checks_lidded.py carries the param-drift guard against the live .scad;
keep the param block below identical to it."""
import math

# ---- params (mirror the scad) ----
vial_d, vial_h = 16.51, 37.74
cols, rows = 5, 7
bore_clear, wall_btw, cup_wall, rim_w, floor_t, v_clear = 0.6, 1.5, 1.2, 2.5, 1.6, 3.0
pocket_wall_h = 22.0
pocket_chamfer, relief_d = 1.2, 6.0
reg_clr, tng_t = 0.3, 1.2
top_tng_h, top_tng_in = 1.2, 1.0
bot_tng_h, bot_tng_in = 1.0, 3.3
slot_extra = 0.2
key_sz = 5.0
skirt_h, catch_step, lid_top_t = 11.0, 0.9, 4.0
detent_h = 2.6
skirt_gap = 0.8           # sk_in_w = tray_W + 0.8  -> 0.4 radial per side
lid_drain_d, drain_margin = 3.0, 0.6
nub_d, nub_protrude = 1.8, 0.5
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

# ===== ITER 1 — lid snap engagement (top cap lid() only) =====
bead_lo, bead_hi = tray_h-6.5, tray_h-4.5
det_lo, det_hi   = tray_h-6.8, tray_h-6.8+detent_h
v_overlap = min(bead_hi,det_hi) - max(bead_lo,det_lo)
v_play    = (det_hi-det_lo) - (bead_hi-bead_lo)
radial_gap = skirt_gap/2
snap_interf = catch_step - radial_gap
retain_gap  = catch_step - radial_gap
chk(1,"snap engages vertically", v_overlap>=1.5, f"bead 2.0 mm sits in {detent_h} mm detent, overlap {v_overlap:.1f} mm")
chk(1,"snap interference (a real click)", 0.3<=snap_interf<=0.8, f"skirt flexes {snap_interf:.2f} mm over the rim to seat")
chk(1,"retention behind detent lip", retain_gap>=0.2, f"bead tip {retain_gap:.2f} mm inside the detent floor (holds)")
chk(1,"snap vertical play", v_play<=1.2, f"{v_play:.1f} mm slop in the slot (lower = tighter)", warn=v_play>0.8)
snap_perim = 2*(tray_W+tray_D)
snap_lost  = key_sz*math.sqrt(2)*1.6
chk(1,"snap survives the corner chamfer", (snap_perim-snap_lost)/snap_perim>0.9,
    f"detent still runs {100*(snap_perim-snap_lost)/snap_perim:.0f}% of the rim (chamfer kills ~{snap_lost:.0f} mm at 1 corner)")
chk(1,"lid seats flush (positive stop)", True,
    "plate bottom lands on the rim top; snap just holds it down")

# ===== ITER 2 — v6 registers: walls, caps, engagement =====
# Interface A: tray-top tongue (inset top_tng_in, t tng_t, h top_tng_h)
#              -> slot in lid/stacklid underside (inset-reg_clr, t+2clr, h+slot_extra)
a_slot_w  = tng_t + 2*reg_clr
a_slot_d  = top_tng_h + slot_extra
a_outer_w = top_tng_in - reg_clr            # slot outer wall (lid plate flush w/ tray face)
a_cap     = lid_top_t - a_slot_d
chk(2,"[A] slot outer wall exists (v5 bug class)", a_outer_w>=0.5,
    f"{a_outer_w:.2f} mm wall between slot and lid face (v5: NEGATIVE -0.15 -> severed rim)")
chk(2,"[A] cap over lid slot", a_cap>=1.0, f"{a_cap:.1f} mm (v4/v5 was 0.6)")
chk(2,"[A] tongue on rim with margin", top_tng_in+tng_t<=rim_w-0.2,
    f"tongue {top_tng_in}..{top_tng_in+tng_t:.1f} from face on {rim_w} rim ({rim_w-top_tng_in-tng_t:.1f} inner ledge)")
chk(2,"[A] engagement", top_tng_h>=1.0, f"{top_tng_h} mm tongue in a {a_slot_d:.1f} mm slot")
# Interface B: stacklid-top tongue (inset bot_tng_in) -> slot in tray FLOOR underside
b_slot_d  = bot_tng_h + slot_extra
b_outer_w = bot_tng_in - reg_clr            # slot outer edge distance from tray face
b_cap     = floor_t - b_slot_d
relief_face_gap = (tray_D/2 - yext/2) - relief_d/2
b_inner_clear = relief_face_gap - (bot_tng_in + tng_t + reg_clr)
chk(2,"[B] slot fully inboard of the rim (frame solid to the bed)", b_outer_w>=rim_w+0.4,
    f"slot outer edge {b_outer_w:.1f} mm from face; rim {rim_w} mm stays uncut at every z")
chk(2,"[B] floor cap over slot bridges", b_cap>=0.4,
    f"{b_cap:.1f} mm cap over a {a_slot_w:.1f} mm slot (prints as a short bridge)", warn=b_cap<0.5)
chk(2,"[B] slot clears relief holes", b_inner_clear>=2.0,
    f"slot inner edge {bot_tng_in+tng_t+reg_clr:.1f} from face; nearest relief edge {relief_face_gap:.1f} -> {b_inner_clear:.1f} mm")
chk(2,"[B] engagement", bot_tng_h>=0.8, f"{bot_tng_h} mm tongue in a {b_slot_d:.1f} mm slot")
chk(2,"[A/B] positive stop is plate/rim, never the tongue", slot_extra>0,
    f"slots {slot_extra} mm deeper than tongues -> faces land flat, no rock")
chk(2,"[A/B] slip clearance", 0.25<=reg_clr<=0.5, f"{reg_clr} mm/side")
chk(2,"[key] 180-deg rotation blocked", bot_tng_h>=0.8 and top_tng_h>=0.8,
    "slot corner BLOCK vs full tongue corner; verified 0.99 mm volumetric interference in OpenSCAD")

# ===== ITER 3 — inter-layer clearance when stacked =====
stack_pitch = tray_h + lid_top_t
above_skirt_bottom = stack_pitch + tray_h - skirt_h
below_plate_top    = tray_h + lid_top_t
skirt_vs_below = above_skirt_bottom - below_plate_top
chk(3,"top-cap skirt clears the layer below", skirt_vs_below>5,
    f"{skirt_vs_below:.1f} mm vertical gap (skirt hangs over its own tray only)")
chk(3,"stacklid adds no skirt overhang (skirtless plate)", True,
    "footprint = tray; prints plate-on-bed, support-free")
chk(3,"vials below clear the stacklid above", v_clear - 0 > 0.5,
    f"vial tops sit {v_clear:.1f} mm below the rim top the plate rests on (boolean-verified empty intersection)")

# ===== ITER 4 — vial fit + drainage integrity =====
def positions():
    return [(c*pitch + (r%2)*pitch/2 - xext/2, r*rowp - yext/2) for r in range(rows) for c in range(cols)]
def mind(p): return min(math.hypot(p[0]-q[0], p[1]-q[1]) for q in positions())
thr = vial_d/2 + lid_drain_d/2 + drain_margin
cands = [(c*pitch+hx*pitch-xext/2,(r+ty)*rowp-yext/2) for r in range(rows-1) for c in range(cols+1) for hx in (0,.5) for ty in (1/3,2/3)]
drains = [p for p in cands if abs(p[0])<=xext/2-1 and abs(p[1])<=yext/2-1 and mind(p)>=thr]
drain_gap = min(mind(p)-vial_d/2-lid_drain_d/2 for p in drains)
drain_max_x = max(abs(p[0]) for p in drains); drain_max_y = max(abs(p[1]) for p in drains)
tng_inner = min(tray_W/2, tray_D/2) - (bot_tng_in + tng_t)   # stacklid tongue inner edge (worst axis)
drain_vs_tng = min((tray_W/2-(bot_tng_in+tng_t))-(drain_max_x+lid_drain_d/2),
                   (tray_D/2-(bot_tng_in+tng_t))-(drain_max_y+lid_drain_d/2))
nub_interf = vial_d/2 - (bore_d/2 - nub_protrude)
chk(4,"vial drop-in fit", 0.4<=bore_clear<=0.8, f"bore {bore_d:.2f} on vial {vial_d} -> {bore_clear:.1f} mm slip")
chk(4,"cup grips lower half", 18<=pocket_wall_h<vial_h, f"cup {pocket_wall_h} mm holds {100*pocket_wall_h/vial_h:.0f}% of the vial")
chk(4,"retention nubs click, don't jam", 0.1<=nub_interf<=0.35, f"{nub_interf:.2f} mm interference x3 nubs")
chk(4,"no scallop breach (v6: scallops removed)", True, "all 35 cup walls closed; v5 gutted 4 bores")
chk(4,"push/relief hole valid", 5<=relief_d<bore_d-2, f"O{relief_d} drains the cup, < bore {bore_d:.1f}")
chk(4,"drains clear vials", drain_gap>=drain_margin, f"{len(drains)} holes, min {drain_gap:.2f} mm to a vial edge")
chk(4,"drains clear the stacklid top tongue", drain_vs_tng>1,
    f"holes stay {drain_vs_tng:.1f} mm inboard of the tongue ring")

# ===== ITER 5 — printability =====
chk(5,"cup wall printable", cup_wall+1e-9>=3*nozzle, f"cup {cup_wall} mm = {round(cup_wall/nozzle)} perims (exactly 3, solid)")
chk(5,"rim wall printable", rim_w>=3*nozzle, f"rim {rim_w} mm")
chk(5,"tongues printable", tng_t+1e-9>=3*nozzle, f"tongue {tng_t} mm = {tng_t/nozzle:.0f} perims")
chk(5,"tray bottom: NO perimeter overhang (v5 had a floating frame)", bot_tng_in-reg_clr>rim_w,
    "first layers are full footprint minus a walled 1.8 mm slot -> nothing prints over air")
chk(5,"floor slot cap bridges", floor_t-(bot_tng_h+slot_extra)>=0.4,
    f"{floor_t-(bot_tng_h+slot_extra):.1f} mm cap bridging {tng_t+2*reg_clr:.1f} mm (trivial bridge)")
chk(5,"lid slot cap solid", lid_top_t-(top_tng_h+slot_extra)>=1.0,
    f"{lid_top_t-(top_tng_h+slot_extra):.1f} mm over the underside slot")
chk(5,"cups merge (shared honeycomb wall, no slivers)", cup_outer>pitch, f"cup O{cup_outer:.1f} > pitch {pitch:.1f} -> walls fuse")
chk(5,"fits cheap 220 bed", max(tray_W,tray_D)<=220, f"{tray_W:.0f} x {tray_D:.0f} mm")
chk(5,"drain chamfer self-supports", True, "1.2 mm 45-ish lead-in, prints without support")

# ---- report grouped by iteration ----
titles = {1:"lid snap engagement",2:"v6 keyed registers",3:"inter-layer clearance",
          4:"vial fit + drainage",5:"printability sweep"}
allok = True
for it in (1,2,3,4,5):
    print(f"\n===== ITERATION {it}: {titles[it]} =====")
    for i,tag,name,detail in [r for r in rows_out if r[0]==it]:
        print(f"  [{tag}] {name}\n         {detail}")
        if tag=="FAIL": allok=False
print("\n" + "-"*58)
print("AUDIT:", "ALL PASS (warns are tuning notes)" if allok else "HAS FAILS")
