// =====================================================================
// 100x 3 mL vial freezer container — LIDDED-STACK variant (v4-lidded)
// SEPARATE TEST VERSION of vial_trays.scad. Same trays + same top lid,
// but EACH tray gets its own lid and the tower stacks tray->lid->tray->lid.
//   vs v3 (sleeveless): a register TONGUE on top of the lid (=> "stacklid")
//   lets the next tray's existing bottom groove seat on the lid instead of on
//   the tray below. tray() is UNCHANGED (reuse tray.stl x3); the lids now also
//   carry DIRECTED DRAIN holes on the hex interstices so meltwater escapes
//   between the vials below, never onto a crimp. Print stacklid.stl x2 (middle
//   layers) + lid.stl x1 (top cap).
//   Height cost: +2*lid_top_t (one extra lid plate per intermediate layer)
//   => 132 mm -> 140 mm. Footprint unchanged. Vial O16.51 x 37.74 mm.
//   SHRINK=true trims plate+register together (~1.5 mm shorter, still robust).
// =====================================================================
$fn = 48;

// SHRINK: trim lid plate + register depth together (~1.5 mm shorter tower, cap
// stays ~0.6 mm so it is NOT more brittle). Defined here so reg_h/lid_top_t can
// read it. See the note at lid_top_t below. Recommended default: false.
SHRINK = false;

// ---- stacking (fully modular) ----
// Every tray is capped by an identical `stacklid`, so the tower is infinitely
// extendable: stack as MANY layers as you like, add more any time. LAYERS only
// drives the assembly/height preview — the printed parts are independent of it.
LAYERS    = 3;       // trays in the previewed tower (set to whatever you want)
// FLUSH_TOP=false keeps the topmost lid a stacklid (its register tongue stays
// exposed = ready to extend). Set true to finish the very top with the plain
// `lid()` (flush, no tongue) — cleaner top, but then you can't stack onto it.
FLUSH_TOP = false;

// ---- vial + grid ----
vial_d   = 16.51;
vial_h   = 37.74;
cols     = 5;
rows     = 7;

// ---- fits / walls ----
bore_clear = 0.6;     // vial radial fit (drop-in)
wall_btw   = 1.5;     // hex pitch spacing between pockets
cup_wall   = 1.2;     // [#17] thin cup-tube wall (light)
rim_w      = 2.5;     // [#3] perimeter frame width (trimmed 3.0->2.5: lighter + 1 mm smaller/side)
floor_t    = 1.6;     // [#3] tray floor (trimmed 2.0->1.6)
v_clear    = 3.0;     // [#1] vertical clearance above each vial
pocket_wall_h = 22.0; // [#16] cup depth: holds vial's lower half; open above = less plastic
corner_r   = 4.0;
slide_clr  = 0.5;     // [#12] tray-in-sleeve slide fit

// ---- features ----
pocket_chamfer = 1.2; // [#6] lead-in at pocket mouth
relief_d       = 6.0; // [#7] push/drain hole at pocket bottom
reg_h          = SHRINK ? 2.5 : 3.0; // [#2] tongue height / groove depth (SHRINK trims it)
tongue_t       = 2.0; // [#2] tongue thickness
reg_clr        = 0.4; // [#12] tongue/groove clearance
key_sz         = 5.0; // [#8] corner key size
lead_ch        = 1.5; // [#9/#13] lead-in / edge chamfers
scallop_d      = 20;  // [#10] finger scallop
// [#19] retention nubs at cup mouth (vial doesn't fall out of a lifted tray)
nub_d        = 1.8;
nub_protrude = 0.5;
// [#21] engraved row/column IDs + a write-on label recess
engrave_d    = 0.7;
label_w_     = 30; label_h_ = 8; label_depth = 0.8;

// ---- lid (clips onto a tray; no sleeve — [#18] sleeve removed) ----
skirt_h     = 11;     // [#3] lid skirt over the tray
catch_step  = 0.9;    // [#3] snap catch depth
// lid_top_t hosts the underside register groove (depth reg_h+0.4). At 4.0 the
// cap over that groove is ~0.6 mm — same as the v3 lid. DON'T thin below ~4.0
// unless you also drop reg_h (see SHRINK below), or the perimeter cap turns
// brittle in the freezer. Height saved by thinning is tiny (~1.5 mm); the real
// lever for a shorter tower is a recessed lid, not a thinner plate.
lid_top_t   = SHRINK ? 3.5 : 4.0;

// ---- SHRINK toggle (defined at top of file): shaves plate + register depth
// TOGETHER so the cap over the register groove stays ~0.6 mm (i.e. NOT more
// brittle). Buys ~1.5 mm of tower but drops the tongue to 2.5, so the lidded
// tray no longer matches the stock tray.stl — print this variant's own tray.

// ---- lid drainage: perforate the plate so meltwater escapes DOWN between the
// vials below (holes sit on the hex interstices -> never over a crimp/septum) ----
lid_drain     = true;
lid_drain_d   = 3.0;  // drain hole Ø (3.0 clears the vials below by ~1 mm)
lid_drain_ch  = 1.2;  // [iter4] top funnel: bigger catch (was 0.6) so surface water finds the hole; still off the vials
drain_margin  = 0.6;  // min gap from a hole edge to a vial edge below

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

// [#lidded] each tray is capped by its own lid; the next tray stacks on that
// lid's top plate (the inter-layer tongue/groove is recessed and adds no pitch).
// Only the TOPMOST exposed tongue adds reg_h — and only when not FLUSH_TOP.
stack_pitch = tray_h + lid_top_t;              // per-layer rise (tray + its lid plate)
stack_h     = LAYERS*stack_pitch + (FLUSH_TOP ? 0 : reg_h);  // any number of layers

// ---- lid drain points: hex INTERSTICES (centroids of the triangular voids
// between 3 cups). Each is equidistant from its 3 surrounding vials = the only
// place a hole can go without sitting over a crimp/septum below. We over-
// generate candidates and keep only those that clear every vial by drain_margin.
function _mind(p) = min([ for (q=positions()) norm([p[0]-q[0], p[1]-q[1]]) ]);
function lid_drain_pts() =
    let(thr = vial_d/2 + lid_drain_d/2 + drain_margin)
    [ for (r=[0:rows-2], c=[0:cols], hx=[0,0.5], ty=[1/3, 2/3])
        let(p = [ c*pitch + hx*pitch - xext/2, (r+ty)*rowp - yext/2 ])
        if (abs(p[0]) <= xext/2 - 1 && abs(p[1]) <= yext/2 - 1 && _mind(p) >= thr) p ];

// ---- 2D helpers ----
module rr(w,d,r) offset(r) square([max(0.1,w-2*r), max(0.1,d-2*r)], center=true);
module ring(w,d,r,inset_out,thick)             // perimeter ring band
    difference(){ offset(-inset_out) rr(w,d,r); offset(-(inset_out+thick)) rr(w,d,r); }

tongue_off = (rim_w - tongue_t)/2;             // center the tongue in the rim

// ---- corner key: a clean 45° FLAT across the +x/+y corner (closed wall) so
// trays have an unambiguous orientation. Replaces the old through-notch, which
// subtracted a 45° cube WIDER than the 3 mm rim and therefore sliced the corner
// open. The flat removes only x+y > (tray_W/2 + tray_D/2 - key_sz); all cups are
// far inside that line, so only the rim/floor corner tip is trimmed.
module corner_chamfer(w, d, h, z0=-1) {
    K   = w/2 + d/2 - key_sz;               // cut plane: x + y = K
    big = 2*(w + d);
    translate([0,0,z0]) rotate([0,0,45])
        translate([K/sqrt(2), -big/2, 0]) cube([big, big, h]);
}

// =====================================================================
// tray() — v3 tray, but the +x/+y corner is CLOSED with a 45° chamfer instead
// of the old through-notch (which sliced the rim open). Otherwise identical.
module tray() {
    cup_top = floor_t + pocket_wall_h;
    nr = bore_d/2 - nub_protrude + nub_d/2;        // nub center radius
    union() {
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
            translate([p[0],p[1],cup_top-pocket_chamfer+0.01])
                cylinder(d1=bore_d, d2=bore_d+2*pocket_chamfer, h=pocket_chamfer);
            translate([p[0],p[1],-1]) cylinder(d=relief_d, h=floor_t+2);
        }
        // [#2] bottom groove ring (receives tongue of tray OR lid below)
        translate([0,0,-0.01])
            linear_extrude(reg_h+0.4)
                ring(tray_W,tray_D,corner_r,tongue_off-reg_clr,tongue_t+2*reg_clr);
        // [#10] finger scallops on the cup-block long sides
        for (s=[-1,1]) translate([0,s*tray_D/2,cup_top*0.55])
            rotate([90,0,0]) scale([1.8,1,1]) sphere(d=scallop_d);
        // [#8] corner key: clean 45° flat on the +x/+y corner (closed wall)
        corner_chamfer(tray_W, tray_D, tray_h+reg_h+3);
        // [#18] lid-snap detent: outer recess near the top
        translate([0,0,tray_h-6.8]) linear_extrude(2.6)
            difference(){ rr(tray_W,tray_D,corner_r);
                          offset(-catch_step) rr(tray_W,tray_D,corner_r); }
        // [#2/#21] engraved row/column IDs + write-on label recess
        engrave_ids();
      }
      // [#4/#19] retention nubs at each cup mouth (after bores so they survive);
      // ~0.2 mm interference -> vial clicks in, won't drop from a lifted tray
      for (p=positions()) for (a=[0:120:359])
          translate([p[0]+nr*cos(a), p[1]+nr*sin(a), cup_top-2.5]) sphere(d=nub_d);
    }
}

// [#21] engraved column letters (+Y face), row numbers (+X face), label recess (-X)
module engrave_ids() {
    for (c=[0:cols-1]) translate([c*pitch - xext/2, tray_D/2, tray_h-3.6])
        rotate([90,0,0]) linear_extrude(2*engrave_d, center=true)
            text(chr(65+c), size=3.0, halign="center", valign="center");
    for (r=[0:rows-1]) translate([tray_W/2, r*rowp - yext/2, tray_h-3.6])
        rotate([90,0,90]) linear_extrude(2*engrave_d, center=true)
            text(str(r+1), size=2.8, halign="center", valign="center");
    translate([-tray_W/2, 0, tray_h*0.5]) rotate([90,0,90])
        linear_extrude(2*label_depth, center=true)
            offset(1.2) square([label_h_, label_w_], center=true);
}

// =====================================================================
// lid() — v3 lid + directed drain perforations. Used as the TOP cap.
module lid() {
    sk_in_w = tray_W + 0.8;            // friction over tray's outer
    sk_in_d = tray_D + 0.8;
    difference() {
        union() {
            // top plate (thick enough to host the tongue groove on its underside)
            linear_extrude(lid_top_t) rr(sk_in_w+2*rim_w, sk_in_d+2*rim_w, corner_r+rim_w);
            // skirt down over the tray
            translate([0,0,-skirt_h]) linear_extrude(skirt_h)
                difference(){ rr(sk_in_w+2*rim_w, sk_in_d+2*rim_w, corner_r+rim_w);
                              rr(sk_in_w, sk_in_d, corner_r); }
            // [#3] inward snap bead near skirt bottom -> clicks into tray detent
            translate([0,0,-6.5]) linear_extrude(2)
                difference(){ rr(sk_in_w, sk_in_d, corner_r);
                              offset(-catch_step) rr(sk_in_w, sk_in_d, corner_r); }
        }
        // [#2] groove on underside receives THIS tray's top tongue (register)
        translate([0,0,-0.01]) linear_extrude(reg_h+0.4)
            ring(tray_W,tray_D,corner_r,tongue_off-reg_clr,tongue_t+2*reg_clr);
        // [#11] grip recess on top
        translate([0,0,lid_top_t-1.2]) linear_extrude(1.4)
            difference(){ rr(sk_in_w*0.55, sk_in_d*0.55, 8);
                          rr(sk_in_w*0.55-7, sk_in_d*0.55-7, 6); }
        // [#drain] directed drainage: holes on the hex interstices route melt-
        // water DOWN between the vials below (never onto a crimp/septum)
        if (lid_drain) lid_drains();
        // NOTE: the lid's outer corners stay ROUNDED (proven snap/skirt geometry).
        // We deliberately do NOT chamfer the lid corner — it would thin the skirt
        // wall at that corner and risk the fit. Only the tray corner is keyed.
        // [iter3] skirt-mouth lead-in: flare the inner bottom edge so the lid
        // starts over the tray rim instead of fighting it
        translate([0,0,-skirt_h-0.01]) hull() {
            linear_extrude(0.01) rr(sk_in_w+2*lead_ch, sk_in_d+2*lead_ch, corner_r+lead_ch);
            translate([0,0,lead_ch]) linear_extrude(0.01) rr(sk_in_w, sk_in_d, corner_r);
        }
    }
}

// [#drain] drain-hole cutter: a through bore + a small top lead-in chamfer at
// each interstitial point. Kept out of the load-bearing rim, so the plate's
// stacking strength is unchanged.
module lid_drains() {
    for (p = lid_drain_pts()) {
        translate([p[0], p[1], -1]) cylinder(d=lid_drain_d, h=lid_top_t+2);
        translate([p[0], p[1], lid_top_t-lid_drain_ch+0.01])
            cylinder(d1=lid_drain_d, d2=lid_drain_d+2*lid_drain_ch, h=lid_drain_ch);
    }
}

// =====================================================================
// [#lidded] stacklid() — the ONLY new part. A lid PLUS a register tongue on
// top, so the NEXT tray's existing bottom groove seats on this lid.
// Snaps to its own tray below (lid()'s skirt+bead+underside groove) and
// presents a tongue up top for the tray above. Adds no pitch beyond the lid
// plate: the tongue is recessed into the next tray's groove.
// [#1] SKIRTLESS flat drain-plate. Rests on its tray (underside groove over the
// tray's top tongue) and presents a top tongue for the tray above. No skirt/snap,
// so it prints PLATE-ON-BED support-free, is lighter, and adds no skirt overhang
// (footprint = tray). The top cap lid() keeps the skirt+snap to secure the tower.
module stacklid() {
    difference() {
        union() {
            linear_extrude(lid_top_t) rr(tray_W, tray_D, corner_r);
            // top register tongue (corner-keyed to match the tray)
            difference() {
                translate([0,0,lid_top_t-0.01]) linear_extrude(reg_h)
                    ring(tray_W,tray_D,corner_r,tongue_off,tongue_t);
                corner_chamfer(tray_W, tray_D, reg_h+3, lid_top_t-1);
            }
        }
        // underside register groove (receives the tray-below top tongue)
        translate([0,0,-0.01]) linear_extrude(reg_h+0.4)
            ring(tray_W,tray_D,corner_r,tongue_off-reg_clr,tongue_t+2*reg_clr);
        // match the tray corner key
        corner_chamfer(tray_W, tray_D, lid_top_t+reg_h+3);
        // [#drain] directed drainage onto the hex interstices below
        if (lid_drain) lid_drains();
    }
}

// ---- part dispatch (read-only selector; never re-assign PART) ----
part_sel = is_undef(PART) ? "tray" : PART;
if      (part_sel=="tray")     tray();
else if (part_sel=="stacklid") stacklid();      // UNIVERSAL lid: snaps on + lets a tray stack on top -> print one per tray
else if (part_sel=="lid")      lid();           // OPTIONAL flush cap: no top tongue, so nothing stacks on it
else if (part_sel=="assembly") {
    // fully modular tower: EVERY tray capped by an identical stacklid, so you
    // can stack any number. FLUSH_TOP=true finishes the very top with lid().
    for (i=[0:LAYERS-1]) {
        translate([0,0,i*stack_pitch]) color(i%2?"steelblue":"slategray") tray();
        translate([0,0,i*stack_pitch + tray_h]) color("seagreen") {
            if (FLUSH_TOP && i==LAYERS-1) lid(); else stacklid();
        }
    }
}
echo(str("LIDDED tower: ", LAYERS, " trays + ", LAYERS, " stacklids = ",
         LAYERS*cols*rows, " vials, H = ", stack_h, " mm",
         FLUSH_TOP ? " (flush top)" : " (extendable top tongue)"));
echo(str("per-layer pitch = ", stack_pitch, " mm  ->  add 1 layer = +",
         stack_pitch, " mm. Print ", LAYERS, "x tray + ", LAYERS, "x stacklid",
         FLUSH_TOP ? " + 1x lid (flush cap)" : ""));
echo(str("drain holes per lid = ", len(lid_drain_pts()), "  (O", lid_drain_d,
         " on hex interstices; SHRINK=", SHRINK, ", reg_h=", reg_h, ", lid_top_t=", lid_top_t, ")"));
