PART="none";
include <vial_trays.scad>;
difference() {
    union() {
        color("gray") sleeve();
        for (i=[0:2]) translate([0,0,base_t + i*tray_h]) color(i%2?"steelblue":"slategray") tray();
        // vials seated to show individual holding + 3mm top clearance
        for (p=positions()) for (i=[0:2])
            translate([p[0],p[1], base_t + i*tray_h + floor_t]) color("khaki") cylinder(d=vial_d, h=vial_h);
        translate([0,0,sleeve_h]) color("seagreen") lid();
    }
    translate([-300,0,-60]) cube([600,400,600]);   // slice away y>0 to reveal section
}
