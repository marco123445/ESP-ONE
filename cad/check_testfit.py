"""Prüft die Passprobe (espone.scad, Modul testfit): Auflageflächen der eingelegten Teile dürfen sich
nicht überschneiden und müssen frei vom fremden Rand liegen. Mindestabstand 2 mm. Werte aus espone.scad."""
import re, math, itertools, sys
sys.stdout.reconfigure(encoding="utf-8")
s = open("espone.scad", encoding="utf-8").read()
g = lambda k: float(re.search(rf"\b{k}\s*=\s*([-\d.]+)", s).group(1))
tf = s[s.index("module testfit"):]
v = lambda k: float(re.search(rf"\b{k}\s*=\s*([-\d.]+)", tf).group(1))
rw = v("rw"); wz, px, tx, tz = v("wz"), v("px"), v("tx"), v("tz")
pcx, pcy, ix, iy, mx, my, dx, dy = (v(k) for k in "pcx pcy ix iy mx my dx dy".split())
def circ(cx, cy, r): return ("c", cx, cy, r)
def rect(x0, y0, x1, y1): return ("r", x0, y0, x1, y1)
Z = {  # Fläche, die das eingelegte Teil bzw. der Rand belegt
 "Tieftöner-Flansch+Rand": circ(0, wz, (g("woofer_fl") + 0.6) / 2 + rw),
 "Hochtöner-Flansch+Rand": circ(tx, tz, (g("tweeter_fl") + 0.6) / 2 + rw),
 "PR-Rahmen 105": rect(px - 52.5, wz - 52.5, px + 52.5, wz + 52.5),
 "Platine 85x56": rect(pcx, pcy, pcx + g("pcb_w"), pcy + g("pcb_h")),
 "DC-Mutter (Ø15)": circ(dx, dy, 7.5),
 "Einsatz-Dom": circ(ix, iy, 5),
 "Senkung/Schraubenkopf": circ(mx, my, 6),
}
def pts(z, n=720):
    if z[0] == "c": return [(z[1] + z[3] * math.cos(2 * math.pi * i / n), z[2] + z[3] * math.sin(2 * math.pi * i / n)) for i in range(n)]
    _, a, b, c, d = z; k = 200
    return [(a + (c - a) * i / k, b) for i in range(k)] + [(a + (c - a) * i / k, d) for i in range(k)] + [(a, b + (d - b) * i / k) for i in range(k)] + [(c, b + (d - b) * i / k) for i in range(k)]
def dist(p, z):  # Abstand Punkt → Fläche (negativ = innen)
    if z[0] == "c": return math.hypot(p[0] - z[1], p[1] - z[2]) - z[3]
    _, a, b, c, d = z; ex = max(a - p[0], 0, p[0] - c); ey = max(b - p[1], 0, p[1] - d)
    return math.hypot(ex, ey) if ex or ey else -min(p[0] - a, c - p[0], p[1] - b, d - p[1])
ok = True
for (na, za), (nb, zb) in itertools.combinations(Z.items(), 2):
    m = min(min(dist(p, zb) for p in pts(za)), min(dist(p, za) for p in pts(zb)))
    flag = "OK " if m >= 2 else "FEHLER"; ok &= m >= 2
    print(f"{flag} {m:6.1f} mm  {na} ↔ {nb}")
print("ALLES FREI" if ok else "KOLLISION"); sys.exit(0 if ok else 1)
