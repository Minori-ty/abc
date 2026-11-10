"""abc 项目：桌面图标走矢量，启动画面走 2 倍位图。

为什么启动图标不用矢量：
    小米 HyperOS 的 SplashScreen 实现会把 VectorDrawable 先栅格化成
    intrinsic 像素尺寸（288px）再放大到屏幕倍率（3.25x），实测边缘过渡 3px；
    而位图是按原生分辨率解码后缩到 936px，边缘过渡 2px。
    真机实测 2px 已是该 ROM 的滤波下限（SystemUI 自身是 1px），所以取位图。

执行顺序：
    dart run flutter_native_splash:create   # 生成位图与 styles（指向 @drawable/android12splash）
    python tool/gen_splash_assets.py        # 位图覆盖成 2 倍
    python tool/gen_splash_vector.py        # 桌面图标矢量 + 约束 <12 的 launch_background
"""

import os
import re

from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen
from fontTools.pens.boundsPen import BoundsPen
from fontTools.ttLib import TTFont

PROJ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RES = os.path.join(PROJ, "android", "app", "src", "main", "res")
FONT_PATH = os.path.join(PROJ, "assets", "fonts", "Poppins-Bold.ttf")
GREEN = "#87E6B4"
WHITE = "#FFFFFF"


def tidy(path_data, nd=2):
    def r(m):
        v = round(float(m.group(0)), nd)
        return (f"{v:.{nd}f}").rstrip("0").rstrip(".") or "0"
    return re.sub(r"-?\d+\.\d+", r, path_data)


def build(canvas, mf_w_ratio, cx_ratio, cy_ratio):
    font = TTFont(FONT_PATH)
    glyphset = font.getGlyphSet()
    cmap = font.getBestCmap()
    glyphs = [cmap[ord("M")], cmap[ord("F")]]

    cursor, spans, xmin, xmax = 0, [], 1e9, -1e9
    for gname in glyphs:
        bp = BoundsPen(glyphset)
        glyphset[gname].draw(bp)
        x0, y0, x1, y1 = bp.bounds
        spans.append((gname, cursor))
        xmin, xmax = min(xmin, cursor + x0), max(xmax, cursor + x1)
        cursor += glyphset[gname].width

    mf_w = canvas * mf_w_ratio
    scale = mf_w / (xmax - xmin)
    cap_h = font["OS/2"].sCapHeight * scale

    gap = mf_w * (22 / 132)
    bar_h = mf_w * (18 / 132)
    bar_w = mf_w * 0.5
    dot_d = bar_h
    step = gap * 0.55

    cx, cy = canvas * cx_ratio, canvas * cy_ratio
    top = cy - (cap_h + gap + bar_h) / 2
    baseline = top + cap_h
    left = cx - (dot_d + step + bar_w) / 2

    parts = []
    for gname, adv in spans:
        pen = SVGPathPen(glyphset)
        tx = (cx - mf_w / 2) - xmin * scale + adv * scale
        glyphset[gname].draw(TransformPen(pen, (scale, 0, 0, -scale, tx, baseline)))
        parts.append(pen.getCommands())
    mf_path = tidy(" ".join(parts))

    bar_top = top + cap_h + gap
    r = dot_d / 2
    dcx, dcy = left + r, bar_top + r
    dot_path = (f"M{dcx - r:.2f},{dcy:.2f} a{r:.2f},{r:.2f} 0 1,0 {2 * r:.2f},0 "
                f"a{r:.2f},{r:.2f} 0 1,0 {-2 * r:.2f},0")

    bx, by = left + dot_d + step, bar_top
    br = bar_h / 2
    bar_path = (f"M{bx + br:.2f},{by:.2f} L{bx + bar_w - br:.2f},{by:.2f} "
                f"A{br:.2f},{br:.2f} 0 0,1 {bx + bar_w:.2f},{by + br:.2f} "
                f"L{bx + bar_w:.2f},{by + bar_h - br:.2f} "
                f"A{br:.2f},{br:.2f} 0 0,1 {bx + bar_w - br:.2f},{by + bar_h:.2f} "
                f"L{bx + br:.2f},{by + bar_h:.2f} "
                f"A{br:.2f},{br:.2f} 0 0,1 {bx:.2f},{by + bar_h - br:.2f} "
                f"L{bx:.2f},{by + br:.2f} "
                f"A{br:.2f},{br:.2f} 0 0,1 {bx + br:.2f},{by:.2f} z")

    return mf_path, dot_path, bar_path, dict(cap_h=cap_h, mf_w=mf_w, top=top)


def vector_xml(canvas, mf, dot, bar, name):
    return f'''<?xml version="1.0" encoding="utf-8"?>
<!-- MF 字标矢量版（桌面图标用）。生成脚本 tool/gen_splash_vector.py，勿手改。 -->
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:name="{name}"
    android:width="{canvas}dp"
    android:height="{canvas}dp"
    android:viewportWidth="{canvas}"
    android:viewportHeight="{canvas}">
    <path android:fillColor="{WHITE}" android:pathData="{mf}" />
    <path android:fillColor="{GREEN}" android:pathData="{dot}" />
    <path android:fillColor="{GREEN}" android:pathData="{bar}" />
</vector>
'''


MONO_XML = '''<?xml version="1.0" encoding="utf-8"?>
<!-- Android 13+ 主题图标单色层 -->
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="{canvas}dp"
    android:height="{canvas}dp"
    android:viewportWidth="{canvas}"
    android:viewportHeight="{canvas}">
    <path android:fillColor="#FFFFFFFF" android:pathData="{mf}" />
    <path android:fillColor="#FFFFFFFF" android:pathData="{dot}" />
    <path android:fillColor="#FFFFFFFF" android:pathData="{bar}" />
</vector>
'''

# <12 的启动背景：纯色 + 2 倍位图，用 288dp 框约束视觉尺寸
LAUNCH_BG = '''<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@color/splash_background" />
    <!-- @drawable/splash 为 2 倍图，288dp 框约束其视觉尺寸 -->
    <item
        android:width="288dp"
        android:height="288dp"
        android:gravity="center">
        <bitmap android:gravity="fill" android:src="@drawable/splash" />
    </item>
</layer-list>
'''

ADAPTIVE = '''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background" />
    <foreground android:drawable="@drawable/ic_launcher_foreground" />
    <monochrome android:drawable="@drawable/ic_launcher_monochrome" />
</adaptive-icon>
'''


def write(path, text):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write(text)


def main():
    # 自适应图标前景：108 视口，内容占 48.1%，收在 66dp 安全圆内
    mf, dot, bar, m = build(108, 0.481, 0.5, 0.5)
    print(f"[桌面图标 108] cap {m['cap_h']:.1f}  字宽 {m['mf_w']:.1f}  bbox 顶 {m['top']:.1f}")

    write(os.path.join(RES, "drawable", "ic_launcher_foreground.xml"),
          vector_xml(108, mf, dot, bar, "ic_launcher_foreground"))
    write(os.path.join(RES, "drawable", "ic_launcher_monochrome.xml"),
          MONO_XML.format(canvas=108, mf=mf, dot=dot, bar=bar))
    write(os.path.join(RES, "mipmap-anydpi-v26", "ic_launcher.xml"), ADAPTIVE)
    print("  ic_launcher_foreground.xml / ic_launcher_monochrome.xml / mipmap-anydpi-v26/ic_launcher.xml")

    # <12 的 layer-list 约束尺寸（位图是 2 倍）
    for folder in ("drawable", "drawable-v21", "drawable-night", "drawable-night-v21"):
        p = os.path.join(RES, folder, "launch_background.xml")
        if os.path.isdir(os.path.join(RES, folder)):
            write(p, LAUNCH_BG)
    print("  launch_background.xml ×4 → 纯色 + 288dp 约束位图")

    # 清理被矢量取代的 mipmap 位图
    import glob
    n = 0
    for pat in ("mipmap-*/ic_launcher_foreground.png", "mipmap-*/ic_launcher_monochrome.png"):
        for p in glob.glob(os.path.join(RES, pat.replace("/", os.sep))):
            os.remove(p)
            n += 1
    print(f"  清理 mipmap 位图 {n} 个")


if __name__ == "__main__":
    main()
