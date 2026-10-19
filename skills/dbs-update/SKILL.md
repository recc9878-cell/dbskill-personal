---
name: dbs-update
description: 更新官方 dbskill，更新前自动留档旧版本，并保留其他 Skill 与用户存档。用户要求更新、升级、检查 dbskill 版本，或在更新提醒后回复 1 时使用。
---

# dbs-update：更新 dbskill

用户已经明确要求更新 dbskill，或在上一条 dbskill 更新提醒后回复了 `1`。两种情况都直接执行更新，不再做第二次文字确认；宿主若要求 Shell 权限，由用户在宿主的权限窗口中决定。

只有上一条助手回复明确包含 dbskill 更新提醒时，单独回复的 `1` 才代表更新。缺少这段上下文时，不要自行解释数字含义。

## 更新范围

- 只更新官方仓库 `dontbesilent2025/dbskill`。
- 保留用户在 `~/.dbs/` 中的存档、报告和决策记录。
- 更新前按「更新前留档」把将被覆盖的旧版本快照到 `~/.dbs/archive/`。
- 不更新用户安装的其他 Skill。
- 清理已下线的官方旧入口时，只处理能确认来自官方的副本；用户改过的或同名的自有 Skill 一律保留。
- 不创建后台任务、定时任务或 Agent Hook。

## 更新前留档（旧版本保护）

官方仓库 `dontbesilent2025/dbskill` 自带完整提交历史，任何旧版本都能从 GitHub 回溯；但更新命令是纯覆盖，本地没有 git 历史。所以每次覆盖前先把旧版本快照到 `~/.dbs/archive/`，给过往版本建一条即取即用的本地通路：

1. 读取 `~/.agents/skills/dbs/references/official-skill-names.txt`（忽略末尾「用户内测扩展」注释块）得到官方 skill 清单。
2. 清单里每个本地已存在的 skill，先把整个目录原样复制到 `~/.dbs/archive/<skill名>/<YYYY-MM-DD-HHMMSS>/`。只复制，不压缩、不改动、不清理旧留档。
3. 已知某个 skill 被手工改过提示词的，在它的留档目录里写一行 `_本地改动.md` 说明改动点和原因：这份内容 GitHub 历史上没有，本地快照是唯一副本。（`dbs-update` 自身的 SKILL.md 含本节手改内容，每次更新都会被官方版冲掉，留档时必须标注。）
4. 回溯官方任意旧版本：优先用本机全量 git 克隆 `~/知识库/dbskill`（remote 即官方仓库，2026-10-05 已补全历史至 2026-03-20 出生提交、71 个版本 tag v2.8.0~v2.18.45；工作区冻结在 v2.17.12 作历史标本，勿 checkout 改动它）。读旧版文件用 `git show <tag>:<路径>`，不改工作区。云端兜底：提交记录 `https://github.com/dontbesilent2025/dbskill/commits/main`；单文件历史用 API `https://api.github.com/repos/dontbesilent2025/dbskill/commits?path=<文件路径>`。

留档完成之前不执行任何覆盖命令。手工修改任何 dbs skill 文件（比如改某个提示词）之前，同样按本节先快照再动手。

## 执行步骤

1. 按「更新前留档」完成旧版本快照。

2. 判断 dbskill 的安装渠道。两种渠道可能同时存在，只更新实际检测到的渠道：

   - **Claude Code 插件**：本 Skill 所在路径包含 `/.claude/plugins/`，或 `claude plugin list` 的输出中有以 `@dontbesilent-skills` 结尾的插件。
   - **Skills CLI**：`~/.agents/skills/`、`~/.claude/skills/` 或其他 Agent 的 Skill 目录中存在 `dbs` 等官方 Skill，且它们不在 `/.claude/plugins/` 下。

3. 更新 Claude Code 插件渠道：先刷新 marketplace，再逐个更新 `claude plugin list` 中以 `@dontbesilent-skills` 结尾的插件。

   ```bash
   claude plugin marketplace update dontbesilent-skills
   claude plugin update dbs@dontbesilent-skills
   ```

   用户单独安装过其他插件（例如 `dbs-diagnosis@dontbesilent-skills`）时，对每个插件分别执行 `claude plugin update`。不要为插件用户再执行 Skills CLI 安装，否则会多出一套副本。

4. 更新 Skills CLI 渠道：

   ```bash
   npx -y skills add dontbesilent2025/dbskill -g --all
   ```

   两种渠道都检测不到时，按这个命令更新。

5. 清理已下线的官方旧入口。名单与官方历史版本指纹在本 Skill 的 [references/retired-skills.json](references/retired-skills.json)：

   - **Claude Code 插件渠道**：`claude plugin list` 中以 `@dontbesilent-skills` 结尾、且名称在名单里的插件，逐个执行 `claude plugin uninstall <名称>@dontbesilent-skills`。
   - **本地 Skill 目录**：解析本 Skill 所在目录的绝对路径，运行其中的 `scripts/cleanup_retired_skills.py`（macOS 与 Linux 用 `python3`，Windows 用 `python` 或 `py`）。脚本只移除失效链接和指向官方旧版本的链接；与官方旧版本完全一致的目录移到 `~/.dbs/retired-skills/<时间>/` 备份；其余同名项保留并说明原因。
   - 当前环境没有 Python 时跳过脚本，在回复中列出名单里的名称，请用户自行检查各 Agent 的 Skill 目录。

6. 命令成功后记录本次更新时间，避免当前对话仍加载旧 Skill 时重复提醒：

   ```bash
   mkdir -p "$HOME/.dbs" && date +%s > "$HOME/.dbs/update_check_at"
   ```

7. 根据命令的退出状态确认是否完成。命令成功时告诉用户更新已完成：插件渠道提醒用户运行 `/reload-plugins` 或新建对话；Skills CLI 渠道提醒用户新建一次对话后再使用新能力。

8. 命令失败时，用一句话说明失败原因和下一步需要用户处理的权限或网络问题。不要把完整终端日志直接贴给用户，除非用户要求。

## 回复格式

成功：

> dbskill 已更新完成（{更新的渠道}）。当前对话如果还没有读取到新能力，{插件渠道：运行 `/reload-plugins`；其他渠道：新建一次对话}后即可使用。

清理了旧入口时追加一句：

> 已清理下线的旧入口：{名称与位置}。{有备份时：原文件备份在 `{备份目录}`。}{有保留项时：`{路径}` 与官方版本不一致，已保留。}

没有残留时不提清理。

失败：

> dbskill 没有更新完成：{简短原因}。处理完 {权限或网络问题} 后，再说一次「更新 dbskill」。

## 边界

- 用户只问版本、更新内容或是否需要更新时，先回答问题，不执行命令。
- 用户明确要求检查更新且希望实际同步时，按本 Skill 更新。
- 不使用 `npx skills update`，该命令可能更新用户安装的其他 Skill。

---

完成当前任务后直接结束。用户的请求超出本 Skill 的范围、任务完成后用户的材料里出现明确的后续需求，或用户询问下一步时，用一句话说明还需要哪种能力，不点名其他 Skill；当前环境已经安装 `/dbs` 时，补一句「可以输入 `/dbs`，由它匹配对应的 Skill」。
