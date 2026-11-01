"""Rendert die STL-Teile aus speaker.scad zu Vorschaubildern (eigener Z-Buffer-Rasterizer, ohne OpenGL)."""
from pathlib import Path
import numpy as np
from PIL import Image, ImageFilter

HERE = Path(__file__).parent
PARTS = {  # Datei: Grundfarbe (RGB 0..1)
    "body_v.stl": (0.92, 0.91, 0.88),
    "cap_v.stl": (0.90, 0.89, 0.86),
    "back_v.stl": (0.88, 0.87, 0.84),
    "woofer_v.stl": (0.20, 0.21, 0.23),
    "tweeter_v.stl": (0.20, 0.21, 0.23),
    "pr_v.stl": (0.26, 0.27, 0.29),
    "pcb_v.stl": (0.12, 0.40, 0.20),
}
SS = 2  # Supersampling


def load_stl(path):
    v = [list(map(float, l.split()[1:4])) for l in open(path, encoding="ascii", errors="ignore") if l.lstrip().startswith("vertex")]
    return np.array(v).reshape(-1, 3, 3)


def render(out, elev, azim, size=(1100, 1300), dist=620, target=(0, 0, 100), fl=5200, colors=None, offsets=None, skip=()):
    colors = colors or PARTS; offsets = offsets or {}
    w, h = size[0] * SS, size[1] * SS
    el, az = np.radians(elev), np.radians(azim)
    tgt = np.array(target, float)
    eye = tgt + dist * np.array([np.cos(el) * np.cos(az), np.cos(el) * np.sin(az), np.sin(el)])
    f = (tgt - eye) / np.linalg.norm(tgt - eye)
    r = np.cross(f, [0, 0, 1]); r /= np.linalg.norm(r)
    u = np.cross(r, f)
    key = (eye - tgt) / dist * 0.6 + np.array([0.3, -0.2, 0.9]); key /= np.linalg.norm(key)

    zbuf = np.full((h, w), np.inf)
    img = np.zeros((h, w, 3))
    alpha = np.zeros((h, w))
    for name, base in colors.items():
        if name in skip:
            continue
        t = load_stl(HERE / name) + np.array(offsets.get(name, (0, 0, 0)))
        n = np.cross(t[:, 1] - t[:, 0], t[:, 2] - t[:, 0])
        n /= np.linalg.norm(n, axis=1, keepdims=True) + 1e-12
        rel = t - eye
        cx, cy, cz = rel @ r, rel @ u, rel @ f
        sx = w / 2 + fl * SS / 2 * cx / cz
        sy = h / 2 - fl * SS / 2 * cy / cz
        # Rückseiten weglassen
        area = (sx[:, 1] - sx[:, 0]) * (sy[:, 2] - sy[:, 0]) - (sx[:, 2] - sx[:, 0]) * (sy[:, 1] - sy[:, 0])
        view = -(t.mean(axis=1) - eye); view /= np.linalg.norm(view, axis=1, keepdims=True)
        diff = np.clip(n @ key, 0, 1)
        half = (key + view); half /= np.linalg.norm(half, axis=1, keepdims=True)
        spec = np.clip(np.sum(n * half, axis=1), 0, 1) ** 40 * 0.25
        col = np.clip(np.outer(0.38 + 0.62 * diff, base) + spec[:, None], 0, 1)
        for i in np.nonzero(area < 0)[0]:
            xs, ys, zs = sx[i], sy[i], cz[i]
            x0, x1 = max(int(xs.min()), 0), min(int(xs.max()) + 1, w - 1)
            y0, y1 = max(int(ys.min()), 0), min(int(ys.max()) + 1, h - 1)
            if x0 > x1 or y0 > y1:
                continue
            X, Y = np.meshgrid(np.arange(x0, x1 + 1) + 0.5, np.arange(y0, y1 + 1) + 0.5)
            d = (ys[1] - ys[2]) * (xs[0] - xs[2]) + (xs[2] - xs[1]) * (ys[0] - ys[2])
            if abs(d) < 1e-9:
                continue
            a = ((ys[1] - ys[2]) * (X - xs[2]) + (xs[2] - xs[1]) * (Y - ys[2])) / d
            b = ((ys[2] - ys[0]) * (X - xs[2]) + (xs[0] - xs[2]) * (Y - ys[2])) / d
            c = 1 - a - b
            m = (a >= -1e-6) & (b >= -1e-6) & (c >= -1e-6)
            if not m.any():
                continue
            z = a * zs[0] + b * zs[1] + c * zs[2]
            sub = zbuf[y0:y1 + 1, x0:x1 + 1]
            m &= z < sub
            sub[m] = z[m]
            img[y0:y1 + 1, x0:x1 + 1][m] = col[i]
            alpha[y0:y1 + 1, x0:x1 + 1][m] = 1
    rgba = np.dstack([img, alpha])
    im = Image.fromarray((rgba * 255).astype(np.uint8), "RGBA").resize(size, Image.LANCZOS)
    im.save(out)


if __name__ == "__main__":
    BLACK = dict(PARTS, **{"body_v.stl": (0.25, 0.25, 0.26), "cap_v.stl": (0.22, 0.22, 0.23), "back_v.stl": (0.24, 0.24, 0.25)})
    render(HERE / "front.png", 12, -60)
    render(HERE / "back.png", 12, 125)
    render(HERE / "front_black.png", 10, -78, colors=BLACK)
    ex = {"cap_v.stl": (0, -110, 0), "woofer_v.stl": (0, -55, 0), "tweeter_v.stl": (0, -55, 0),
          "back_v.stl": (0, 110, 0), "pr_v.stl": (0, 150, 0), "pcb_v.stl": (0, 110, 0)}
    render(HERE / "explode.png", 18, -38, size=(1600, 1100), dist=900, target=(0, 0, 100), fl=4300, offsets=ex)
    print("ok")
