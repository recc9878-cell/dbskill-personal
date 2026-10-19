---
name: dbs-gpts-sync
description: 把本地 dbs skills 同步成 GPTs 模板（Instructions + knowledge 文件），并可上传到飞书。用户提到 GPTs 模板、dbs-gpts-template、同步 GPTs 版、更新飞书上的工具箱文档、对齐最新版 skills 时使用。
---

# dbs-gpts-sync：GPTs 模板同步

你是 dbs GPTs 模板的维护入口。本地 dbs skills 更新后，把变更同步到 GPTs 模板，保持「不缺不漏 + GPTs 环境适配」，按需上传飞书。

---

## 固定路径

| 东西 | 位置 |
|---|---|
| GPTs 模板 | `/Users/rec/dbs-gpts-template/` |
| Instructions | `dbs-gpts-template/gpts-instructions.md` |
| knowledge 文件 | `dbs-gpts-template/knowledge/`（编号-名称.md） |
| 使用说明 | `dbs-gpts-template/README.md` |
| 本地 skills 源 | `~/.agents/skills/dbs-*`（以 SKILL.md 为准） |
| 飞书 CLI | `/Users/rec/.local/bin/lark-cli`（账号：靳桂高） |

---

## 工作流程

### 第一步：diff 出变更

对每个 knowledge 文件与对应 skill 的 SKILL.md 做行级 diff（python difflib 足够）。产出三张清单：

1. **有更新的已有工具**（+N/-N 行）
2. **本地新增的 skills**（skills 目录里有、模板里没有）
3. **上游架构变化**（如「下一步建议」表格移除、新加「留档」段——这类全局模式要统一处理，不是逐文件特例）

### 第二步：新增 skill 的纳入决策（必须问用户）

对每个新增 skill，按 GPTs 可运行性给用户三档选项，附功能一句话说明：

| 类型 | 判断标准 | 处理 |
|---|---|---|
| 可真实运行 | 纯方法论、纯文本处理 | 建议纳入 |
| 仅方法论 | 重度依赖本地文件系统 | 按 decision/content-system 先例可标注纳入，交用户定 |
| 不可运行 | 基础设施（更新/桥接/迁移/清理/存档） | 默认排除，说明理由 |

历史决定（作缺省参考，用户可改）：knowledge、wechat-html、wechat-plus、video-extract 不纳入；save/restore/report 早已删除；skill-maker 以「Skill 提示词制作器」（26-skill-prompt.md，提示词交付版）形式纳入；book-learning（27）由用户直接提供内容，**没有本地 skill 源**，同步时勿当孤儿删除；RAG 知识库版 2026-09-08 实测放弃（知识库无指令槽，规则无强度），一律回到 GPTs 版。

用户点错选项时重新确认，不要将错就错。

### 第三步：生成 knowledge 文件

以最新 SKILL.md 为底，应用下方「GPTs 适配规则」，**其余内容原样保留，不缺不漏**。

编号规则：**追加式**。新工具接在现有最大编号后（如已有 17 则新增从 18 起），已有文件名不改（保持线上 GPT 配置稳定，05-logic-continuity.md 对应 dbs-script-flow 属于既成映射，勿改）。

### 第四步：重写 gpts-instructions.md

上游把跨工具推荐收归 `/dbs` 主路由后，Instructions = 主路由，必须同步吸收：

- 路由表（行数 = knowledge 文件数，含触发词）
- 任务后导航地图（从 /dbs 主路由 SKILL.md 的模式 B 翻译，`/dbs-xxx` → 中文工具名，删掉指向被排除工具的行）
- 核心公理（各 skill 的哲学根基，goal 新版用「语义做工检测」）
- 工具索引（每个工具 3-5 行摘要 + 文件名）
- 边界能力列表（工具数 = 文件数）
- 内容类工具的路由澄清表

**硬约束：全文 < 24000 字符（GPTs Instructions 上限），用 `len(text)` 实测。**

### 第五步：更新 README.md

文件树、上传表（与磁盘一一对应）、Conversation Starters、版本记录表（日期 + 变更摘要）。

### 第六步：终检（全过才算完成）

用脚本一次性验证，任何一项不过都要修：

1. 路由表行数 = 磁盘 knowledge 文件数 = 工具索引数 = 边界列表工具数
2. knowledge 正文无 `/dbs` 命令引用（frontmatter 和本地路径描述除外）
3. 无 `Agent tool` / `并行调用` / `sonnet` / `model: "` 引用
4. README 上传表与磁盘文件一致
5. 抽查改造点（chatroom 依次扮演、austrian 依次启动、goal 新哲学、公理对齐）

### 第七步：上传飞书（用户要求时）

```bash
# 登录（token 失效时；--domain all 授权全部域）
/Users/rec/.local/bin/lark-cli auth login --domain all --recommend
# 建文档
/Users/rec/.local/bin/lark-cli docs +create --title "标题" --markdown "内容"
```

- 标题前缀「DBS-GPTs」，编号对应：00-README、000-Instructions、01-21 各工具
- **Instructions 和全部 knowledge 文件全文包代码块**（方便收缩 + 一键复制出原始 Markdown）；文件内部已含 ``` 时外围用四反引号 ````；README 不包裹
- 建文件夹 API 在此 CLI 下 404，文档建在「我的文档」根目录，靠前缀检索
- 上传后逐条 `docs +fetch` 验证存活和标题，链接清单交用户

---

## GPTs 适配规则（核心规范）

| 原 SKILL.md 内容 | GPTs 版处理 |
|---|---|
| chatroom 系列的 `Agent tool` 并行调用 | 改为单模型依次扮演各角色，独立成段 |
| `/dbs-xxx` 命令引用（正文） | 改为中文工具名 |
| 结尾「…已安装 `/dbs` 时，简短提示：输入 `/dbs`」 | 改为「用户明确询问下一步时，按主 Instructions 的「任务后导航」选择下一个工具」 |
| 「留档（可选）」段（依赖 /dbs-save） | 整段删除 |
| 正文内「输入 `/dbs`，由主路由…」 | 改为「由主路由…」 |
| 本地知识库引用 | 标注「(本地知识库，GPTs 环境不可用)」或改为对话上下文 |
| 文件系统型工具（decision/learning/content-system） | 文件顶部加 GPTs 限制说明，方法论完整保留 |
| 其他一切内容 | **原样保留，不做改写** |

适配项若出现新的模式（本次没见过的），处理原则：改写到 GPTs 等价物，并在 README 变更说明表登记。

---

## 语言

- 中文遵循《中文文案排版指北》
