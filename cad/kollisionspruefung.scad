// Kollisions- und Volumenprüfung: pair=<a>-<b> schneidet zwei Teile in Einbaulage; pair="air" = Innenluft
include <espone.scad>
pair = "";
module P(n) {
    if (n=="body") body(); else if (n=="back") back(); else if (n=="cap") cap();
    else if (n=="woofer") woofer_dummy(); else if (n=="tweeter") tweeter_dummy();
    else if (n=="pr") pr_dummy(); else if (n=="pcb") pcb_dummy();
}
if (pair == "air") difference() {
    intersection() { inner_space(); slab(yBi-1, yR); }
    body(); back(); woofer_dummy(); tweeter_dummy(); pr_dummy(); pcb_dummy();
} else {
    a = search("-", pair)[0];
    intersection() { P(substr(pair, 0, a)); P(substr(pair, a+1)); }
}
function substr(s, i, j=undef) = let(e = j==undef ? len(s) : j) i >= e ? "" : str(s[i], substr(s, i+1, e));
