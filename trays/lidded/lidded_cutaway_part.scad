PART="none";
include <vial_trays_lidded.scad>;
// half-section of the modular tower: LAYERS trays, a stacklid on each, vials in
// their cups. Every layer is identical -> stack as many as you like.
difference() {
    union() {
        for (i=[0:LAYERS-1]) {
            translate([0,0,i*stack_pitch]) color(i%2?"steelblue":"slategray") tray();
            translate([0,0,i*stack_pitch + tray_h]) color("seagreen")
                { if (FLUSH_TOP && i==LAYERS-1) lid(); else stacklid(); }
            for (p=positions())
                translate([p[0],p[1], i*stack_pitch + floor_t]) color("khaki")
                    cylinder(d=vial_d, h=vial_h);
        }
    }
    translate([-300,0,-60]) cube([600,400,600]);   // cut away the +y half
}
