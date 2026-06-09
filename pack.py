import math
D, H, N = 16.51, 37.74, 100
clr, wall = 0.3, 1.5
Dp = D + clr
rp = Dp*math.sqrt(3)/2     # hex row pitch

def hexbox(cols, rows):
    W  = (cols + (0.5 if rows>1 else 0))*Dp
    Hh = Dp + (rows-1)*rp
    return W, Hh

# Search arrangements: k vials end-to-end (axis), cols x rows hex in cross-section.
# Need k*cols*rows >= N. Objective: minimize the LARGEST dimension (smallest cube),
# tiebreak total volume. Keep waste (empty slots) modest.
best_cube=None; best_vol=None
for k in range(1,7):
    for cols in range(1,40):
        for rows in range(1,40):
            cap = k*cols*rows
            if cap < N or cap > N+ k*cols + k*rows + 8:  # cap waste
                continue
            W,Hh = hexbox(cols,rows)
            L = k*H
            dims = sorted([L,W,Hh])
            maxd = dims[2]; vol = L*W*Hh/1000
            rec = (maxd, vol, k, cols, rows, L, W, Hh, cap)
            if best_cube is None or (maxd, vol) < best_cube[:2]: best_cube=rec
            if best_vol  is None or (vol, maxd) < best_vol[:2]:  best_vol=rec

def show(tag, r):
    maxd,vol,k,cols,rows,L,W,Hh,cap = r
    d = sorted([L,W,Hh])
    ow,od,oh = W+2*wall, Hh+2*wall, L+2*wall
    oc = sorted([ow,od,oh])
    print(f"\n{tag}")
    print(f"  k={k} end-to-end, {cols}x{rows} hex cross-section ({cap} slots, {cap-N} empty)")
    print(f"  vial bundle : {d[0]:.0f} x {d[1]:.0f} x {d[2]:.0f} mm   = {vol:.0f} cm3   aspect {d[2]/d[0]:.2f}")
    print(f"  CONTAINER   : {oc[0]:.0f} x {oc[1]:.0f} x {oc[2]:.0f} mm  (+{wall}mm walls)")

print(f"vial Ø{D} x {H} mm, eff Ø{Dp:.1f}, hex row pitch {rp:.2f} mm, N={N}")
show("MOST COMPACT (smallest largest-dimension / near-cube):", best_cube)
show("SMALLEST VOLUME:", best_vol)

glass = N*math.pi*(D/2)**2*H/1000
print(f"\nabsolute floor (vial cylinders touching, 0.9069 hex eff): {glass/0.9069:.0f} cm3")
print(f"raw vial volume: {glass:.0f} cm3")
