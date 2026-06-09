// =====================================================================
// 100x 3 mL vial freezer container — INDIVIDUAL-HOLDER stacking trays  v2
// Each vial in its OWN pocket on its OWN floor. 3 identical 5x7 hex trays
// (35 pockets, 105 total) stack inside a sleeve -> near-cube. Snap lid.
// Vial Ø16.51 x 37.74 mm.  Render each part via its *_part.scad wrapper.
//   v2 adds: vial height clearance, stacking tongue/groove, snap lid,
//   sleeve push-hole + side windows, pocket chamfer + relief hole,
//   corner key, lead-in chamfers, finger grips, dimensional checks.
// =====================================================================
$fn = 48;

// ---- vial + grid ----
vial_d   = 16.51;
vial_h   = 37.74;
cols     = 5;
rows     = 7;

// ---- fits / walls ----
bore_clear = 0.6;     // vial radial fit (drop-in)
wall_btw   = 1.5;     // interstitial wall between pockets
rim_w      = 4.0;     // perimeter frame width (hosts tongue/groove)
floor_t    = 2.5;     // tray floor
v_clear    = 3.0;     // [#1] vertical clearance above each vial
corner_r   = 4.0;
slide_clr  = 0.5;     // [#12] tray-in-sleeve slide fit

// ---- features ----
pocket_chamfer = 1.2; // [#6] lead-in at pocket mouth
relief_d       = 6.0; // [#7] push/drain hole at pocket bottom
reg_h          = 3.0; // [#2] tongue height / groove depth
tongue_t       = 2.0; // [#2] tongue thickness
reg_clr        = 0.4; // [#12] tongue/groove clearance
key_sz         = 5.0; // [#8] corner key size
lead_ch        = 1.5; // [#9/#13] lead-in / edge chamfers
scallop_d      = 20;  // [#10] finger scallop

// ---- sleeve / lid ----
base_t      = 2.5;
push_hole_d = 30;     // [#4] bottom-layer push hole
win_w       = 34;     // [#5] side window width
skirt_h     = 12;     // [#3] lid skirt
catch_step  = 1.0;    // [#3] snap catch depth
lid_top_t   = 2.5;

// ---- derived ----
bore_d  = vial_d + bore_clear;
pitch   = bore_d + wall_btw;
rowp    = pitch*sqrt(3)/2;
xext = (cols-1)*pitch + pitch/2;
yext = (rows-1)*rowp;
function positions() = [ for (r=[0:rows-1], c=[0:cols-1])
    [ c*pitch + (r%2)*pitch/2 - xext/2, r*rowp - yext/2 ] ];

tray_W = xext + bore_d + 2*rim_w;
tray_D = yext + bore_d + 2*rim_w;
tray_h = floor_t + vial_h + v_clear;           // wall top sits v_clear above vial

sleeve_in_w = tray_W + 2*slide_clr;
sleeve_in_d = tray_D + 2*slide_clr;
sleeve_W = sleeve_in_w + 2*rim_w;
sleeve_D = sleeve_in_d + 2*rim_w;
sleeve_h = base_t + 3*tray_h + reg_h + 1;      // base + 3 trays (+top tongue room)

// ---- 2D helpers ----
module rr(w,d,r) offset(r) square([max(0.1,w-2*r), max(0.1,d-2*r)], center=true);
module ring(w,d,r,inset_out,thick)             // perimeter ring band
    difference(){ offset(-inset_out) rr(w,d,r); offset(-(inset_out+thick)) rr(w,d,r); }

tongue_off = (rim_w - tongue_t)/2;             // center the tongue in the rim

// ---- corner key: a vertical rib (sleeve) / notch (tray) at +x+y corner ----
module corner_key_solid(h, sz)
    translate([tray_W/2 - rim_w/2, tray_D/2 - rim_w/2, 0])
        rotate([0,0,45]) translate([-sz/2,-sz/2,0]) cube([sz,sz,h]);

// =====================================================================
module tray() {
    difference() {
        union() {
            // frame body with chamfered top edge
            hull() {
                linear_extrude(tray_h-lead_ch) rr(tray_W, tray_D, corner_r);
                linear_extrude(tray_h)        rr(tray_W-2*lead_ch, tray_D-2*lead_ch, corner_r);
            }
            // [#2] top tongue ring
            translate([0,0,tray_h-0.01])
                linear_extrude(reg_h) ring(tray_W,tray_D,corner_r,tongue_off,tongue_t);
        }
        // pockets: bore + [#6] mouth chamfer + [#7] relief hole
        for (p=positions()) {
            translate([p[0],p[1],floor_t]) cylinder(d=bore_d, h=tray_h);
            translate([p[0],p[1],tray_h-pocket_chamfer+0.01])
                cylinder(d1=bore_d, d2=bore_d+2*pocket_chamfer, h=pocket_chamfer);
            translate([p[0],p[1],-1]) cylinder(d=relief_d, h=floor_t+2);
        }
        // [#2] bottom groove ring (receives tongue of tray below)
        translate([0,0,-0.01])
            linear_extrude(reg_h+0.4)
                ring(tray_W,tray_D,corner_r,tongue_off-reg_clr,tongue_t+2*reg_clr);
        // [#10] finger scallops on long sides
        for (s=[-1,1]) translate([0,s*tray_D/2,tray_h*0.6])
            rotate([90,0,0]) scale([1.8,1,1]) sphere(d=scallop_d);
        // [#8] corner key NOTCH (clears the sleeve rib; +0.8 fit)
        corner_key_solid(tray_h+reg_h+1, key_sz+0.8);
    }
}

// =====================================================================
module sleeve() {
    difference() {
        union() {
            linear_extrude(sleeve_h) rr(sleeve_W, sleeve_D, corner_r+rim_w);
            // [#3] catch lip: outward bead near the top for the lid to snap under
            translate([0,0,sleeve_h-3])
                linear_extrude(3) difference(){
                    offset(catch_step) rr(sleeve_W,sleeve_D,corner_r+rim_w);
                    rr(sleeve_W-2*rim_w, sleeve_D-2*rim_w, corner_r); }
        }
        // inner cavity
        translate([0,0,base_t]) linear_extrude(sleeve_h) rr(sleeve_in_w, sleeve_in_d, corner_r);
        // [#4] push-hole in base
        translate([0,0,-1]) cylinder(d=push_hole_d, h=base_t+2);
        // [#5] side windows (short ends) so all trays incl. bottom are reachable
        for (s=[-1,1]) translate([s*sleeve_W/2, 0, base_t+ tray_h*0.5])
            rotate([0,90,0]) translate([0,0,-rim_w-1])
                linear_extrude(rim_w+2) offset(4) square([2.4*tray_h, win_w], center=true);
    }
    // [#8] corner key RIB into the cavity — only the keyed (notched) tray clears it
    intersection() {
        corner_key_solid(sleeve_h, key_sz);
        translate([0,0,base_t]) linear_extrude(sleeve_h) rr(sleeve_in_w, sleeve_in_d, corner_r);
    }
}

// =====================================================================
module lid() {
    skirt_in_w = sleeve_W + 2*0.3;     // friction over sleeve outer
    skirt_in_d = sleeve_D + 2*0.3;
    difference() {
        union() {
            // top plate
            linear_extrude(lid_top_t) rr(skirt_in_w+2*rim_w, skirt_in_d+2*rim_w, corner_r+rim_w);
            // skirt
            translate([0,0,-skirt_h]) linear_extrude(skirt_h)
                difference(){ rr(skirt_in_w+2*rim_w, skirt_in_d+2*rim_w, corner_r+rim_w);
                              rr(skirt_in_w, skirt_in_d, corner_r); }
        }
        // [#3] inner catch bead near skirt bottom (snaps under sleeve lip)
        translate([0,0,-skirt_h+1]) linear_extrude(2.2)
            difference(){ rr(skirt_in_w, skirt_in_d, corner_r);
                          offset(-catch_step) rr(skirt_in_w, skirt_in_d, corner_r); }
        // [#11] grip recess on top
        translate([0,0,lid_top_t-1]) linear_extrude(1.5)
            difference(){ rr(skirt_in_w*0.5, skirt_in_d*0.5, 8);
                          rr(skirt_in_w*0.5-6, skirt_in_d*0.5-6, 6); }
    }
}

// ---- part dispatch (read-only selector; never re-assign PART) ----
part_sel = is_undef(PART) ? "tray" : PART;
if (part_sel=="tray") tray();
else if (part_sel=="sleeve") sleeve();
else if (part_sel=="lid") lid();
else if (part_sel=="assembly") {
    color("gray")   sleeve();
    for (i=[0:2]) translate([0,0,base_t + i*tray_h]) color(i%2?"steelblue":"slategray") tray();
    translate([0,0,sleeve_h]) color("seagreen") lid();
}
