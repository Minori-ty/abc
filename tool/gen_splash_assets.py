"""abc 项目启动图标生成器（2 倍图版本）。

用法（顺序不能换）：
    dart run flutter_native_splash:create
    python tool/gen_splash_assets.py

flutter_native_splash 只按 1x 生成各密度，本脚本把它覆盖成 2 倍像素。
系统会把 windowSplashScreenAnimatedIcon 塞进固定的 288dp 框内 fitCenter，
所以像素翻倍不会改变图标视觉大小，只会让它被下采样 —— 边缘更锐。
"""

import json
import os
import sys

from PIL import Image, ImageDraw, ImageFont

PROJ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RES = os.path.join(PROJ, "android", "app", "src", "main", "res")
FONT = os.path.join(PROJ, "assets", "fonts", "Poppins-Bold.ttf")

BLUE = (37, 99, 235, 255)
GREEN = (135, 230, 180, 255)
WHITE = (255, 255, 255, 255)

# 288 画布基准的比例（与设计稿一致）
R_MF_W = 132 / 288      # MF 字宽 / 画布
R_BAR_W = 66 / 132
R_BAR_H = 18 / 132
R_GAP = 22 / 132
R_CY = 136 / 288        # 整组视觉中心（上移 8 平衡重心）

SCALE = 2               # ← 二倍图
MASTER = 4608           # 主渲染分辨率，所有尺寸由它降采样
BUCKETS = [("mdpi", 288), ("hdpi", 432), ("xhdpi", 576),
           ("xxhdpi", 864), ("xxxhdpi", 1152)]


def fit_font(path, text, target_w, lo=8, hi=20000):
    while lo < hi:
        mid = (lo + hi + 1) // 2
        if ImageFont.truetype(path, mid).getlength(text) <= target_w:
            lo = mid
        else:
            hi = mid - 1
    return ImageFont.truetype(path, lo)


def draw_mark(canvas, mf_w_ratio):
    """透明底 + 白色 MF + 绿色进度条，几何按 288 网格等比缩放。"""
    n = canvas
    img = Image.new("RGBA", (n, n), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)

    mf_w = n * mf_w_ratio
    font = fit_font(FONT, "MF", mf_w)
    bx0, by0, bx1, by1 = font.getbbox("MF")
    cap_h = by1 - by0

    bar_w = mf_w * R_BAR_W
    bar_h = mf_w * R_BAR_H
    gap = mf_w * R_GAP
    dot_d = bar_h

    top = n * R_CY - (cap_h + gap + bar_h) / 2
    d.text((((n - mf_w) / 2) - bx0, top - by0), "MF", font=font, fill=WHITE,
           stroke_width=max(1, int(font.size * 0.014)), stroke_fill=WHITE)

    bar_top = top + cap_h + gap
    step = gap * 0.55
    left = (n - (dot_d + step + bar_w)) / 2
    d.ellipse([left, bar_top, left + dot_d, bar_top + bar_h], fill=GREEN)
    x = left + dot_d + step
    d.rounded_rectangle([x, bar_top, x + bar_w, bar_top + bar_h],
                        radius=bar_h / 2, fill=GREEN)
    return img


def save(img, folder, name):
    path = os.path.join(RES, folder, name)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    img.save(path, "PNG", optimize=True)
    print(f"  {folder}/{name:26s} {img.size[0]}x{img.size[1]}")


def main():
    master = draw_mark(MASTER, R_MF_W)

    # 素材源文件也一并留 2 倍
    splash_dir = os.path.join(PROJ, "assets", "splash")
    os.makedirs(splash_dir, exist_ok=True)
    for name in ("splash_mark.png", "splash_mark_android12.png"):
        master.resize((MASTER // 2, MASTER // 2), Image.LANCZOS).save(
            os.path.join(splash_dir, name), "PNG", optimize=True)
    print(f"[源图] assets/splash/  2x = {MASTER // 2}px")

    print(f"[android12splash] {SCALE}x")
    for dpi, base in BUCKETS:
        im = master.resize((base * SCALE, base * SCALE), Image.LANCZOS)
        for folder in (f"drawable-{dpi}", f"drawable-night-{dpi}"):
            if os.path.isdir(os.path.join(RES, folder)):
                save(im, folder, "android12splash.png")

    print(f"[splash <12] {SCALE}x 位图（矢量版由 gen_splash_vector.py 接管，此处只留兜底）")
    for dpi, base in BUCKETS:
        im = master.resize((base * SCALE, base * SCALE), Image.LANCZOS)
        save(im, f"drawable-{dpi}", "splash.png")


LAYER_LIST = """<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item>
        <bitmap android:gravity="fill" android:src="@drawable/background"/>
    </item>
    <!-- splash.png 为 2 倍图，这里用 288dp 框约束其视觉尺寸 -->
    <item
        android:width="288dp"
        android:height="288dp"
        android:gravity="center">
        <bitmap android:gravity="fill" android:src="@drawable/splash"/>
    </item>
</layer-list>
"""


if __name__ == "__main__":
    main()
