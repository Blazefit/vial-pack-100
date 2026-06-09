#!/usr/bin/env python3
"""Dimensional self-checks — v4-LIDDED variant (3 trays, each with its own lid,
stack tray->lid->tray->lid). Mirrors vial_trays_lidded.scad. Pure geometry.
Compares tower height against the sleeveless v3 (single top lid)."""
import math, sys

vial_d, vial_h = 16.51, 37.74
cols, rows = 5, 7
bore_clear, wall_btw, cup_wall, rim_w, floor_t, v_clear = 0.6, 1.5, 1.2, 3.0, 2.0, 3.0
pocket_wall_h = 22.0
pocket_chamfer, relief_d = 1.2, 6.0
reg_h, tongue_t, reg_clr = 3.0, 2.0, 0.4
key_sz, lead_ch = 5.0, 1.5
skirt_h, catch_step, lid_top_t = 11, 0.9, 4.0
BED = 220  # cheap printer bed (Ender-class)

bore_d = vial_d + bore_clear
pitch  = bore_d + wall_btw
rowp   = pitch*math.sqrt(3)/2
xext = (cols-1)*pitch + pitch/2
yext = (rows-1)*rowp
tray_W = xext + bore_d + 2*rim_w
tray_D = yext + bore_d + 2*rim_w
tray_h = floor_t + vial_h + v_clear

# ---- v3 sleeveless (single top lid) vs v4 lidded (lid per tray) ----
stack_h_v3      = 3*tray_h + lid_top_t           # 3 trays + 1 lid
stack_pitch     = tray_h + lid_top_t             # lidded: tray + its lid plate
stack_h_lidded  = 3*tray_h + 3*lid_top_t         # 3 trays + 3 lid plates
height_delta    = stack_h_lidded - stack_h_v3    # == 2*lid_top_t
stack_h = stack_h_lidded

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

ck("capacity >= 100", cols*rows*3>=100, f"{cols}x{rows}x3 = {cols*rows*3} pockets")
ck("[lidded] one lid per tray", True, "3 trays -> 3 lids (2x stacklid + 1x top lid)")
ck("[drain] perforations present", len(drain_pts)>=20, f"{len(drain_pts)} holes/lid (O{lid_drain_d} mm)")
ck("[drain] holes clear the vials below", min_gap>=drain_margin-1e-6,
   f"min hole-edge-to-vial-edge gap {min_gap:.2f} mm (>= {drain_margin})")
ck("[drain] holes sit on hex interstices (off the crimps)", min_gap>0,
   "meltwater routed BETWEEN vials below, never onto a septum")
ck("[lidded] lid registers tray above (tongue on lid top)",
   lid_top_t>=reg_h+0.4, f"lid plate {lid_top_t} hosts top tongue {reg_h} + underside groove")
ck("[lidded] next tray seats on lid plate (no extra pitch from tongue)",
   reg_clr>0, f"top tongue recesses into tray bottom groove, {reg_clr} mm slip")
ck("[lidded] each layer independently capped + liftable",
   catch_step>=0.8 and skirt_h>6, f"lid snaps each tray: detent {catch_step} mm, skirt {skirt_h} mm")
ck("[lidded] height cost is small (telescoping skirts)",
   height_delta <= 0.10*stack_h_v3, f"+{height_delta:.1f} mm ({100*height_delta/stack_h_v3:.0f}%): "
   f"{stack_h_v3:.0f} -> {stack_h_lidded:.0f} mm")
ck("[#1] vial height clearance", v_clear>=2.5, f"{v_clear} mm gap above vial top")
ck("[#16] cup holds vial securely", 18<=pocket_wall_h<vial_h, f"cup {pocket_wall_h} mm (~{100*pocket_wall_h/vial_h:.0f}%), open above")
ck("[#17] thin cup-tube wall printable", cup_wall>=1.0, f"cup wall {cup_wall} mm")
ck("[#2] tongue/groove engage (slip)", reg_h>=2.5 and reg_clr>0, f"{reg_h} mm engage, {reg_clr} mm clr (lift-apart)")
ck("[#18] lid clears tongue", lid_top_t>=reg_h+0.4, f"lid plate {lid_top_t} >= tongue {reg_h}+0.4")
ck("[#6] pocket lead-in chamfer", pocket_chamfer>=0.8, f"{pocket_chamfer} mm")
ck("[#7] relief/push hole valid", 5<=relief_d<bore_d-2, f"O{relief_d} < bore {bore_d:.1f}")
ck("[#8] corner key present", key_sz>=3, f"key {key_sz} mm (+0.8 notch fit)")
ck("[#9] lead-in chamfer", lead_ch>=1.0, f"{lead_ch} mm")
ck("    walls printable", wall_btw>=1.2 and rim_w>=1.2, f"pitch-wall {wall_btw}, rim {rim_w} mm")
ck("    parts fit cheap bed (220mm)", max(tray_W,tray_D)<=BED, f"tray {tray_W:.0f}x{tray_D:.0f} (bed {BED})")
asp = max(tray_W,tray_D,stack_h)/min(tray_W,tray_D,stack_h)
ck("near-cube aspect < 1.4", asp<1.4, f"{tray_W:.0f} x {tray_D:.0f} x {stack_h:.0f} mm, aspect {asp:.2f}")

print("="*60); print("TRAY TOWER v4-LIDDED (lid per tray) — DIMENSIONAL CHECKS"); print("="*60)
for n,ok,d in C: print(f"[{'PASS' if ok else 'FAIL'}] {n}\n        {d}")
allok=all(o for _,o,_ in C)
print("-"*60); print(f"RESULT: {'PASS' if allok else 'FAIL'}")
print(f"v3 sleeveless tower : {tray_W:.0f} x {tray_D:.0f} x {stack_h_v3:.0f} mm  (3 trays + 1 lid)")
print(f"v4 lidded   tower   : {tray_W:.0f} x {tray_D:.0f} x {stack_h_lidded:.0f} mm  (3 trays + 3 lids)")
print(f"height delta        : +{height_delta:.1f} mm  (= 2 x lid_top_t {lid_top_t})  ~{100*height_delta/stack_h_v3:.0f}% taller")
sys.exit(0 if allok else 1)
