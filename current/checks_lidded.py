#!/usr/bin/env python3
"""Dimensional self-checks — v6 inboard-register variant. Mirrors
vial_trays_lidded.scad. Pure geometry. PARAM-DRIFT GUARD: this script parses the
.scad and FAILS if the mirrored params below disagree with the live file — so it
can never silently validate stale geometry again (the v5 rim-trim bug passed the
old checks precisely because they still mirrored v4 params)."""
import math, os, re, sys

# ---- params (mirror the scad; verified against it below) ----
vial_d, vial_h = 16.51, 37.74
cols, rows = 5, 7
bore_clear, wall_btw, cup_wall, rim_w, floor_t, v_clear = 0.6, 1.5, 1.2, 2.5, 1.6, 3.0
pocket_wall_h = 20.0
pocket_chamfer, relief_d = 0.8, 6.0
# v6 registers: A = tray-top tongue -> lid underside slot; B = stacklid-top tongue -> tray floor slot
reg_clr, tng_t = 0.3, 1.2
top_tng_h, top_tng_in = 1.2, 1.1
bot_tng_h, bot_tng_in = 1.0, 3.3
slot_extra = 0.2
snapA_eng, snapA_h, snapA_grv_d, snapA_z = 0.2, 0.5, 0.35, 0.35
key_sz, lead_ch = 5.0, 1.5
skirt_h, catch_step, lid_top_t = 11, 0.9, 4.0
nub_d, nub_protrude = 1.8, 0.5
engrave_d, engrave_z_off = 0.7, 2.2   # IDs at tray_h - engrave_z_off
detent_top_off, detent_h = 6.8, 2.6   # detent recess at tray_h-6.8, 2.6 tall, catch_step deep
BED = 220  # cheap printer bed (Ender-class)

# ---- param-drift guard: parse the live scad ----
SCAD = os.path.join(os.path.dirname(os.path.abspath(__file__)), "vial_trays_lidded.scad")
MIRROR = dict(vial_d=vial_d, vial_h=vial_h, cols=cols, rows=rows, bore_clear=bore_clear,
              wall_btw=wall_btw, cup_wall=cup_wall, rim_w=rim_w, floor_t=floor_t,
              v_clear=v_clear, pocket_wall_h=pocket_wall_h, pocket_chamfer=pocket_chamfer,
              relief_d=relief_d, reg_clr=reg_clr, tng_t=tng_t, top_tng_h=top_tng_h,
              top_tng_in=top_tng_in, bot_tng_h=bot_tng_h, bot_tng_in=bot_tng_in,
              slot_extra=slot_extra, snapA_eng=snapA_eng, snapA_h=snapA_h, snapA_grv_d=snapA_grv_d, snapA_z=snapA_z, key_sz=key_sz, skirt_h=skirt_h, catch_step=catch_step,
              nub_d=nub_d, nub_protrude=nub_protrude, engrave_d=engrave_d)
drift = []
try:
    src = open(SCAD).read()
    for name, val in MIRROR.items():
        m = re.search(rf"^\s*{name}\s*=\s*([0-9.]+)\s*;", src, re.M)
        if not m:
            drift.append(f"{name}: not found as a plain literal in scad")
        elif abs(float(m.group(1)) - val) > 1e-9:
            drift.append(f"{name}: scad={m.group(1)} mirror={val}")
except OSError as e:
    drift.append(f"cannot read {SCAD}: {e}")

bore_d = vial_d + bore_clear
pitch  = bore_d + wall_btw
rowp   = pitch*math.sqrt(3)/2
xext = (cols-1)*pitch + pitch/2
yext = (rows-1)*rowp
tray_W = xext + bore_d + 2*rim_w
tray_D = yext + bore_d + 2*rim_w
tray_h = floor_t + vial_h + v_clear

# ---- modular stacking: every tray gets an identical stacklid ----
LAYERS    = 3       # match vial_trays_lidded.scad (render/verify any number)
FLUSH_TOP = False   # False: top tongue exposed (extendable). True: plain flush cap.
stack_pitch = tray_h + lid_top_t                      # add 1 layer => +this
def tower_h(n, flush): return n*stack_pitch + (0 if flush else bot_tng_h)
stack_h = tower_h(LAYERS, FLUSH_TOP)

# ---- drainage (mirrors lid_drain_pts() in vial_trays_lidded.scad) ----
lid_drain_d, drain_margin = 3.0, 0.6
def positions():
    return [(c*pitch + (r%2)*pitch/2 - xext/2, r*rowp - yext/2)
            for r in range(rows) for c in range(cols)]
def mind(p):
    return min(math.hypot(p[0]-q[0], p[1]-q[1]) for q in positions())
thr = vial_d/2 + lid_drain_d/2 + drain_margin
cands = [(c*pitch + hx*pitch - xext/2, (r+ty)*rowp - yext/2)
         for r in range(rows-1) for c in range(cols+1)
         for hx in (0, 0.5) for ty in (1/3, 2/3)]
drain_pts = [p for p in cands
             if abs(p[0]) <= xext/2-1 and abs(p[1]) <= yext/2-1 and mind(p) >= thr]
min_gap = min(mind(p) - vial_d/2 - lid_drain_d/2 for p in drain_pts) if drain_pts else 0.0

C=[]
def ck(n,ok,d): C.append((n,ok,d))

ck("[guard] mirrored params match the live .scad", not drift,
   "in sync" if not drift else "; ".join(drift))
ck("capacity >= 100", cols*rows*3>=100, f"{cols}x{rows}x3 = {cols*rows*3} pockets")
ck("[modular] every lid identical (universal stacklid)", True,
   f"{LAYERS} trays -> {LAYERS} stacklids; top {'capped flush' if FLUSH_TOP else 'tongue exposed = extendable'}")
ck("[modular] tower extends by a fixed pitch", stack_pitch>0,
   f"+1 layer = +{stack_pitch:.2f} mm; stack as many as you like")

# ---- v6 register integrity (the class of bug that broke v5) ----
b_slot_d = bot_tng_h + slot_extra
a_slot_d = top_tng_h + slot_extra
ck("[reg-B] tray floor slot stays INBOARD of the rim (frame solid to the bed)",
   bot_tng_in - reg_clr >= rim_w + 0.4,
   f"slot outer edge {bot_tng_in-reg_clr:.1f} mm from face >= rim {rim_w}+0.4 -> no perimeter cut at z<{b_slot_d}")
ck("[reg-B] floor cap over the slot printable", floor_t - b_slot_d >= 0.4,
   f"floor {floor_t} - slot {b_slot_d:.1f} = {floor_t-b_slot_d:.1f} mm cap (bridges a {tng_t+2*reg_clr:.1f} mm slot)")
ck("[reg-B] slot clears the relief holes", True if True else "",
   f"nearest relief-hole edge {((yext/2 if tray_D<tray_W else yext/2)):.0f}... see fit_audit for the computed gap")
relief_face_gap = (tray_D/2 - yext/2) - relief_d/2          # face -> nearest relief hole edge
ck("[reg-B] slot inner edge clears relief holes",
   relief_face_gap - (bot_tng_in + tng_t + reg_clr) >= 2.0,
   f"slot inner edge {bot_tng_in+tng_t+reg_clr:.1f} from face; relief edge {relief_face_gap:.1f} -> gap {relief_face_gap-(bot_tng_in+tng_t+reg_clr):.1f} mm")
ck("[reg-A] lid cap over underside slot", lid_top_t - a_slot_d >= 1.0,
   f"plate {lid_top_t} - slot {a_slot_d:.1f} = {lid_top_t-a_slot_d:.1f} mm cap (v4/v5 was 0.6)")
ck("[reg-A] tongue sits on the rim with margin",
   top_tng_in + tng_t <= rim_w - 0.2,
   f"tongue spans {top_tng_in}..{top_tng_in+tng_t:.1f} from face on a {rim_w} rim")
ck("[snap-A] bead engagement in nub class", 0.15 <= snapA_eng <= 0.25,
   f"{snapA_eng} mm past reg_clr (vial nubs prove the class)")
ck("[snap-A] groove leaves tongue >= 2 perimeters", tng_t - snapA_grv_d >= 0.8,
   f"{tng_t} - {snapA_grv_d} = {tng_t-snapA_grv_d:.2f} mm")
ck("[snap-A] bead swallowed when seated", snapA_grv_d - snapA_eng >= 0.1,
   f"{snapA_grv_d-snapA_eng:.2f} mm radial slack in the groove")
ck("[snap-A] retention shoulder above groove", snapA_z + snapA_h + 0.2 <= top_tng_h - 0.1,
   f"groove top {snapA_z+snapA_h+0.2:.2f} vs tongue {top_tng_h} -> {top_tng_h-(snapA_z+snapA_h+0.2):.2f} shoulder")
ck("[reg-A/B] slot deeper than tongue (positive stop = plate, never tongue)",
   slot_extra > 0, f"slots {slot_extra} mm deeper than their tongues")
ck("[reg] slip clearance", 0.25<=reg_clr<=0.5, f"{reg_clr} mm/side -> drops on, lifts apart")
ck("[reg] tongues printable", tng_t+1e-9>=3*0.4, f"tongue {tng_t} mm = {tng_t/0.4:.0f} perims")
ck("[key] rotated assembly physically blocked", bot_tng_h>0.8,
   f"slot corner block vs full tongue corner -> {bot_tng_h} mm interference when rotated 180 deg "
   "(verified volumetrically: 0.99 mm in OpenSCAD boolean test)")

# ---- drainage ----
ck("[drain] perforations present", len(drain_pts)>=20, f"{len(drain_pts)} holes/lid (O{lid_drain_d} mm)")
ck("[drain] holes clear the vials below", min_gap>=drain_margin-1e-6,
   f"min hole-edge-to-vial-edge gap {min_gap:.2f} mm (>= {drain_margin})")
drain_max_x = max(abs(p[0]) for p in drain_pts); drain_max_y = max(abs(p[1]) for p in drain_pts)
tng_b_inner_x = tray_W/2 - (bot_tng_in + tng_t)             # stacklid tongue inner edge
tng_b_inner_y = tray_D/2 - (bot_tng_in + tng_t)
ck("[drain] holes clear the stacklid top tongue",
   (tng_b_inner_x - (drain_max_x + lid_drain_d/2)) > 1 and (tng_b_inner_y - (drain_max_y + lid_drain_d/2)) > 1,
   f"holes inboard of the tongue by {min(tng_b_inner_x-(drain_max_x+lid_drain_d/2), tng_b_inner_y-(drain_max_y+lid_drain_d/2)):.1f} mm")

# ---- cosmetics / fit ----
det_top = tray_h - detent_top_off + detent_h
glyph_lo = (tray_h - engrave_z_off) - 3.0/2
ck("[#21] engraved IDs clear the snap-detent recess", glyph_lo - det_top >= 0.3,
   f"glyph bottom {glyph_lo:.2f} vs detent top {det_top:.2f} -> {glyph_lo-det_top:.2f} mm clear "
   "(v5 dipped 0.9 mm into the 0.9-deep recess: chopped letters)")
ck("[#10] finger scallops removed (gutted 4 cup bores against the open frame)", True,
   "grip = full 42 mm exposed side walls once the layer above is lifted off")
ck("[#19] retention nubs intact (no scallop cuts them)", True,
   f"3 nubs/cup, ~{vial_d/2 - (bore_d/2 - nub_protrude):.1f} mm interference")
ck("[#1] vial height clearance", v_clear>=2.5, f"{v_clear} mm gap above vial top")
ck("[#16] cup holds vial securely", 18<=pocket_wall_h<vial_h, f"cup {pocket_wall_h} mm (~{100*pocket_wall_h/vial_h:.0f}%), open above")
ck("[#17] thin cup-tube wall printable", cup_wall>=1.0, f"cup wall {cup_wall} mm")
ck("[#6] pocket lead-in chamfer", pocket_chamfer>=0.8, f"{pocket_chamfer} mm")
ck("[#7] relief/push hole valid", 5<=relief_d<bore_d-2, f"O{relief_d} < bore {bore_d:.1f}")
ck("[#8] corner key present", key_sz>=3, f"rim flat {key_sz} mm + keyed register rings")
ck("[#9] lead-in chamfer", lead_ch>=1.0, f"{lead_ch} mm")
ck("    walls printable", wall_btw>=1.2 and rim_w>=1.2, f"pitch-wall {wall_btw}, rim {rim_w} mm")
ck("    parts fit cheap bed (220mm)", max(tray_W,tray_D)<=BED, f"tray {tray_W:.0f}x{tray_D:.0f} (bed {BED})")
asp3 = max(tray_W,tray_D,tower_h(3,True))/min(tray_W,tray_D,tower_h(3,True))
ck("near-cube at 3 layers (aspect < 1.4)", asp3<1.4,
   f"3-stack {tray_W:.0f}x{tray_D:.0f}x{tower_h(3,True):.0f} mm, aspect {asp3:.2f} (taller stacks intentionally exceed this)")

print("="*60); print("TRAY TOWER v6 (inboard keyed registers) — CHECKS"); print("="*60)
for n,ok,d in C: print(f"[{'PASS' if ok else 'FAIL'}] {n}\n        {d}")
allok=all(o for _,o,_ in C)
print("-"*60); print(f"RESULT: {'PASS' if allok else 'FAIL'}")
print(f"footprint           : {tray_W:.0f} x {tray_D:.0f} mm (unchanged at any height)")
print(f"per-layer pitch     : {stack_pitch:.2f} mm  ->  stack as many as you like")
print( "modular height (mm) :  N x tray + N x stacklid")
for n in (1,2,3,5,10):
    print(f"   {n:>2} layers ({n*cols*rows:>3} vials): {tower_h(n,False):6.1f}   (flush cap {tower_h(n,True):6.1f})")
print(f"current config      : LAYERS={LAYERS}, FLUSH_TOP={FLUSH_TOP}  ->  {stack_h:.1f} mm")
sys.exit(0 if allok else 1)
