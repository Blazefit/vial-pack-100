// =====================================================================
// 100x 3 mL vial freezer container — INDIVIDUAL-HOLDER stacking trays
// Each vial sits in its OWN pocket on its OWN floor (never stacked on
// another vial). 3 identical trays (35 pockets each, 5x7 hex) stack
// inside a thin sleeve -> near-cube. Vial Ø16.51 x 37.74 mm.
// =====================================================================
$fn = 48;

vial_d   = 16.51;
vial_h   = 37.74;
cols     = 5;
rows     = 7;

bore_clear = 0.5;
wall       = 1.5;     // pocket + perimeter wall
wall_btw   = 1.5;     // interstitial wall between pockets
floor_t    = 2.0;
clr        = 0.5;     // tray-in-sleeve clearance
corner_r   = 4.0;

bore_d  = vial_d + bore_clear;
pitch   = bore_d + wall_btw;
rowp    = pitch*sqrt(3)/2;
tray_h  = floor_t + vial_h + 1.0;       // wall just taller than the vial

// hex centers, then centered on origin
xext = (cols-1)*pitch + pitch/2;
yext = (rows-1)*rowp;
function positions() = [ for (r=[0:rows-1], c=[0:cols-1])
    [ c*pitch + (r%2)*pitch/2 - xext/2, r*rowp - yext/2 ] ];

tray_W = xext + bore_d + 2*wall;
tray_D = yext + bore_d + 2*wall;

module rrect(w,d,r,h) linear_extrude(h) offset(r) square([w-2*r, d-2*r], center=true);

module finger_scallops(w,d,h) {
    for (s=[-1,1]) translate([0, s*d/2, h*0.62])
        rotate([90,0,0]) scale([1.7,1,1]) sphere(d=18);
}

module tray() {
    difference() {
        rrect(tray_W, tray_D, corner_r, tray_h);
        for (p=positions())
            translate([p[0], p[1], floor_t]) cylinder(d=bore_d, h=vial_h+1);
        finger_scallops(tray_W, tray_D, tray_h);
    }
}

sleeve_in_w = tray_W + 2*clr;
sleeve_in_d = tray_D + 2*clr;
sleeve_W = sleeve_in_w + 2*wall;
sleeve_D = sleeve_in_d + 2*wall;
sleeve_h = 3*tray_h + floor_t + 2;      // 3 trays + base

module sleeve() {
    difference() {
        rrect(sleeve_W, sleeve_D, corner_r+wall, sleeve_h);
        translate([0,0,floor_t])
            rrect(sleeve_in_w, sleeve_in_d, corner_r, sleeve_h);
        finger_scallops(sleeve_W, sleeve_D, sleeve_h*0.9);
    }
}

module lid() {
    difference() {
        rrect(sleeve_W, sleeve_D, corner_r+wall, wall+4);
        translate([0,0,wall])
            rrect(sleeve_in_w+0.6, sleeve_in_d+0.6, corner_r, 6);
    }
}

part_sel = is_undef(PART) ? "tray" : PART;   // read-only — never re-assign PART (hoisting bug)
if (part_sel=="tray") tray();
else if (part_sel=="sleeve") sleeve();
else if (part_sel=="lid") lid();
else if (part_sel=="assembly") {
    color("gray") sleeve();
    for (i=[0:2]) translate([0,0,floor_t + i*tray_h]) color(i%2?"steelblue":"slategray") tray();
}
