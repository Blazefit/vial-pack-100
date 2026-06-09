#!/usr/bin/env python3
"""Dimensional self-checks — v3 sleeveless interlocking tower (3 trays + snap lid).
Mirrors vial_trays.scad; verifies every fit/clearance closes. Pure geometry."""
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
stack_h = 3*tray_h + lid_top_t

C=[]
def ck(n,ok,d): C.append((n,ok,d))

ck("capacity >= 100", cols*rows*3>=100, f"{cols}x{rows}x3 = {cols*rows*3} pockets")
ck("[#1] vial height clearance", v_clear>=2.5, f"{v_clear} mm gap above vial top")
ck("[#16] cup holds vial securely", 18<=pocket_wall_h<vial_h, f"cup {pocket_wall_h} mm (~{100*pocket_wall_h/vial_h:.0f}%), open above")
ck("[#17] thin cup-tube wall printable", cup_wall>=1.0, f"cup wall {cup_wall} mm")
ck("[#2] tongue/groove engage (slip)", reg_h>=2.5 and reg_clr>0, f"{reg_h} mm engage, {reg_clr} mm clr (lift-apart)")
ck("[#18] lid snaps to top tray", catch_step>=0.8 and skirt_h>6, f"detent {catch_step} mm, skirt {skirt_h} mm")
ck("[#18] lid clears tongue", lid_top_t>=reg_h+0.4, f"lid plate {lid_top_t} >= tongue {reg_h}+0.4")
ck("[#18] bottom layer accessible", reg_clr>0, "no sleeve -> lift the stack apart (slip-fit grooves)")
ck("[#6] pocket lead-in chamfer", pocket_chamfer>=0.8, f"{pocket_chamfer} mm")
ck("[#7] relief/push hole valid", 5<=relief_d<bore_d-2, f"Ø{relief_d} < bore {bore_d:.1f}")
ck("[#8] corner key present", key_sz>=3, f"key {key_sz} mm (+0.8 notch fit)")
ck("[#9] lead-in chamfer", lead_ch>=1.0, f"{lead_ch} mm")
ck("    walls printable", wall_btw>=1.2 and rim_w>=1.2, f"pitch-wall {wall_btw}, rim {rim_w} mm")
ck("    parts fit cheap bed (220mm)", max(tray_W,tray_D)<=BED, f"tray {tray_W:.0f}x{tray_D:.0f} (bed {BED})")
asp = max(tray_W,tray_D,stack_h)/min(tray_W,tray_D,stack_h)
ck("near-cube aspect < 1.4", asp<1.4, f"{tray_W:.0f} x {tray_D:.0f} x {stack_h:.0f} mm, aspect {asp:.2f}")

print("="*58); print("TRAY TOWER v3 (sleeveless) — DIMENSIONAL CHECKS"); print("="*58)
for n,ok,d in C: print(f"[{'PASS' if ok else 'FAIL'}] {n}\n        {d}")
allok=all(o for _,o,_ in C)
print("-"*58); print(f"RESULT: {'PASS' if allok else 'FAIL'}")
print(f"assembled tower ~ {tray_W:.0f} x {tray_D:.0f} x {stack_h:.0f} mm")
sys.exit(0 if allok else 1)
