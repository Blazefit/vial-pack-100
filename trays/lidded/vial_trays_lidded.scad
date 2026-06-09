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
rim_w      = 3.0;     // perimeter frame width (hosts tongue/groove)
floor_t    = 2.0;     // tray floor
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
lid_drain_ch  = 0.6;  // top lead-in chamfer (catch water, keep top mostly flat)
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

// ---- corner key: a vertical rib (sleeve) / notch (tray) at +x+y corner ----
module corner_key_solid(h, sz)
    translate([tray_W/2 - rim_w/2, tray_D/2 - rim_w/2, 0])
        rotate([0,0,45]) translate([-sz/2,-sz/2,0]) cube([sz,sz,h]);

// =====================================================================
// tray() — UNCHANGED from vial_trays.scad (reuse tray.stl).
module tray() {
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
            translate([p[0],p[1],floor_t+pocket_wall_h-pocket_chamfer+0.01])
                cylinder(d1=bore_d, d2=bore_d+2*pocket_chamfer, h=pocket_chamfer);
            translate([p[0],p[1],-1]) cylinder(d=relief_d, h=floor_t+2);
        }
        // [#2] bottom groove ring (receives tongue of tray OR lid below)
        translate([0,0,-0.01])
            linear_extrude(reg_h+0.4)
                ring(tray_W,tray_D,corner_r,tongue_off-reg_clr,tongue_t+2*reg_clr);
        // [#10] finger scallops on the cup-block long sides
        for (s=[-1,1]) translate([0,s*tray_D/2,(floor_t+pocket_wall_h)*0.55])
            rotate([90,0,0]) scale([1.8,1,1]) sphere(d=scallop_d);
        // [#8] corner key NOTCH (trays seat one way; +0.8 fit)
        corner_key_solid(tray_h+reg_h+1, key_sz+0.8);
        // [#18] lid-snap detent: shallow recess on the outer face near the top
        translate([0,0,tray_h-7]) linear_extrude(3)
            difference(){ rr(tray_W,tray_D,corner_r);
                          offset(-catch_step) rr(tray_W,tray_D,corner_r); }
    }
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
module stacklid() {
    lid();                                       // reuse the full lid (snap + underside groove + grip)
    // top register tongue (mirrors the tray's top tongue so a tray seats on it)
    translate([0,0,lid_top_t-0.01]) linear_extrude(reg_h)
        ring(tray_W,tray_D,corner_r,tongue_off,tongue_t);
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
