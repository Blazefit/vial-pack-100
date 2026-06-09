PART="none";
include <vial_trays_lidded.scad>;
// half-section of the lidded tower: 3 trays, a lid on each, vials in their cups
difference() {
    union() {
        for (i=[0:2]) {
            translate([0,0,i*stack_pitch]) color(i%2?"steelblue":"slategray") tray();
            translate([0,0,i*stack_pitch + tray_h]) color("seagreen")
                { if (i<2) stacklid(); else lid(); }
            for (p=positions())
                translate([p[0],p[1], i*stack_pitch + floor_t]) color("khaki")
                    cylinder(d=vial_d, h=vial_h);
        }
    }
    translate([-300,0,-60]) cube([600,400,600]);   // cut away the +y half
}
