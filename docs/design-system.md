# CRM App 设计系统规范（Figma 提炼）

> 来源：Figma 文件 `最满意的`（fileKey `VHrGFBHISrJt8uSnkTjwdc`），含 1 个 Screens 画板组（22 屏，含暗色变体）+ 1 个 Components 库（21 个组件）+ 1 个隐藏 Tokens 画板。
> 提取方式：Figma Dev Mode MCP（get_metadata / get_variable_defs / get_design_context / get_screenshot），变量均为真实取值，非目测。
> 设备基准：412 × 892 移动端单列。

---

## 1. 布局栅格

| 项 | 值 |
|---|---|
| 画板 | 412 × 892 |
| 页面左右安全边距 | 24 |
| 内容列宽 | 364 |
| 状态栏 | 高 28 |
| 底部导航 | 高 72（4 项） |
| 首屏标题基线区 | 标题 y=44（H1/24），副标题 y=76（Caption/12），间距 2 |
| 区块节奏 | 标题区 → 搜索 24；搜索 → 筛选 14；筛选 → 分组头 20；分组头 → 列表 12 |
| 列表行间距 | 10（行高 64） |
| 悬浮按钮 | 56 × 56 圆形，右下，距边 24，浮于底部导航之上（导航上有渐变遮罩） |

**结论**：不是严格 8pt 栅格，而是 4/8/10/12/14/16/20/24 的混合节奏；24 是页面级唯一基准，12 是组件级基准。

---

## 2. 色彩 Token（Light / Dark 双模）

| Token | Light | Dark | 用途 |
|---|---|---|---|
| `color/bg` | `#f8fafc` | `#0b1220` | 页面底色 |
| `color/card` | `#ffffff` | `#111c2e` | 卡片、输入框、导航 |
| `color/muted` | `#f1f5fd` | `#172437` | 次级填充（chip 底、图标底） |
| `color/border` | `#e4ecfc` | `#2b3c57` | 1px 描边（暗色下承担主要层次） |
| `color/fg` | `#0f172a` | `#e6edf8` | 主文字 |
| `color/mutedFg` | `#475569` | `#9fb0c7` | 次级文字 |
| `color/primary` | `#2563eb` | `#60a5fa` | 主色实底（按钮、hero 卡、激活态） |
| `color/primaryText` | `#1d4ed8` | `#60a5fa` | 主色文字/图标（浅底上） |
| `color/primarySoft` | `#dbeafe` | `#1b3350` | 主色浅底（头像底、图标底） |
| `color/onPrimary` | `#ffffff` | `#0b1220` | 主色上的文字（暗色下反转为深色） |
| `color/accent` | `#059669` | `#34d399` | 正向数值、成功 |
| `color/accentText` | `#047857` | `#34d399` | 正向文字（浅底） |
| `color/accentSoft` | `#d1fae5` | `#12352b` | 成功浅底 |
| `color/warning` | `#f59e0b` | `#fbbf24` | 警示实色 |
| `color/warningText` | `#b45309` | `#fbbf24` | 警示文字 |
| `color/destructive` | `#dc2626` | `#f87171` | 危险操作 |
| `color/destructiveText` | `#b91c1c` | — | 危险文字 |
| `color/destructiveSoft` | `#fee2e2` | — | 危险浅底 |
| `color/scrim` | `#0f172a` | — | 弹层遮罩（约 50% 不透明） |
| `color/ink` / `color/white` / `color/onAccent` | `#0f172a` / `#ffffff` / `#ffffff` | — | 备用绝对色 |

**对比度实测（WCAG）**：主文字 17.1:1、次级文字 7.6:1、白色文字压在 primary 上 5.17:1、主色文字 6.7:1、暗色主文字 15.9:1、暗色次级 7.7:1、暗色 primary 6.7:1 —— 全部 ≥ AA（4.5:1），主色实底按钮上的白字是全场最低值 5.17:1，仍达标。

**未被任何节点绑定的 token**（可清理）：`color/primaryDark`、`color/warningSoft`（有定义无解析值）、`color/white`、`color/ink`。

---

## 3. 字体系统

| 角色 | 字体 | 依据 |
|---|---|---|
| 标题 / 数字 | **Poppins SemiBold (600)** | Display、H1/H2、Number 及各屏大标题 |
| 正文 / UI 标签 | **Open Sans**（Regular 400 / SemiBold 600） | 按钮、chip、菜单项、列表、导航、正文 |
| 样式页标本（矛盾项） | Noto Sans SC | 仅存在于隐藏的字体标本画板，实际组件未使用 |

| Token | 字号 | 行高 | 字重 | 说明 |
|---|---|---|---|---|
| `Display/32` | 32 | 1.2 (38) | 700 | 营销级大数 |
| `H1/24` | 24 | 1.25 (30) | 600/700 | 页面标题 |
| `H2/20` | 20 | 1.3 (26) | 600 | hero 卡标题 |
| `H3/16` | 16 | 1.35 (22) | 700 | 分组标题、卡片标题 |
| `Body/14` | 14 | 1.5 (21) | 400 | 正文、列表主文 |
| `BodyStrong/14` | 14 | 1.5 (21) | 500 | 强调正文 |
| `Label/13` | 13 | 1.4 (18) | 500 | 头像缩写、小标签 |
| `Caption/12` | 12 | 1.45 (17) | 400 | 副标题、时间、辅助信息 |
| `CaptionStrong/12` | 12 | 1.45 (17) | 600 | chip 文案 |
| `Number/26` | 26 | 1.2 (31) | 600 Poppins | 指标数字（1,284 / $184K） |

**待修的一致性缺陷**
1. 字体族三套并存：样式页写 Noto Sans SC，组件实为 Open Sans + Poppins。中文界面下 Open Sans / Poppins 均无 CJK 字形，中文会回退到系统字体，行高与字重观感与设计稿不一致 —— 落 Flutter 时建议统一为 `Noto Sans SC`（或 `PingFang SC`/`HarmonyOS Sans`）作正文，保留 Poppins 只用于纯数字。
2. H1/H2 在样式页是 Bold(700)，在组件里是 SemiBold(600)，需二选一。
3. 按钮文字用 Open Sans SemiBold 14 —— 与 CaptionStrong/chip 同族但字重语义不同，需在 token 层收敛成 `Label/Button`。

---

## 4. 间距 / 圆角 / 层级

**间距**（4pt 基准）：`space/1`=4、`space/2`=8、`space/3`=12、`space/5`=20 已验证；4/6/8/12 档位存在但未在这些节点绑定，按 16/24/32/48 延续。

**圆角**：`sm`=8（菜单项）、`md`=12（按钮、输入框、列表卡）、`lg`=16（统计卡、弹窗菜单）、`xl`=24（对话框/底部弹层）、`full`=999（pill、头像、FAB、图标按钮）。

**阴影**（仅浅色模式有效，暗色模式改用 1px 描边表达层次）

| Token | 值 |
|---|---|
| `Shadow/Card` | `0 4 12 rgba(15,23,41,0.06)` |
| `Shadow/Menu` | `0 10 28 rgba(15,23,41,0.18)` |
| `Shadow/Dialog` | `0 18 48 rgba(15,23,41,0.24)` |

统一卡片公式：`bg card + 1px border + radius md/lg + Shadow/Card`，无边框纯阴影的卡片不存在。

---

## 5. 组件库（21 个）

| 组件 | 关键规格 |
|---|---|
| `Button/Primary` | min-h 48，px 20 / py 12，r 12，bg primary，label 14/600 onPrimary |
| `Button/Secondary` | 同上，bg card + 1px border，label fg |
| `Button/Danger` | 同上，bg destructive，label onPrimary |
| `IconButton/Ghost` | 48 × 48，r full，图标 24，无底色（含 bell 变体 + 16px 未读红点） |
| `StatusChip/Active·Pending·New` | h 25（py 4 / px 8），r full，gap 4，bg muted，6px 圆点 + 12/600 文字（accentText / warningText / primaryText） |
| `Avatar/40` | 40 圆，bg primarySoft，缩写 13/600 primaryText |
| `MenuItem` | px 12 / py 8，r 8，gap 12，图标 20，label 14/400 fg |
| `TextField` | 宽 328，纵向 gap 8（label + 输入框 48 高） |
| `SearchField` | 364 × 48，r 12，bg card + border，内距 12，gap 8，图标 20 |
| `SectionHeader` | 364 × 24，两端对齐（H3 左 + Caption「See all」右，primaryText） |
| `StatCard` | 176 × 142，r 16，p 16，gap 12：40 图标底 + 涨跌 Caption + Number/26 + Caption 标签 |
| `CustomerRow` | 364 × 64，r 12，p 12，gap 12：Avatar 40 + 两行文字 + chevron 20 |
| `BottomNav` | 412 × 72，bg card + 顶边 1px，4 项；激活项为主色 soft pill + primaryText |
| `MoreMenu` | 220 宽，r 16，p 8，项间距 2，Shadow/Menu |

**图标**：线性描边、24px 网格（小尺寸 20）、统一线宽，主色/次级色两态，无填充图标。

---

## 6. 页面与状态（22 屏）

主流程：Dashboard、Customers、Customer detail、Deals、Settings、Notifications、Deal detail。
状态变体：More menu（行内操作）、Add customer（表单弹层）、Add customer · Validation（错误态）、Delete customer · Confirm（危险确认）、Customers · Filter sheet（底部筛选）、No results、Empty state、Delete success（toast）、Pull to refresh、Loading（骨架屏）、Offline。
暗色镜像：Dashboard / Customers / Deals / Settings 4 屏。

---

## 7. 复用模式（设计语言）

1. **Hero 卡反转**：浅色模式 hero 卡是 primary 实底 + 白字；暗色模式反转为 `#60a5fa` 浅蓝底 + `#0b1220` 深字。双主题不是简单换色，而是「强调块反转」。
2. **三段式页面结构**：标题区（H1 + Caption + 右侧两个图标按钮）→ 主内容（卡片组）→ 底部导航；页面内不出现分隔线，靠 12px 间隙分块。
3. **分组头双端对齐**：左 H3、右 Caption 主色链接，是全站唯一允许的「标题+跳转」组合。
4. **列表行统一 64 高**，内部 40 头像 + 两行（14/500 主文 + 12/400 次文）+ 右侧 12 时间或 chevron。
5. **状态即颜色**：Qualified/Active = accent、Proposal/New = primary、Negotiation/Pending = warning，chip 底色一律 `muted`，靠圆点与文字色区分 —— 不使用浅色 semantic 底（避免暗色模式二次适配）。
6. **弹层**：对话框 r 24 + Shadow/Dialog + scrim；底部筛选 sheet 顶角 r 24。
7. **加载用骨架屏**而非 spinner；离线态用顶部细条提示。

---

## 8. 落 Flutter 的建议映射

| Figma token | Flutter |
|---|---|
| `color/*` | `ColorScheme` + `ThemeExtension<AppColors>`（双模用 light/dark 两套 `ThemeData`） |
| `radius/*` | 常量类 `AppRadius`（12/16/24），`BorderRadius.circular` |
| `space/*` | `AppGap` 常量，禁止裸数字 |
| `Shadow/*` | `BoxShadow` 常量（暗色模式置空，改由 `BorderSide` 承担） |
| 字体层级 | `TextTheme` + `AppTextStyles`（Poppins 数字单列一个 style） |
| 组件 | `StatCard` / `CustomerRow` / `StatusChip` / `SectionHeader` / `AppButton` / `AppTextField` |

---

## 9. 实现状态（Flutter 还原）

工程：`E:/program/flutter/abc`（Flutter 3.47.3 / Dart 3.13.3，依赖 `flutter_svg`，字体 Poppins + Open Sans 已本地打包）。

| 目录 | 内容 |
|---|---|
| `lib/design/tokens.dart` | 双模色板、字体层级（行高按 Figma 文本盒整数对齐 + `even` 行距分配）、圆角/间距/阴影、画布尺寸 |
| `lib/design/dsl.dart` | `DsFrame`（412×892 画布 + 等比缩放）、`DsBox` / `DsText` / `DsSlot` |
| `lib/components/icons.dart` | `DsGlyph` —— 单色字形 + `srcIn` 着色；`DsGlyph.raw` 用于双色资源 |
| `lib/components/chrome.dart` | StatusBar、BottomNav、IconButton、Bell（角标用原生绘制）、BottomAction、FAB |
| `lib/components/cards.dart` | Avatar、CustomerRow、SectionHeader、StatCard、FollowUpCard、StatusChip |
| `lib/components/detail.dart` | QuickActionTile、MiniStat、PipelineCard/Stage、NoteCard、DealsSummary、DealCard |
| `lib/components/inputs.dart` | SearchField、FilterChip（圆角 16）、TextField、Button |
| `lib/screens/` | Dashboard、Customers、Customer detail、Deals + 三个深色版 |
| `lib/app.dart` | 帧浏览器（侧栏列出 22 个 frame，未还原的显式标为 pending） |
| `test/` | 文案断言 + 7 张 412×892 golden |

### 已按设计稿修正的实现细节

1. **描边改为前景绘制**：Figma 的 1px stroke 不参与布局，Flutter 的 `Border` 会挤压内容，已统一改为 `foregroundDecoration`。
2. **行高按 Figma 文本盒取整**：Caption 17/12、H3 22/16、Number 31/26。
3. **行距分配方式**：Flutter 默认 `TextLeadingDistribution.proportional`，比 Figma 的居中对齐整体高 1px；全部字号改为 `even` 后，姓名/标题/正文的墨迹范围与导出一致（这是此前所有文字"差 1px"的根因）。
4. **Poppins 只有 SemiBold**：全文件无 `Poppins:Bold` 节点，`DsType.h3` 曾误设 w700，导致标题偏宽；已改为 w600。
5. **图标改为「单色字形 + 运行时着色」**：Figma 把颜色烘焙进每份导出的 SVG，而颜色取决于节点的**状态**（选中/未选中/强调），不是主题——`dark/home.svg` 实际是「深色主题下未选中」的颜色。因此 `assets/icons/` 只保留一份单色字形（颜色统一改写为 `currentColor`），由 `DsGlyph` 用 `srcIn` 过滤器按 token 上色，深浅主题、任何状态共用一份资源。
6. **未读角标改为原生绘制**：它是双色资源（红底 + 页面底色描边环），用 Flutter 圆形容器 + `colors.destructive` / `colors.bg` 环即可在两个主题下都正确。
7. **筛选芯片圆角 16**（非胶囊 17），交易阶段芯片圆点内缩 9（`Active` 芯片为 8）。
8. **底栏 `BottomAction` 是四边描边**（左右两条落在画布边缘，只看得见上下）。
9. **golden 默认关掉阴影**：`flutter_test` 会把每个 `BoxShadow` 画成硬边矩形（`debugDisableShadows = true`），必须在捕获前置为 `false`、并在测试体结束前复原（`debugAssertAllPaintingVarsUnset` 在 body 之后执行，放 `tearDown` 里会报错）。修正后 Snackbar 的 `Shadow/Menu` 与导出逐像素吻合（差 ≤3/255）。

### 像素级验收方法

`.workbuddy/diff_png.py` 把 golden 与 `.workbuddy/figma_out/<node>.png` 逐像素比较，输出超容差像素比例、差异包围盒与差异最多的行。golden 统一以 **412×892 @1x** 捕获（`test/golden_test.dart` 设置 `tester.view.physicalSize`），与 Figma 导出尺寸完全一致，可直接比对。

当前 9 张的残差（容差阈值 / 差异像素占比）：

| 画板 | tol12 | tol48 | tol80 |
|---|---|---|---|
| Customer detail 7:120 | 2.62% | 1.03% | **0.40%** |
| Customers · Loading 10:652 | 2.48% | 0.75% | **0.51%** |
| Dashboard · Dark 64:672 | 3.82% | 1.91% | 1.06% |
| Deals · Dark 64:789 | 4.12% | 2.06% | 1.06% |
| Dashboard 5:2 | 3.80% | 1.89% | 1.11% |
| Deals 7:307 | 4.17% | 2.15% | 1.24% |
| Customers · Delete success 9:583 | 3.47% | 1.94% | 1.30% |
| Customers · Dark 64:738 | 4.27% | 2.59% | 1.69% |
| Customers 5:100 | 4.20% | 2.53% | 1.83% |

残差经掩膜确认全部落在**字形边缘**（Figma 与 Skia 的栅格化/hinting 差异）与 1px 圆角抗锯齿上，没有任何位置或配色错误；`Customer detail` 文字最少，因此最低。

### 已完成 / 未完成

已完成 9 帧：Dashboard(5:2)、Customers(5:100)、Customers · Dark(64:738)、Customer detail(7:120)、Dashboard · Dark(64:672)、Deals(7:307)、Deals · Dark(64:789)、Customers · Loading(10:652)、Customers · Delete success(9:583)。

未完成 13 帧：More menu(7:422)、Add customer Dialog(7:531)、Delete confirm(7:601)、Filter sheet(7:659)、No results(9:354)、Empty state(9:470)、Validation(9:695)、Settings(9:831)、Pull to refresh(10:542)、Deal detail(11:620)、Notifications(11:703)、Offline(16:649)、Settings · Dark(64:875)。

**其中多数被图标资源卡住**：Settings / Notifications / Deal detail / More menu / Offline 等用到了 `user`、`shield`、`moon`、`globe`、`wifi-off`、`log-out` 等字形，它们的资产哈希只能从 `get_design_context` 拿到。当前 `assets/icons/` 里只有 Dashboard / Customers / Customer detail / Deals 用到的 19 个字形。

这些帧的 `get_design_context` 没能抓到（Figma Dev Mode MCP 当日配额耗尽，`ctx2/` 里 105 份只有 87 份是有效载荷），目前只有几何（`.workbuddy/meta_now.txt`，22 帧全量）与整屏 PNG（`.workbuddy/figma_out/*.png`）。继续推进的方式：用 `.workbuddy/meta_tree.py <node>` 拿逐节点坐标，用 `.workbuddy/probe_at.py` 从导出 PNG 采样颜色/量测尺寸（Deals 即以此法完成），再用 `diff_png.py` 验收；配额恢复后可用 `.workbuddy/crawl2.py` 补抓样式（会跳过已有节点）。
