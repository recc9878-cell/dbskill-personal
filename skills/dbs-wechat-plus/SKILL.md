---
name: dbs-wechat-plus
description: 微信公众号个人风格排版，支持默认黑白灰与蒙德里安两种风格。用户要求「蒙德里安风格」「彩色版公众号」「用我的两套个人风格排版」时使用。其余风格走 dbs-wechat-html。
---

# dbs-wechat-plus：公众号个人风格排版（内测）

**性质**：dontbesilent 内测 skill（原 v1.1，2026-02-16），2026-08-04 由用户并入 dbs 家族。更新源外的内测版，`/dbs-update` 不会覆盖它。

## 与 dbs-wechat-html 的分工（重要）

| | dbs-wechat-html | dbs-wechat-plus（本 skill） |
|---|---|---|
| 风格 | 15 种内置风格（minimal、WIRED、Stripe…） | **2 种个人风格：默认黑白灰、蒙德里安** |
| 独有价值 | 风格全、预览总览页 | 蒙德里安（dbs-wechat-html 的 15 种里没有）＋句号去除等个人排版规则 |
| 什么时候用 | 「做公众号版」「排版」不指定风格时 | 「蒙德里安」「彩色版」或明确要这两种风格时 |

dbs-wechat-html 的 15 种风格里没有蒙德里安——这是本 skill 存在的理由。

---

## 触发条件

- 「生成微信公众号 HTML（蒙德里安／默认风格）」
- 「做一个公众号版本（彩色版）」
- `/公众号HTML`

## 风格参数

| 参数 | 说明 | 触发词 |
|------|------|--------|
| **默认风格** | 黑白灰，干净简洁 | 不指定风格时自动使用 |
| **蒙德里安风格** | 红蓝黄黑白，几何感强 | 「蒙德里安」「蒙德里安配色」「彩色版」 |

---

## 微信粘贴兼容性（2026-08-04 并入时新增，关键修正）

浏览器预览正确 ≠ 粘贴到公众号后台正确。`Cmd+A`、`Cmd+C` 复制时不携带 `<head><style>`，公众号后台还会再次清洗 HTML。因此：

- **每个可见元素（`<p>`、`<h1>`–`<h3>`、`<blockquote>`、`<ul>`、`<li>`、`<hr>`、`<strong>`）必须把完整样式写在自身的 `style` 属性里**，不得依赖 `<style>` 标签或继承。
- `<body>` 只保留本地预览需要的宽度与页边距，正文样式不得依赖 `<body>` 继承。
- 禁止 `<style>` 标签、class/id 选择器、伪元素、外部资源。

原内测版的 `<style>` 模板仅作样式值参考，生成时一律展开为内联样式。

---

## 核心规范

### 字号（微信后台会放大 pt 值，必须用小 px）

- **正文**：16px｜**h1**：24px｜**h2**：20px（默认）／19px（蒙德里安）｜**h3**：18px（默认）／17px（蒙德里安）
- 引用文字：16px，与正文相同

### 间距

- 标题上方：h1 32px／h2 36px（默认）、40px（蒙德里安）／h3 28px
- 标题下方：h1 16px／h2 12px（默认）、14px（蒙德里安）／h3 10px
- 段落上下 10px（默认）／12px（蒙德里安）；行高 1.75（默认）／1.85（蒙德里安）

### 字体

```css
font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "PingFang SC", "Hiragino Sans GB", "Microsoft YaHei", sans-serif;
```

### 颜色

**默认风格**：正文 #333；h1 #000，h2/h3 #333；引用 #666 + 左边框 3px #ddd；分隔线 1px #eee。

**蒙德里安风格**：正文 #222；h1 #111（font-weight: 900，letter-spacing: 3px）；h2 #111 + 左侧 5px 红色竖线 #d40920；h3 蒙德里安蓝 #0057b8；加粗 #111（font-weight: 800）；引用 #444 + #111 左边框 + 淡黄底 #fdf8e8；分隔线 3px #111。设计原则：红色克制（仅 h2 竖线）、蓝色给 h3、黄色给引用底、黑线粗重。

---

## 工作流程

1. **读取 Markdown 源文件**（用户给的路径或直接贴的内容）。
2. **按选定风格生成 HTML**——使用下方内联样式模板。
3. **转换 Markdown**，规则：
   - `#`→`<h1>`、`##`→`<h2>`、`###`→`<h3>`；`>`→`<blockquote>`；`-`→`<ul><li>`（连续项共用一个 `<ul>`）；`**`→`<strong>`；`---`→`<hr>`
   - **每段末尾的句号（。）必须去掉**，不管原文有没有
   - Markdown 硬换行不转 `<br>` 也不输出可见 `&lt;br&gt;`；连续短句优先改成列表，普通换行合并成段
   - **中文排版间距（严格执行）**：中英文之间加一个空格（`Claude Code` 前后各一）；中文与数字之间加一个空格（`30%` 前后各一）；只能一个空格不能连续两个；`%` 视为数字的一部分
4. **保存**：原文件名 + `_微信公众号版.html`，与源文件同目录。
5. **浏览器打开**（`open [路径]`），并告知用户：全选（Cmd+A）→ 复制（Cmd+C）→ 粘贴到公众号后台 → 检查格式。

---

## 内联样式模板

### 模板 A：默认风格（每个元素自带 style，可直接整段复制粘贴）

```html
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>微信公众号版</title>
</head>
<body style="max-width: 750px; margin: 0 auto; padding: 20px;">
<h1 style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei', sans-serif; font-size: 24px; font-weight: bold; text-align: center; margin: 32px 0 16px 0; color: #000;">文章标题</h1>
<h2 style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei', sans-serif; font-size: 20px; font-weight: bold; margin: 36px 0 12px 0; color: #333;">第一章</h2>
<h3 style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei', sans-serif; font-size: 18px; font-weight: bold; margin: 28px 0 10px 0; color: #333;">小节</h3>
<p style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei', sans-serif; font-size: 16px; line-height: 1.75; color: #333; margin: 10px 0;">正文段落</p>
<blockquote style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei', sans-serif; font-size: 16px; line-height: 1.75; color: #666; font-style: italic; margin: 12px 0; padding-left: 20px; border-left: 3px solid #ddd;">引用内容</blockquote>
<ul style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei', sans-serif; font-size: 16px; margin: 10px 0; padding-left: 20px;">
<li style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei', sans-serif; font-size: 16px; line-height: 1.75; color: #333; margin: 4px 0;">列表项</li>
</ul>
<p style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei', sans-serif; font-size: 16px; line-height: 1.75; color: #333; margin: 10px 0;"><strong style="font-weight: bold; color: #333;">重点</strong>在这里</p>
<hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;">
</body>
</html>
```

### 模板 B：蒙德里安风格

```html
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>微信公众号版·蒙德里安</title>
</head>
<body style="max-width: 750px; margin: 0 auto; padding: 20px; background: #fff;">
<h1 style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei', sans-serif; font-size: 24px; font-weight: 900; text-align: center; margin: 40px 0 20px 0; color: #111; letter-spacing: 3px;">文章标题</h1>
<h2 style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei', sans-serif; font-size: 19px; font-weight: 800; margin: 40px 0 14px 0; color: #111; padding-left: 14px; border-left: 5px solid #d40920;">第一章</h2>
<h3 style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei', sans-serif; font-size: 17px; font-weight: 700; margin: 28px 0 10px 0; color: #0057b8;">小节</h3>
<p style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei', sans-serif; font-size: 16px; line-height: 1.85; color: #222; margin: 12px 0;">正文段落</p>
<blockquote style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei', sans-serif; font-size: 16px; line-height: 1.85; color: #444; font-style: italic; margin: 16px 0; padding: 12px 20px; border-left: 4px solid #111; background: #fdf8e8;">引用内容</blockquote>
<ul style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei', sans-serif; font-size: 16px; margin: 10px 0; padding-left: 20px;">
<li style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei', sans-serif; font-size: 16px; line-height: 1.85; color: #333; margin: 5px 0;">列表项</li>
</ul>
<p style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei', sans-serif; font-size: 16px; line-height: 1.85; color: #222; margin: 12px 0;"><strong style="font-weight: 800; color: #111;">重点</strong>在这里</p>
<hr style="border: none; height: 3px; background: #111; margin: 28px 0;">
</body>
</html>
```

---

## 注意事项

### ⚠️ 常见错误

1. **字号用 pt**——微信后台放大 pt 值，必须用 px。
2. **样式只写在 `<style>` 里**——复制粘贴时全部丢失，必须内联。
3. **标题间距不足**——h2 上方至少 36px。
4. **每个 `<li>` 单独包一个 `<ul>`**——列表显示断裂，多个 `<li>` 共用一个 `<ul>`。

### 💡 优化建议

1. **表格**：公众号对表格支持差，转成 `•` 列表。
2. **图片**：HTML 不含图片，用 `[图片：描述]` 标记位置，后台手动上传。
3. **外链**：公众号限制外链，文末统一列出或用「阅读原文」。
4. **预览**：粘贴后手机端和电脑端都检查一遍。

---

## 更新日志

- **v1.0（2026-02-06）**：原版创建，字号/间距规范、`<style>` 模板、转换规则
- **v1.1（2026-02-16）**：新增蒙德里安风格，模板拆分 A/B
- **2026-08-04 并入**：改名 dbs-wechat-plus；按微信粘贴兼容性把两个模板从 `<style>` 标签改为内联样式（原 `<style>` 方案复制粘贴会丢全部样式）；新增与 dbs-wechat-html 的分工表
