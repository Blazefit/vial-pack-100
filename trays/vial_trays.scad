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
wall_btw   = 1.5;     // hex pitch spacing between pockets
cup_wall   = 1.2;     // [#17] thin cup-tube wall (light)
rim_w      = 3.0;     // perimeter frame width (hosts tongue/groove)
floor_t    = 2.0;     // tray floor
v_clear    = 3.0;     // [#1] vertical clearance above each vial
pocket_wall_h = 22.0; // [#16] cup depth: holds vial's lower half; open above = less plastic
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

// ---- lid (clips onto the TOP tray; no sleeve — [#18] sleeve removed) ----
skirt_h     = 11;     // [#3] lid skirt over the top tray
catch_step  = 0.9;    // [#3] snap catch depth
lid_top_t   = 4.0;

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

stack_h = 3*tray_h + lid_top_t;                // [#18] tower height (3 trays + lid)

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
            // [#17] thin floor plate (chamfered edge) — relief holes punched later
            hull() {
                linear_extrude(floor_t-0.6) rr(tray_W, tray_D, corner_r);
                linear_extrude(floor_t)     rr(tray_W-1.2, tray_D-1.2, corner_r);
            }
            // [#17] thin-wall cup TUBES (open between cups -> ~half the plastic)
            for (p=positions()) translate([p[0],p[1],floor_t-0.01])
                cylinder(d=bore_d+2*cup_wall, h=pocket_wall_h);
            // perimeter FRAME ring (full height) carries the stack + hosts grooves
            translate([0,0,floor_t-0.01])
                linear_extrude(tray_h-floor_t) ring(tray_W,tray_D,corner_r,0,rim_w);
            // [#2] top tongue ring
            translate([0,0,tray_h-0.01])
                linear_extrude(reg_h) ring(tray_W,tray_D,corner_r,tongue_off,tongue_t);
        }
        // cups: bore + [#6] mouth chamfer + [#7] relief/push hole
        for (p=positions()) {
            translate([p[0],p[1],floor_t]) cylinder(d=bore_d, h=pocket_wall_h+0.1);
            translate([p[0],p[1],floor_t+pocket_wall_h-pocket_chamfer+0.01])
                cylinder(d1=bore_d, d2=bore_d+2*pocket_chamfer, h=pocket_chamfer);
            translate([p[0],p[1],-1]) cylinder(d=relief_d, h=floor_t+2);
        }
        // [#2] bottom groove ring (receives tongue of tray below)
        translate([0,0,-0.01])
            linear_extrude(reg_h+0.4)
                ring(tray_W,tray_D,corner_r,tongue_off-reg_clr,tongue_t+2*reg_clr);
        // [#10] finger scallops on the cup-block long sides
        for (s=[-1,1]) translate([0,s*tray_D/2,(floor_t+pocket_wall_h)*0.55])
            rotate([90,0,0]) scale([1.8,1,1]) sphere(d=scallop_d);
        // [#8] corner key NOTCH (trays seat one way; +0.8 fit)
        corner_key_solid(tray_h+reg_h+1, key_sz+0.8);
        // [#18] lid-snap detent: shallow recess on the outer face near the top
        translate([0,0,tray_h-7]) linear_extrude(3)
            difference(){ rr(tray_W,tray_D,corner_r);
                          offset(-catch_step) rr(tray_W,tray_D,corner_r); }
    }
}

// =====================================================================
// [#18] LID — clips onto the TOP tray (no sleeve). Tongue-groove register +
// friction skirt + snap bead into the tray's outer detent.
module lid() {
    sk_in_w = tray_W + 0.8;            // friction over top tray's outer
    sk_in_d = tray_D + 0.8;
    difference() {
        union() {
            // top plate (thick enough to host the tongue groove on its underside)
            linear_extrude(lid_top_t) rr(sk_in_w+2*rim_w, sk_in_d+2*rim_w, corner_r+rim_w);
            // skirt down over the top tray
            translate([0,0,-skirt_h]) linear_extrude(skirt_h)
                difference(){ rr(sk_in_w+2*rim_w, sk_in_d+2*rim_w, corner_r+rim_w);
                              rr(sk_in_w, sk_in_d, corner_r); }
            // [#3] inward snap bead near skirt bottom -> clicks into tray detent
            translate([0,0,-6.5]) linear_extrude(2)
                difference(){ rr(sk_in_w, sk_in_d, corner_r);
                              offset(-catch_step) rr(sk_in_w, sk_in_d, corner_r); }
        }
        // [#2] groove on underside receives the top tray's tongue (register)
        translate([0,0,-0.01]) linear_extrude(reg_h+0.4)
            ring(tray_W,tray_D,corner_r,tongue_off-reg_clr,tongue_t+2*reg_clr);
        // [#11] grip recess on top
        translate([0,0,lid_top_t-1.2]) linear_extrude(1.4)
            difference(){ rr(sk_in_w*0.55, sk_in_d*0.55, 8);
                          rr(sk_in_w*0.55-7, sk_in_d*0.55-7, 6); }
    }
}

// ---- part dispatch (read-only selector; never re-assign PART) ----
part_sel = is_undef(PART) ? "tray" : PART;
if (part_sel=="tray") tray();
else if (part_sel=="lid") lid();
else if (part_sel=="assembly") {
    for (i=[0:2]) translate([0,0,i*tray_h]) color(i%2?"steelblue":"slategray") tray();
    translate([0,0,3*tray_h]) color("seagreen") lid();
}
