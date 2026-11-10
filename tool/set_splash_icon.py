"""切换 Android 12+ 启动图标的实现方式：矢量 或 2 倍位图。

    python tool/set_splash_icon.py vector    # 矢量，3.2KB，任意密度可用
    python tool/set_splash_icon.py bitmap    # 2 倍位图，真机上更锐

真机（Redmi M786BC / HyperOS / 520dpi）实测边缘 10-90% 过渡：
    矢量 3px · 位图 2px · 桌面图标(矢量，launcher 渲染) 1px
HyperOS 会把 VectorDrawable 按 intrinsic 尺寸 288px 先栅格化再放大 3.25x，
所以启动画面里矢量反而不如位图。桌面图标不受影响，始终用矢量。
"""

import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from gen_splash_vector import build, vector_xml, write, RES

STYLE_DIRS = ("values-v31", "values-night-v31")
ICON_VECTOR = "@drawable/splash_icon"
ICON_BITMAP = "@drawable/android12splash"

LAUNCH_BG = '''<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@color/splash_background" />
{body}
</layer-list>
'''

BODY_VECTOR = '''    <!-- 矢量图标，288dp 框内居中 -->
    <item
        android:width="288dp"
        android:height="288dp"
        android:gravity="center"
        android:drawable="@drawable/splash_icon" />'''

BODY_BITMAP = '''    <!-- @drawable/splash 为 2 倍图，288dp 框约束其视觉尺寸 -->
    <item
        android:width="288dp"
        android:height="288dp"
        android:gravity="center">
        <bitmap android:gravity="fill" android:src="@drawable/splash" />
    </item>'''


def patch_styles(ref):
    for folder in STYLE_DIRS:
        p = os.path.join(RES, folder, "styles.xml")
        if not os.path.exists(p):
            continue
        with open(p, encoding="utf-8") as f:
            s = f.read()
        new = re.sub(
            r'(<item name="android:windowSplashScreenAnimatedIcon">)[^<]*(</item>)',
            rf"\g<1>{ref}\g<2>", s)
        write(p, new)
        print(f"  {folder}/styles.xml → {ref}")


def main():
    mode = (sys.argv[1] if len(sys.argv) > 1 else "").lower()
    if mode not in ("vector", "bitmap"):
        print(__doc__)
        sys.exit(1)

    if mode == "vector":
        mf, dot, bar, m = build(288, 132 / 288, 0.5, 136 / 288)
        p = os.path.join(RES, "drawable", "splash_icon.xml")
        write(p, vector_xml(288, mf, dot, bar, "splash_icon"))
        print(f"[矢量] splash_icon.xml  {os.path.getsize(p) / 1024:.1f} KB  "
              f"(MF {m['mf_w']:.1f} / cap {m['cap_h']:.1f})")
        patch_styles(ICON_VECTOR)
        body = BODY_VECTOR
    else:
        p = os.path.join(RES, "drawable", "splash_icon.xml")
        if os.path.exists(p):
            os.remove(p)
            print("[位图] 已移除 splash_icon.xml")
        patch_styles(ICON_BITMAP)
        body = BODY_BITMAP

    for folder in ("drawable", "drawable-v21", "drawable-night", "drawable-night-v21"):
        if os.path.isdir(os.path.join(RES, folder)):
            write(os.path.join(RES, folder, "launch_background.xml"),
                  LAUNCH_BG.format(body=body))
    print(f"  launch_background.xml ×4 → {'矢量' if mode == 'vector' else '288dp 约束位图'}")
    print(f"\n完成：启动图标 = {mode}。记得 flutter build / run。")


if __name__ == "__main__":
    main()
