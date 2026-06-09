PART="none";
include <vial_trays_lidded.scad>;
// Lid (stacklid) snapped onto a tray, then sectioned at y=0 so you can SEE the
// fit: skirt telescoped over the tray wall, snap bead sitting in the tray's
// detent, and the lid plate resting flat on the rim. Render with --render.
difference() {
    union() {
        color("slategray") tray();
        translate([0,0,tray_h]) color("seagreen") stacklid();   // seats: plate bottom on rim top
    }
    translate([-300,-400,-80]) cube([600,400,600]);   // cut away -y half -> y=0 section faces the front camera
}
