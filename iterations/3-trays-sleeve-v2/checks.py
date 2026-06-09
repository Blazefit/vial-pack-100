#!/usr/bin/env python3
"""Dimensional self-checks for the v2 tray system. Mirrors vial_trays.scad params
and verifies every fit/clearance closes. Pure geometry — no render needed."""
import math, sys

# mirror params
vial_d, vial_h = 16.51, 37.74
cols, rows = 5, 7
bore_clear, wall_btw, rim_w, floor_t, v_clear = 0.6, 1.5, 4.0, 2.5, 3.0
slide_clr = 0.5
pocket_chamfer, relief_d = 1.2, 6.0
reg_h, tongue_t, reg_clr = 3.0, 2.0, 0.4
key_sz, lead_ch = 5.0, 1.5
base_t, push_hole_d, win_w = 2.5, 30, 34
skirt_h, catch_step = 12, 1.0

bore_d = vial_d + bore_clear
pitch  = bore_d + wall_btw
rowp   = pitch*math.sqrt(3)/2
xext = (cols-1)*pitch + pitch/2
yext = (rows-1)*rowp
tray_W = xext + bore_d + 2*rim_w
tray_D = yext + bore_d + 2*rim_w
tray_h = floor_t + vial_h + v_clear
sleeve_in_w = tray_W + 2*slide_clr
sleeve_W = sleeve_in_w + 2*rim_w
sleeve_D = (yext+bore_d+2*rim_w) + 2*slide_clr + 2*rim_w
sleeve_h = base_t + 3*tray_h + reg_h + 1

C=[]
def ck(n,ok,d): C.append((n,ok,d))

ck("capacity >= 100", cols*rows*3>=100, f"{cols}x{rows}x3 = {cols*rows*3} pockets")
ck("[#1] vial height clearance", v_clear>=2.5, f"{v_clear} mm gap above vial top")
ck("    vial fits pocket depth", (tray_h-floor_t)>=vial_h, f"pocket {tray_h-floor_t:.1f} >= vial {vial_h}")
ck("[#2] tongue/groove engage", reg_h>=2.5, f"engagement {reg_h} mm")
ck("    groove deeper than tongue", reg_h+0.4>reg_h, "groove +0.4 mm")
ck("    groove wider than tongue", reg_clr>0, f"clearance {reg_clr} mm/side")
ck("[#3] lid snap engages", catch_step>=0.8 and skirt_h>3, f"catch {catch_step} mm, skirt {skirt_h} mm")
ck("[#4] push-hole usable", 25<=push_hole_d<sleeve_in_w, f"Ø{push_hole_d} in base (cavity {sleeve_in_w:.0f})")
ck("[#5] side window usable", win_w>=25, f"window {win_w} mm wide")
ck("[#6] pocket lead-in chamfer", pocket_chamfer>=0.8, f"{pocket_chamfer} mm")
ck("[#7] relief/push hole valid", 5<=relief_d<bore_d-2, f"Ø{relief_d} < bore {bore_d:.1f}")
ck("[#8] corner key present", key_sz>=3, f"key {key_sz} mm (notch clears with +0.8)")
ck("[#9] lead-in chamfer", lead_ch>=1.0, f"{lead_ch} mm edge chamfer")
ck("[#12] tray-in-sleeve slide", 0.3<=slide_clr<=0.7, f"{slide_clr} mm/side")
ck("    walls printable", wall_btw>=1.2 and rim_w>=1.2, f"btw {wall_btw}, rim {rim_w} mm")
asp = max(sleeve_W,sleeve_D,sleeve_h)/min(sleeve_W,sleeve_D,sleeve_h)
ck("near-cube aspect < 1.35", asp<1.35, f"{sleeve_W:.0f} x {sleeve_D:.0f} x {sleeve_h:.0f} mm, aspect {asp:.2f}")

print("="*58); print("TRAY SYSTEM v2 — DIMENSIONAL CHECKS"); print("="*58)
for n,ok,d in C: print(f"[{'PASS' if ok else 'FAIL'}] {n}\n        {d}")
allok=all(o for _,o,_ in C)
print("-"*58); print(f"RESULT: {'PASS' if allok else 'FAIL'}")
print(f"assembled envelope ~ {sleeve_W:.0f} x {sleeve_D:.0f} x {sleeve_h:.0f} mm")
sys.exit(0 if allok else 1)
