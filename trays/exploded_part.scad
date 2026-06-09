PART="none";
include <vial_trays.scad>;
color("gray") sleeve();
for (i=[0:2]) translate([0,0, sleeve_h + 22 + i*(tray_h+16)]) color(i%2?"steelblue":"slategray") tray();
translate([0,0, sleeve_h + 22 + 3*(tray_h+16) + 14]) color("seagreen") lid();
