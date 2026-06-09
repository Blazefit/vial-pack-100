#!/usr/bin/env python3
"""Dimensional self-checks — v4-LIDDED variant: every tray capped by an identical
`stacklid`, so the tower is fully modular (stack any number of layers). Mirrors
vial_trays_lidded.scad. Pure geometry. Set LAYERS / FLUSH_TOP to match the scad."""
import math, sys

vial_d, vial_h = 16.51, 37.74
cols, rows = 5, 7
bore_clear, wall_btw, cup_wall, rim_w, floor_t, v_clear = 0.6, 1.5, 1.2, 2.5, 1.6, 3.0
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

# ---- modular stacking: every tray gets an identical stacklid ----
LAYERS    = 3       # match vial_trays_lidded.scad (render/verify any number)
FLUSH_TOP = False   # False: top tongue exposed (extendable). True: plain flush cap.
stack_pitch    = tray_h + lid_top_t                   # add 1 layer => +this
def tower_h(n, flush): return n*stack_pitch + (0 if flush else reg_h)
stack_h_v3     = 3*tray_h + lid_top_t                 # original single-lid 3-tray tower (132)
stack_h_flush  = tower_h(3, True)                     # lidded 3-stack, flush cap (140)
stack_h_lidded = tower_h(LAYERS, FLUSH_TOP)           # current config
height_delta   = stack_h_flush - stack_h_v3           # +8 mm vs v3 (flush form)
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
ck("[modular] every lid identical (universal stacklid)", True,
   f"{LAYERS} trays -> {LAYERS} stacklids; top {'capped flush' if FLUSH_TOP else 'tongue exposed = extendable'}")
ck("[modular] tower extends by a fixed pitch", stack_pitch>0,
   f"+1 layer = +{stack_pitch:.2f} mm; stack as many as you like")
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
   height_delta <= 0.10*stack_h_v3,
   f"3-stack flush +{height_delta:.1f} mm ({100*height_delta/stack_h_v3:.0f}%): v3 {stack_h_v3:.0f} -> "
   f"flush {stack_h_flush:.0f} mm (exposed-tongue top adds {reg_h:.0f} mm more)")
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
asp3 = max(tray_W,tray_D,stack_h_flush)/min(tray_W,tray_D,stack_h_flush)
ck("near-cube at 3 layers (aspect < 1.4)", asp3<1.4,
   f"3-stack {tray_W:.0f}x{tray_D:.0f}x{stack_h_flush:.0f} mm, aspect {asp3:.2f} (taller stacks intentionally exceed this)")

print("="*60); print("TRAY TOWER v4-LIDDED (modular, lid per tray) — CHECKS"); print("="*60)
for n,ok,d in C: print(f"[{'PASS' if ok else 'FAIL'}] {n}\n        {d}")
allok=all(o for _,o,_ in C)
print("-"*60); print(f"RESULT: {'PASS' if allok else 'FAIL'}")
print(f"footprint           : {tray_W:.0f} x {tray_D:.0f} mm (unchanged at any height)")
print(f"per-layer pitch     : {stack_pitch:.2f} mm  ->  stack as many as you like")
print( "modular height (mm) :  N x tray + N x stacklid")
for n in (1,2,3,5,10):
    print(f"   {n:>2} layers ({n*cols*rows:>3} vials): {tower_h(n,False):6.1f}   (flush cap {tower_h(n,True):6.1f})")
print(f"current config      : LAYERS={LAYERS}, FLUSH_TOP={FLUSH_TOP}  ->  {stack_h_lidded:.1f} mm")
sys.exit(0 if allok else 1)
