PART="none";
include <vial_trays.scad>;
color("gray") sleeve();
for (i=[0:2]) translate([0,0, sleeve_h + 18 + i*(tray_h+14)])
    color(i%2?"steelblue":"slategray") tray();
