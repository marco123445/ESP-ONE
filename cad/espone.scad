// ESP-ONE – DIY WLAN-Lautsprecher, parametrisches Gehäuse v5.0 (Innenraum = v4; Wand 8 mm für 3+3 Wandlinien → steifer + schneller; Kappe 2,4 mm mit grösseren Löchern)
// Bestückung: Visaton W 100 S – 4 Ω (Art. 9020) · Visaton G 25 NDWG – 8 Ω (Art. 1188) · Passivmembran 4" AliExpress (GHXAMP 105 mm)
// Alles M3 + Gewindeeinsätze. Drucker: Bambu P1S (256³). Masse in mm.
// Koordinaten: x = Breite, y = Tiefe (Front bei -D/2), z = Höhe.
//
// Teile (part=…), alle OHNE Stützen druckbar:
//   "body"     Korpus mit Schallwand          – Druck: Front nach UNTEN
//   "back"     Rückwand (PR, DC, Platine)      – Druck: Aussenseite nach UNTEN
//   "cap"      Frontkappe mit Lochgitter       – Druck: Sichtseite nach UNTEN
//   "testfit"  Passprobe                       – ZUERST drucken
//   "preview" / "explode"                      – Ansichten
part = "preview";

// ---------------- Hauptmasse ----------------
W = 154; H = 232; D = 134.4;      // aussen (inkl. Kappe); Innenraum netto 2.57 L wie v4
R = 12;                         // Eckenradius Draufsicht (flache Front = W - 2R = 126 ≥ Flansch 122)
E = 5;                          // Kantenfase oben/unten
wall = 8;                       // Wand (Sandwich: 3 Wandlinien je Seite + 15 % Gyroid) – steifer als v4 bei weniger Material
back_t = 8;                     // Rückwand
baffle_t = 15;                  // Schallwand (steif, Platz für Flanschtaschen + Einsätze)
cap_front = 2.4; cap_gap = 8;     // Gitterplatte + Luftspalt vor der Schallwand
skirt = 2; overlap = 6;         // Kappen-Schürze, Überdeckung des Korpus
tip = 0;                        // keine Rest-Stufe: Zunge läuft mit 60° bis auf die Aussenwand
slope = 60;                     // Winkel des Übergangs zur Waagrechten (Druckrichtung) – ≥ 45° = stützenfrei
cap_tip = 0.5;                  // Kappe endet dort, wo ihre Wand noch 0.5 mm dick ist
cap_clr = 0.2;                  // Spiel Kappe ↔ Zunge
yF  = -D/2;
yB  = yF + cap_front + cap_gap; // Schallwand-Vorderseite
yS  = yB + overlap;             // Fuge Kappe/Korpus
yBi = yB + baffle_t;            // Schallwand-Rückseite
yR  = D/2 - back_t;             // Trennebene Korpus/Rückwand

// ---------------- Treiber (Datenblätter) ----------------
// Visaton W 100 S: Flansch Ø122 × 6, 5 × Ø3.7 auf Ø111, Ausschnitt Ø94, Korb 48 tief, Magnet Ø70
woofer_z = 84; woofer_cut = 94.5; woofer_fl = 122; woofer_fl_t = 6; woofer_pcd = 111; woofer_n = 5;
// Visaton G 25 NDWG: Flansch Ø66.5 × 4, 4 × Ø4 auf Ø56 (45°), Ausschnitt Ø45, Gehäuse Ø44/Ø32, Tiefe 25.9
tweeter_z = 183; tweeter_cut = 45.5; tweeter_fl = 66.5; tweeter_fl_t = 4; tweeter_pcd = 56;
// Passivmembran GHXAMP 4": Rahmen 105, Ausschnitt 95, Höhe 31.2, 4 Löcher auf Lochkreis 113 (= Quadrat 79.9)
pr_z = 132; pr_cut = 95.4; pr_sq = 105; pr_holes = 79.9; pr_h = 31.2;
// DC-Einbaubuchse DC-099 (5.5/2.1, M11)
dc_x = 55; dc_z = 34; dc_hole = 11.3;
// Louder ESP32 rev H7: 85 × 56, Löcher Ø3.05 bei (3.5,3.5) (3.5,52.5) (61.5,52.5)
pcb_w = 85; pcb_h = 56; pcb_x0 = -48; pcb_z0 = 14; standoff = 7; standoff_d = 8.5;
pcb_holes = [[3.5,3.5],[3.5,52.5],[61.5,52.5]];
// Frontkappe: 4 × M3×12 Zylinderkopf, Kopf versenkt (ausserhalb Tieftöner und Hochtöner)
cap_pos = [[-45, 11], [45, 11], [-45, H-11], [45, H-11]];
// Gewindeeinsätze M3 (5.7 lang, Bohrung 4.0)
ins_d = 4.0; ins_l = 7; ins_depth = 6.5;
col_d = 12;
cols = [[-(W/2-wall-4), wall+4], [W/2-wall-4, wall+4], [-(W/2-wall-4), H-wall-4], [W/2-wall-4, H-wall-4],
        [-(W/2-wall-1.5), H/2], [W/2-wall-1.5, H/2]];
rib_t = 4; rib_h = 6;
side_ribs = [68, 168];

$fn = 72;

// ---------------- Grundformen ----------------
module rbox(w, d, h, r, e) {
    hull() for (x = [-1, 1], y = [-1, 1]) {
        translate([x*(w/2-r), y*(d/2-r), e]) cylinder(r=r, h=h-2*e);
        translate([x*(w/2-r), y*(d/2-r), 0]) cylinder(r=r-e, h=h);
    }
}
module outer() { rbox(W, D, H, R, E); }
module inset(s) { translate([0, 0, s]) rbox(W-2*s, D-2*s, H-2*s, R-s, max(E-s, 0.01)); }
module slab(y0, y1) { translate([-W, y0, -1]) cube([2*W, y1-y0, H+2]); }
module ycyl(d, y0, y1, x, z) { translate([x, y1, z]) rotate([90,0,0]) cylinder(d=d, h=y1-y0); }
module sq_holes(s, d, y0, y1, zc) { for (i=[-1,1], j=[-1,1]) ycyl(d, y0, y1, i*s/2, zc + j*s/2); }
module pcd_holes(pcd, n, a0, d, y0, y1, zc) { for (k = [0:n-1]) ycyl(d, y0, y1, pcd/2*cos(a0+k*360/n), zc + pcd/2*sin(a0+k*360/n)); }
// Zunge unter der Kappe: gerade bis yS-(skirt-tip), dann 45°-Schräge bis yS. c = Aufmass (Kappe: Spiel)
ch = (skirt - tip) * tan(slope);                                   // Länge des Übergangs in Druckrichtung
yCe = yS - ch + (skirt - cap_clr - cap_tip) * ch / (skirt - tip);  // Ende der Kappe
module tongue(y0, c=0) {
    union() {
        intersection() { inset(skirt-c); slab(y0, yS-ch); }
        hull() {
            intersection() { inset(skirt-c); slab(yS-ch-0.01, yS-ch); }
            intersection() { inset(tip-c); slab(yS-0.01, yS); }
        }
    }
}
module inner_space() { translate([0, 0, wall]) rbox(W-2*wall, D-2*wall, H-2*wall, R-wall+0.01, 0.01); }

// ---------------- Korpus ----------------
module body() {
    difference() {
        union() {
            difference() {
                union() {
                    intersection() { outer(); slab(yS, yR); }
                    tongue(yB);                                                    // Zunge mit 45°-Übergang
                }
                intersection() { inner_space(); slab(yBi, yR+1); }
            }
            intersection() {
                inner_space();
                union() {
                    for (c = cols) ycyl(col_d, yBi-1, yR, c[0], c[1]);
                    for (s = [-1, 1], z = side_ribs)
                        translate([s > 0 ? W/2-wall-rib_h : -(W/2-wall)-0.01, yBi-1, z - rib_t/2]) cube([rib_h+0.01, yR-yBi+1, rib_t]);
                    translate([-rib_t/2, yBi-1, wall-0.01]) cube([rib_t, yR-yBi+1, rib_h]);
                    translate([-rib_t/2, yBi-1, H-wall-rib_h]) cube([rib_t, yR-yBi+1, rib_h+0.01]);
                }
            }
        }
        // Tieftöner: Ausschnitt, Fase hinten, Flanschtasche, 5 Einsätze
        ycyl(woofer_cut, yB-1, yBi+1, 0, woofer_z);
        translate([0, yBi-4, woofer_z]) rotate([-90,0,0]) cylinder(d1=woofer_cut, d2=woofer_cut+8, h=4.01);
        ycyl(woofer_fl+0.6, yB-1, yB+woofer_fl_t, 0, woofer_z);
        pcd_holes(woofer_pcd, woofer_n, 90, ins_d, yB-1, yB+woofer_fl_t+ins_depth, woofer_z);
        // Hochtöner: Ausschnitt, Flanschtasche, 4 Einsätze
        ycyl(tweeter_cut, yB-1, yBi+1, 0, tweeter_z);
        ycyl(tweeter_fl+0.6, yB-1, yB+tweeter_fl_t, 0, tweeter_z);
        pcd_holes(tweeter_pcd, 4, 45, ins_d, yB-1, yB+tweeter_fl_t+ins_depth, tweeter_z);
        // Frontkappe + Rückwand
        for (m = cap_pos) ycyl(ins_d, yB-1, yB+ins_depth, m[0], m[1]);
        for (c = cols) ycyl(ins_d, yR-ins_l, yR+1, c[0], c[1]);
    }
}

// ---------------- Rückwand ----------------
module back() {
    difference() {
        union() {
            intersection() { outer(); slab(yR, D/2+1); }
            intersection() {
                inner_space();
                union() {
                    translate([0, yR+0.01, pr_z]) rotate([90,0,0]) difference() { cylinder(d=pr_cut+15, h=rib_h); translate([0,0,-1]) cylinder(d=pr_cut+3, h=rib_h+2); }
                    translate([-W/2, yR-rib_h, pcb_z0+pcb_h+3]) cube([W, rib_h+0.01, rib_t]);
                    for (p = pcb_holes) translate([pcb_x0+p[0], yR+0.01, pcb_z0+p[1]]) rotate([90,0,0]) cylinder(d=standoff_d, h=standoff);
                }
            }
        }
        ycyl(pr_cut, yR-rib_h-1, D/2+1, 0, pr_z);
        sq_holes(pr_holes, ins_d, D/2-ins_depth, D/2+1, pr_z);
        ycyl(dc_hole, yR-1, D/2+1, dc_x, dc_z);
        for (p = pcb_holes) ycyl(ins_d, yR-standoff-1, yR-standoff+ins_depth, pcb_x0+p[0], pcb_z0+p[1]);
        for (c = cols) { ycyl(3.4, yR-1, D/2+1, c[0], c[1]); ycyl(6.4, D/2-3.2, D/2+1, c[0], c[1]); }
    }
}

// ---------------- Frontkappe ----------------
module cap() {
    gw = W - 2*R - 4; gh = H - 2*E - 14; hole = 4.5; pitch = 6.0;   // ca. gleich viel offene Fläche wie 3.6/4.9, halb so viele Löcher
    difference() {
        union() {
            difference() {
                intersection() { outer(); slab(yF, yCe); }
                tongue(yF+cap_front, cap_clr);                                     // gleiche 60°-Schräge + Spiel
            }
            for (m = cap_pos) ycyl(11, yF+cap_front-0.01, yB-0.3, m[0], m[1]);
        }
        translate([0, yF-1, H/2]) rotate([-90,0,0]) linear_extrude(cap_front+2)
            for (i = [0:floor(gw/pitch)+1], j = [0:floor(gh/(pitch*0.866))+1]) {
                x = -gw/2 + i*pitch + (j%2)*pitch/2;
                z = -gh/2 + j*pitch*0.866;
                if (abs(x) <= gw/2 && abs(z) <= gh/2 && min([for (m = cap_pos) norm([x-m[0], (z+H/2)-m[1]])]) > 7.5)
                    translate([x, z]) circle(d=hole, $fn=6);
            }
        for (m = cap_pos) {
            ycyl(3.4, yF-1, yB+1, m[0], m[1]);
            ycyl(6.2, yF-1, yF+3.2, m[0], m[1]);                                                // Senkung für Zylinderkopf ISO 4762 (Kopf Ø5.5 × 3) → M3×12
        }
    }
}

// ---------------- Passprobe (flach, 250 × 185 × 3) ----------------
module testfit() {
    t = 3; wz = 62; px = 125; tx = -30; tz = 152;
    difference() {
        translate([-62, 0, 0]) cube([250, 185, t]);
        translate([0, wz, -1]) { cylinder(d=woofer_cut, h=t+2); for (k = [0:woofer_n-1]) rotate(90+k*72) translate([woofer_pcd/2, 0, 0]) cylinder(d=ins_d, h=t+2); }
        translate([px, wz, -1]) { cylinder(d=pr_cut, h=t+2); for (i=[-1,1], j=[-1,1]) translate([i*pr_holes/2, j*pr_holes/2, 0]) cylinder(d=ins_d, h=t+2); }
        translate([tx, tz, -1]) { cylinder(d=tweeter_cut, h=t+2); for (k = [0:3]) rotate(45+k*90) translate([tweeter_pcd/2, 0, 0]) cylinder(d=ins_d, h=t+2); }
        translate([150, 150, -1]) cylinder(d=dc_hole, h=t+2);
        translate([175, 132, -1]) cylinder(d=3.4, h=t+2);    // M3 Durchgang
        translate([175, 168, -1]) cylinder(d=ins_d, h=t+2);  // Einsatz
        // Platinenumriss als 0.6-mm-Nut
        translate([30, 125, t-0.6]) difference() { cube([pcb_w, pcb_h, 1]); translate([0.8, 0.8, -1]) cube([pcb_w-1.6, pcb_h-1.6, 3]); }
    }
    translate([30, 125, 0]) for (p = pcb_holes) translate([p[0], p[1], 0]) cylinder(d=2.9, h=t+4);   // Stifte für die Platinenlöcher
}

// ---------------- Dummies (Ansicht + Kollisionsprüfung) ----------------
module woofer_dummy() {
    color([0.15,0.15,0.16]) translate([0, yB, woofer_z]) rotate([-90,0,0]) {
        cylinder(d=woofer_fl, h=woofer_fl_t);
        translate([0,0,woofer_fl_t]) cylinder(d1=94, d2=72, h=26);
        translate([0,0,woofer_fl_t+26]) cylinder(d=70, h=48-26);
    }
    color([0.55,0.57,0.6]) translate([0, yB+3, woofer_z]) rotate([-90,0,0]) cylinder(d=84, h=0.6);
}
module tweeter_dummy() {
    color([0.15,0.15,0.16]) translate([0, yB, tweeter_z]) rotate([-90,0,0]) {
        cylinder(d=tweeter_fl, h=tweeter_fl_t);
        translate([0,0,tweeter_fl_t]) cylinder(d=44, h=14.6-tweeter_fl_t);
        translate([0,0,14.6]) cylinder(d=32, h=25.9-14.6);
    }
    color([0.4,0.4,0.42]) translate([0, yB+2, tweeter_z]) scale([1, 0.3, 1]) sphere(d=26);   // Kalotte im Waveguide
}
module pr_dummy() {
    color([0.15,0.15,0.16]) translate([0, D/2, pr_z]) rotate([90,0,0]) {
        translate([-pr_sq/2, -pr_sq/2, -3]) cube([pr_sq, pr_sq, 3]);
        cylinder(d1=94, d2=80, h=pr_h-3);
    }
    color([0.6,0.62,0.65]) translate([0, D/2+3.2, pr_z]) rotate([90,0,0]) cylinder(d=78, h=0.6);
}
module pcb_dummy() {
    translate([pcb_x0, yR-standoff-1.6, pcb_z0]) {
        color([0.1,0.35,0.15]) cube([pcb_w, 1.6, pcb_h]);
        color([0.2,0.2,0.2]) translate([3, -15, 3]) cube([pcb_w-6, 15, pcb_h-6]);
    }
    color([0.1,0.1,0.1]) translate([dc_x, D/2+2, dc_z]) rotate([90,0,0]) { cylinder(d=11, h=back_t+16); translate([0,0,back_t+2]) cylinder(d=14, h=3); }
}

module assembly(ex=0) {
    color([0.92,0.91,0.88]) body();
    color([0.90,0.89,0.86]) translate([0, -ex, 0]) cap();
    color([0.88,0.87,0.84]) translate([0, ex, 0]) back();
    translate([0, -ex*0.5, 0]) { woofer_dummy(); tweeter_dummy(); }
    translate([0, ex, 0]) { pr_dummy(); pcb_dummy(); }
}

if (part == "body") rotate([90,0,0]) translate([0, -yB, 0]) body();
else if (part == "back") rotate([-90,0,0]) translate([0, -D/2, 0]) back();
else if (part == "cap") rotate([90,0,0]) translate([0, D/2, 0]) cap();
else if (part == "testfit") testfit();
else if (part == "explode") assembly(70);
else if (part == "body_v") body();
else if (part == "back_v") back();
else if (part == "cap_v") cap();
else if (part == "woofer_v") woofer_dummy();
else if (part == "tweeter_v") tweeter_dummy();
else if (part == "pr_v") pr_dummy();
else if (part == "pcb_v") pcb_dummy();
else if (part == "preview") assembly(0);
