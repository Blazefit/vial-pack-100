// =====================================================================
// 100 x 3 mL vial freezer container — near-cube honeycomb
// Vial: Ø16.51 x 37.74 mm (standard 3 mL serum vial), lyophilized powder.
// 5 x 7 hex grid x 3 deep = 105 cells (100 vials + 5 spare).
// Print standing up: vertical bores = no supports.
// =====================================================================
$fn = 48;

vial_d      = 16.51;
vial_h      = 37.74;
deep        = 3;       // vials stacked per cell
cols        = 5;
rows        = 7;

bore_clear  = 0.5;     // drop-in clearance
wall        = 1.2;     // outer + interstitial wall (min printable)
floor_t     = 2.0;

bore_d  = vial_d + bore_clear;
pitch   = bore_d + wall;
rowp    = pitch*sqrt(3)/2;
H_total = deep*vial_h + floor_t;

function positions() = [ for (r=[0:rows-1], c=[0:cols-1])
                         [ c*pitch + (r%2)*pitch/2, r*rowp ] ];

module shell2d() hull() for (p=positions()) translate(p) circle(d=bore_d+2*wall);

module container() {
    difference() {
        linear_extrude(height=H_total) shell2d();
        for (p=positions())
            translate([p[0], p[1], floor_t])
                cylinder(d=bore_d, h=H_total);   // open-top blind bores
    }
}

PART = is_undef(PART) ? "container" : PART;
if (PART=="container") container();
else if (PART=="cutaway") difference(){ container();
    translate([-200, rowp*rows/2, -1]) cube([400,400,400]); }
