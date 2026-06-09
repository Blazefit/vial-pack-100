PART="none";
include <vial_trays.scad>;
difference() {
    union() {
        for (i=[0:2]) translate([0,0,i*tray_h]) color(i%2?"steelblue":"slategray") tray();
        for (p=positions()) for (i=[0:2])
            translate([p[0],p[1], i*tray_h + floor_t]) color("khaki") cylinder(d=vial_d, h=vial_h);
        translate([0,0,3*tray_h]) color("seagreen") lid();
    }
    translate([-300,0,-60]) cube([600,400,600]);
}
