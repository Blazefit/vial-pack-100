// =====================================================================
// 100x 3 mL vial freezer container — LIDDED-STACK variant (v6 inboard register)
// Each tray gets its own lid; the tower stacks tray->stacklid->tray->stacklid.
// The lids carry DIRECTED DRAIN holes on the hex interstices so meltwater
// escapes between the vials below, never onto a crimp.
// Print: N x tray + N x stacklid (+ optional 1x lid as a flush top cap).
//
// v6 REGISTER REDESIGN: v5 trimmed the rim 3.0->2.5 mm but kept the perimeter
// groove cut 2.8 mm wide -> the cut was WIDER than the rim and severed the
// frame's bottom 3.4 mm (floating wall, unprintable overhang, no groove walls).
// Root-cause fix: a walled groove cannot live in a <=3 mm rim, so BOTH register
// interfaces move INBOARD into solid material:
//   A: tray TOP tongue (on the rim) -> slot in the lid/stacklid UNDERSIDE plate
//   B: stacklid TOP tongue (inboard ring) -> slot in the tray FLOOR underside
// Both tongues carry a 45-degree corner-key flat and both slots a matching
// corner BLOCK, so a 180-degree-rotated part physically cannot seat.
// Vial O16.51 x 37.74 mm. 3-layer tower ~140 mm.
// =====================================================================
$fn = 48;

// SHRINK: thin the lid plate 4.0 -> 3.0 mm (~3 mm shorter 3-tower). The v6
// underside slot is only 1.4 mm deep, so even at 3.0 the cap over it is 1.6 mm
// (vs 0.6 mm in v4/v5) — safe either way. Default false = stiffer plate.
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
pocket_wall_h = 20.0; // [#16] cup depth: holds vial's lower half; open above = less
                      // plastic. [iter1] 22 -> 20: reclaims ~4.8 cm3 so the v6 tray
                      // stays under the 99.4 cm3 v5 budget; cup still covers 53% of
                      // the vial and the nubs ride down with cup_top (grip unchanged)
corner_r   = 4.0;
slide_clr  = 0.5;     // [#12] tray-in-sleeve slide fit

// ---- features ----
pocket_chamfer = 0.8; // [#6] lead-in at pocket mouth. [iter1] 1.2 -> 0.8: at 1.2
                      // it equalled cup_wall, so the chamfer ran out EXACTLY at the
                      // tube OD -> knife-edge mouths (sub-nozzle top layers, 54
                      // non-manifold mesh edges). 0.8 leaves a 0.4 mm (1 perimeter)
                      // land; still 4x the 0.2 mm nub interference as lead-in.
relief_d       = 6.0; // [#7] push/drain hole at pocket bottom
key_sz         = 5.0; // [#8] corner key size (cosmetic rim flat; registers key separately)
lead_ch        = 1.5; // [#9/#13] lead-in / edge chamfers
// [#10] v6: finger scallops REMOVED. Against the v5 open frame + thin cup tubes
// they cut clean through the frame AND through the bore of 2 cups per long side
// (4 gutted pockets). They were vestigial from the v3 solid cup block: once the
// layer above is lifted off, a tray exposes its full 42 mm side walls to grip.

// ---- register (tongue/slot) — v6 inboard redesign ----
reg_clr    = 0.3;  // [#2] tongue/slot clearance per side (drop-on, lift-apart)
tng_t      = 1.2;  // [#2] tongue thickness (both interfaces, 3 perimeters)
top_tng_h  = 1.2;  // A: tray-top tongue height (slot in lid underside is 1.4 deep)
top_tng_in = 1.1;  // A: tongue inset from outer face (sits on the 2.5 mm rim).
                   // [iter1] 1.0 -> 1.1: the mating slot sits at inset-reg_clr, so
                   // at 1.0 the lid/stacklid slot outer wall was a 0.7 mm single-
                   // perimeter ring at the bed; 1.1 makes it 0.8 mm = 2 perimeters
                   // (tongue now spans 1.1..2.3 on the 2.5 rim, 0.2 inner ledge)
bot_tng_h  = 1.0;  // B: stacklid-top tongue height (tray floor slot is 1.2 deep)
bot_tng_in = 3.3;  // B: inboard of the rim, into solid floor (clears relief holes >3 mm)
slot_extra = 0.2;  // slot depth beyond tongue height -> positive stop is plate/rim, never the tongue

// ---- [snap-A] latch each lid onto its tray (stacking unchanged) ----
// Bead segments on the slot's outer wall click into a groove around the tray
// tongue's outer flank: every tray+lid becomes a latched unit (vials stay
// covered even if a lifted layer tips), while interface B stays a drop-on
// register. Staircase lead faces the slot mouth (= insertion ramp AND the
// print-overhang relief, since the lids print mouth-down); the retention
// face on top stays square.
snapA_eng   = 0.2;   // radial engagement past reg_clr (same class as the vial nubs)
snapA_h     = 0.5;   // bead band height (z 0.40..0.90 in the slot)
snapA_grv_d = 0.35;  // groove depth into the tongue flank (leaves 0.85 = 2 perims)
snapA_z     = 0.35;  // groove bottom above rim top; groove is snapA_h+0.2 tall
snapA_seg   = 24;    // bead segment length at each side-face center (x4)
// [iter1] NOTE: an earlier attempt added a hulled `ring_flare` slot-mouth chamfer
// here for elephant-foot relief. Its "tuck-inside" offsets left a 0.2 mm step
// against the straight slot wall -> coincident faces -> NON-MANIFOLD mesh on all
// three parts (Manifold render, trimesh watertight=False). Removed: the real
// finding-6 fix is the 0.8 mm two-perimeter slot wall (top_tng_in 1.0->1.1);
// first-layer squish is handled by the slicer's elephant-foot compensation.
// [iter1] snap profiling — both snap faces used to be 0.9 mm 90-deg ledges
// (square-edge jam on insertion; 0.9 mm unsupported overhangs in print
// orientation on BOTH mating retention faces -> PETG droop where it matters)
bead_lead  = 0.9;  // bead insertion-side 45-deg lead-in height (protrusion 0 -> full)
bead_sq    = 0.45; // square protrusion kept at the bead top / detent step (~1 extrusion width)
det_taper  = 0.45; // detent upper-shoulder 45-deg ramp height (depth 0.9 -> bead_sq)
// [#19] retention nubs at cup mouth (vial doesn't fall out of a lifted tray)
nub_d        = 1.8;
nub_protrude = 0.5;
// [#21] engraved row/column IDs + a write-on label recess
engrave_d    = 0.7;
label_w_     = 30; label_h_ = 8; label_depth = 0.8;

// ---- lid (clips onto a tray; no sleeve — [#18] sleeve removed) ----
skirt_h     = 11;     // [#3] lid skirt over the tray
catch_step  = 0.9;    // [#3] snap catch depth
// lid_top_t hosts the underside register slot (depth top_tng_h+slot_extra=1.4).
// Cap over the slot: 2.6 mm at 4.0, still 1.6 mm at SHRINK's 3.0 — both safe.
lid_top_t   = SHRINK ? 3.0 : 4.0;

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
// lid's top plate (the inter-layer tongue/slot is recessed and adds no pitch).
// Only the TOPMOST exposed tongue adds bot_tng_h — and only when not FLUSH_TOP.
stack_pitch = tray_h + lid_top_t;              // per-layer rise (tray + its lid plate)
stack_h     = LAYERS*stack_pitch + (FLUSH_TOP ? 0 : bot_tng_h);  // any number of layers

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

// ---- v6 keyed register rings ----
// A tongue is a thin rounded-rect ring with a 45° FLAT at the +x/+y corner; the
// mating slot is the same ring widened by reg_clr with that corner BLOCKED
// (solid). Correct orientation: the tongue's flat stops reg_clr short of the
// block. Rotated 180°: the tongue's full corner hits the block -> cannot seat.
// reg_K(): the corner-cut line x+y=K for a ring at `inset` (trims ~3 mm of ring)
function reg_K(inset) =
    tray_W/2 + tray_D/2 - 2*inset - 0.586*max(0.5, corner_r - inset) - 3;

module corner_wedge(K, h) {        // everything beyond the 45° plane x+y=K
    rotate([0,0,45]) translate([K/sqrt(2), -500, -1]) cube([1000, 1000, h+2]);
}
module reg_tongue(inset, h) {      // ADD to a part top (caller translates to z)
    difference() {
        linear_extrude(h) ring(tray_W, tray_D, corner_r, inset, tng_t);
        corner_wedge(reg_K(inset), h);
    }
}
module reg_slot(inset, h) {        // SUBTRACT from a part bottom (cuts z=0 up)
    difference() {
        translate([0,0,-0.01]) linear_extrude(h + slot_extra + 0.01)
            ring(tray_W, tray_D, corner_r, inset - reg_clr, tng_t + 2*reg_clr);
        corner_wedge(reg_K(inset) + reg_clr, h + slot_extra);
    }
}

// [snap-A] bead segments ADDED inside a lid underside slot (local z=0 = mouth).
// Rooted 0.05 into the slot outer wall; steps overlap 0.05 in z so no internal
// joint is tangent (no sliver shells -- same lesson as the detent rebuild).
module snapA_beads() {
    p = [0.17, 0.34, snapA_eng + reg_clr];   // protrusion past the slot wall face
    intersection() {
        union() for (s = [[0, tray_D/2, 0], [0, -tray_D/2, 0],
                          [tray_W/2, 0, 90], [-tray_W/2, 0, 90]])
            translate([s[0], s[1], 0]) rotate([0, 0, s[2]])
                cube([snapA_seg, 14, 8], center=true);
        union() {
            translate([0,0,0.40]) linear_extrude(0.20)
                ring(tray_W, tray_D, corner_r, top_tng_in-reg_clr-0.05, 0.05+p[0]);
            translate([0,0,0.55]) linear_extrude(0.20)
                ring(tray_W, tray_D, corner_r, top_tng_in-reg_clr-0.05, 0.05+p[1]);
            translate([0,0,0.70]) linear_extrude(0.20)
                ring(tray_W, tray_D, corner_r, top_tng_in-reg_clr-0.05, 0.05+p[2]);
        }
    }
}

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
            // [#17] thin-wall cup TUBES (open between cups -> ~half the plastic).
            // [iter1] h pocket_wall_h -> pocket_wall_h+0.01 so the tube top lands
            // EXACTLY at cup_top (= floor_t+pocket_wall_h), coplanar with the mouth
            // chamfer top below; the old 0.02 mm offset between the two planes left
            // a sliver ring at every mouth (non-manifold edges at z~cup_top).
            for (p=positions()) translate([p[0],p[1],floor_t-0.01])
                cylinder(d=bore_d+2*cup_wall, h=pocket_wall_h+0.01);
            // perimeter FRAME ring (full height) carries the stack
            translate([0,0,floor_t-0.01])
                linear_extrude(tray_h-floor_t+0.01) ring(tray_W,tray_D,corner_r,0,rim_w);
            // [#2] top tongue ring (keyed; seats in the lid/stacklid underside slot)
            // [iter1] the tongue used to START at tray_h-0.01 = exactly the frame
            // top plane -> ZERO union overlap (CGAL split it into a floating ring;
            // Manifold glued it into a non-manifold mesh). Now it roots 0.2 mm
            // INTO the frame; the extra 0.2 of height keeps the top at tray_h+1.2.
            translate([0,0,tray_h-0.2]) reg_tongue(top_tng_in, top_tng_h+0.2);
        }
        // cups: bore + [#6] mouth chamfer + [#7] relief/push hole
        for (p=positions()) {
            // [iter1] bore tops out EXACTLY at cup_top (h pocket_wall_h+0.1 ->
            // pocket_wall_h): the old 0.1 mm poke left a free-floating bore-top cap
            // at z=cup_top+0.1 in the air above the tube -> non-manifold edges. The
            // bore (8.56 r) sits well inside the chamfer mouth (9.36 r) at cup_top,
            // so a coincident top plane here is a clean washer face, not a knife edge.
            translate([p[0],p[1],floor_t]) cylinder(d=bore_d, h=pocket_wall_h);
            // [iter1] mouth chamfer top lands exactly at cup_top, coplanar with the
            // tube top -> the 0.4 mm (1-perimeter) mouth land is a clean flat ring
            // (chamfer end-dia 18.71 < tube OD 19.51; no knife edge, no sliver).
            translate([p[0],p[1],cup_top-pocket_chamfer])
                cylinder(d1=bore_d, d2=bore_d+2*pocket_chamfer, h=pocket_chamfer);
            translate([p[0],p[1],-1]) cylinder(d=relief_d, h=floor_t+2);
        }
        // [#2] v6 bottom register: a walled SLOT in the floor underside, fully
        // inboard of the rim -> the rim stays solid to the bed (v5's perimeter
        // groove was wider than the 2.5 rim and severed the frame's bottom 3.4 mm)
        reg_slot(bot_tng_in, bot_tng_h);
        // [#8] corner key: clean 45° flat on the +x/+y corner (closed wall)
        corner_chamfer(tray_W, tray_D, tray_h+top_tng_h+3);
        // [#18] lid-snap detent: outer recess near the top. [iter1] the recess
        // used to end square at its top -> a 0.9 mm 90-deg downward-facing ledge
        // ~438 mm around the rim (tray prints bed-down; PETG droops it, and it is
        // the very shoulder the lid bead bears on). The last det_taper now RAMPS
        // at 45 deg back to a bead_sq step (~1 extrusion width, prints clean).
        // Built as ONE cut solid (band minus kept plug): two stacked cuts used
        // to butt exactly at the taper start and shed zero-volume sliver shells
        // at the corner arcs. The plug pieces overlap so every internal joint
        // is embedded, never tangent.
        translate([0,0,tray_h-6.8]) difference() {
            linear_extrude(2.6) rr(tray_W,tray_D,corner_r);
            union() {
                translate([0,0,-0.1]) linear_extrude(2.6-det_taper+0.1)
                    offset(-catch_step) rr(tray_W,tray_D,corner_r);
                hull() {
                    translate([0,0,2.6-det_taper-0.01]) linear_extrude(0.01)
                        offset(-catch_step) rr(tray_W,tray_D,corner_r);
                    translate([0,0,2.6]) linear_extrude(0.1)
                        offset(-bead_sq) rr(tray_W,tray_D,corner_r);
                }
            }
        }
        // [#2/#21] engraved row/column IDs + write-on label recess
        engrave_ids();
        // [snap-A] groove around the tongue's outer flank: the lid's slot beads
        // click in -> tray+lid latch closed. 0.35 deep leaves 0.85 mm tongue;
        // the 0.15 mm of full flank above it is the retention shoulder.
        translate([0,0,tray_h+snapA_z]) linear_extrude(snapA_h+0.2)
            ring(tray_W, tray_D, corner_r, top_tng_in-0.1, 0.1+snapA_grv_d);
      }
      // [#4/#19] retention nubs at each cup mouth (after bores so they survive);
      // ~0.2 mm interference -> vial clicks in, won't drop from a lifted tray
      for (p=positions()) for (a=[0:120:359])
          translate([p[0]+nr*cos(a), p[1]+nr*sin(a), cup_top-2.5]) sphere(d=nub_d);
    }
}

// [#21] engraved column letters (+Y face), row numbers (+X face), label recess (-X)
// v6: raised tray_h-3.6 -> tray_h-2.2. At -3.6 the glyph bottoms dipped 0.8-0.9 mm
// into the snap-detent recess (0.9 deep > 0.7 engrave) and printed chopped.
// At -2.2 glyphs sit between the detent top (tray_h-4.2) and the rim top, with
// 0.7 mm clearance below and 0.5+ mm above.
module engrave_ids() {
    for (c=[0:cols-1]) translate([c*pitch - xext/2, tray_D/2, tray_h-2.2])
        rotate([90,0,0]) linear_extrude(2*engrave_d, center=true)
            text(chr(65+c), size=3.0, halign="center", valign="center");
    for (r=[0:rows-1]) translate([tray_W/2, r*rowp - yext/2, tray_h-2.2])
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
            // [#3] inward snap bead near skirt bottom -> clicks into tray detent.
            // [iter1] profiled (was a square 2 mm prism: 0.5 mm square-edge-on-
            // square-edge interference with NO lead-in on the insertion path —
            // the skirt-mouth flare sits 4.5 mm below and is long past the rim
            // by the time the bead arrives). LOWER edge: 45-deg bead_lead ramp
            // so axial push cams the skirt open over the rim. UPPER (retention)
            // edge: ramps back to a bead_sq square ledge, so the printed
            // overhang (lid prints flipped) is ~1 extrusion width, not 0.9 mm.
            // Outer face embeds 0.1/side INTO the skirt wall (real union overlap).
            translate([0,0,-6.5]) difference() {
                linear_extrude(2) rr(sk_in_w+0.2, sk_in_d+0.2, corner_r);
                hull() {   // insertion ramp: protrusion 0 -> catch_step over bead_lead
                    translate([0,0,-0.01]) linear_extrude(0.01)
                        offset(0.01) rr(sk_in_w, sk_in_d, corner_r);
                    translate([0,0,bead_lead]) linear_extrude(0.01)
                        offset(-catch_step) rr(sk_in_w, sk_in_d, corner_r);
                }
                // full-protrusion band: bead_lead .. 2-(catch_step-bead_sq)
                translate([0,0,bead_lead-0.01])
                    linear_extrude(2-bead_lead-(catch_step-bead_sq)+0.02)
                        offset(-catch_step) rr(sk_in_w, sk_in_d, corner_r);
                hull() {   // retention ramp: catch_step -> bead_sq at the top edge
                    translate([0,0,2-(catch_step-bead_sq)]) linear_extrude(0.01)
                        offset(-catch_step) rr(sk_in_w, sk_in_d, corner_r);
                    translate([0,0,2]) linear_extrude(0.01)
                        offset(-bead_sq) rr(sk_in_w, sk_in_d, corner_r);
                    translate([0,0,2.2]) linear_extrude(0.01)
                        offset(-bead_sq) rr(sk_in_w, sk_in_d, corner_r);
                }
            }
        }
        // [#2] underside slot receives THIS tray's top tongue (keyed register)
        reg_slot(top_tng_in, top_tng_h);
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
    // [snap-A] tongue latch too (belt + braces with the skirt snap)
    snapA_beads();
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
            // top register tongue: INBOARD ring (v6) -> seats in the next tray's
            // walled floor slot; keyed so a rotated tray cannot seat.
            // [iter1] roots 0.2 mm into the plate (real union overlap, same fix
            // as the tray-top tongue); the +0.2 height keeps the top at
            // lid_top_t + bot_tng_h.
            translate([0,0,lid_top_t-0.2]) reg_tongue(bot_tng_in, bot_tng_h+0.2);
        }
        // underside slot (receives the tray-below top tongue; keyed)
        reg_slot(top_tng_in, top_tng_h);
        // match the tray corner key (cosmetic flat; doesn't reach the inboard rings)
        corner_chamfer(tray_W, tray_D, lid_top_t+bot_tng_h+3);
        // [#drain] directed drainage onto the hex interstices below
        if (lid_drain) lid_drains();
    }
    // [snap-A] click onto the tray below (the stacking tongue above is untouched)
    snapA_beads();
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
         " on hex interstices; SHRINK=", SHRINK, ", lid_top_t=", lid_top_t, ")"));
echo(str("v6 registers: A tray-top tongue ", top_tng_h, "x", tng_t, " @inset ", top_tng_in,
         " -> lid slot; B stacklid-top tongue ", bot_tng_h, "x", tng_t, " @inset ", bot_tng_in,
         " -> floor slot (cap ", floor_t-(bot_tng_h+slot_extra), " mm); clr ", reg_clr, "/side, keyed corners"));
