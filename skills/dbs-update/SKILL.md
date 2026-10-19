---
name: dbs-update
description: 更新个人版 dbskill（recc9878-cell/dbskill-personal），更新前自动留档旧版本，并把本机改动推送回仓库。用户要求更新、升级、检查 dbskill 版本，或在更新提醒后回复 1 时使用。
---

# dbs-update：更新 dbskill（个人版）

用户已经明确要求更新 dbskill，或在上一条 dbskill 更新提醒后回复了 `1`。两种情况都直接执行更新，不再做第二次文字确认；宿主若要求 Shell 权限，由用户在宿主的权限窗口中决定。

只有上一条助手回复明确包含 dbskill 更新提醒时，单独回复的 `1` 才代表更新。缺少这段上下文时，不要自行解释数字含义。

## 更新范围

- 只更新个人仓库 `recc9878-cell/dbskill-personal`（公开，本机 dbs 家族的镜像）。
- 本机 `~/.agents/skills/` 是真源：本机的改动和新 skill 由本 Skill 推送回仓库，仓库只跟随本机。
- 保留用户在 `~/.dbs/` 中的存档、报告和决策记录。
- 更新前按「更新前留档」把将被覆盖的旧版本快照到 `~/.dbs/archive/`。
- 不更新用户安装的其他 Skill。
- 不创建后台任务、定时任务或 Agent Hook。

## 更新前留档（旧版本保护）

安装命令是纯覆盖，本地没有 git 历史；未推送的本机改动一旦被覆盖就无法找回。所以每次覆盖前先把旧版本快照到 `~/.dbs/archive/`，给过往版本建一条即取即用的本地通路：

1. 读取 `~/.agents/skills/dbs/references/official-skill-names.txt`（忽略末尾「用户内测扩展」注释块）得到清单，加上 `~/.agents/skills/` 下清单外的 `dbs*` 自有目录。
2. 清单里每个本地已存在的 skill，先把整个目录原样复制到 `~/.dbs/archive/<skill名>/<YYYY-MM-DD-HHMMSS>/`。只复制，不压缩、不改动、不清理旧留档。
3. 已知某个 skill 被手工改过提示词的，在它的留档目录里写一行 `_本地改动.md` 说明改动点和原因。
4. 回溯旧版本：个人版历史看本仓库（`~/dbskill-personal` 的 `git log` / GitHub 提交记录）；官方上游任意旧版本用本机全量 git 克隆 `~/知识库/dbskill`（remote 即官方仓库，含 71 个版本 tag；工作区冻结勿 checkout），读旧版文件用 `git show <tag>:<路径>`。云端兜底：`https://github.com/dontbesilent2025/dbskill/commits/main`。

留档完成之前不执行任何覆盖命令。手工修改任何 dbs skill 文件（比如改某个提示词）之前，同样按本节先快照再动手。

## 执行步骤

1. 按「更新前留档」完成旧版本快照。

2. 先推送，再安装：把本机改动同步回仓库，避免未推送的改动被覆盖安装冲掉。

   ```bash
   ~/dbskill-personal/sync.sh "更新前推送"
   ```

   脚本无变化时自动跳过；本机新装或自建的 `dbs*` skill 会被自动纳入仓库；下线名单（dbs-hook、dbs-xhs-title、dbs-agent-migration）自动剔除。

3. 运行安装命令（与本家同款指令）：

   ```bash
   npx -y skills add recc9878-cell/dbskill-personal -g --all
   ```

4. 命令成功后记录本次更新时间，避免当前对话仍加载旧 Skill 时重复提醒：

   ```bash
   mkdir -p "$HOME/.dbs" && date +%s > "$HOME/.dbs/update_check_at"
   ```

5. 根据命令的退出状态确认是否完成。命令成功时告诉用户更新已完成，并提醒用户新建一次对话后再使用新能力。

6. 命令失败时，用一句话说明失败原因和下一步需要用户处理的权限或网络问题。不要把完整终端日志直接贴给用户，除非用户要求。

## 回复格式

成功：

> dbskill（个人版）已更新完成。当前对话如果还没有读取到新能力，新建一次对话后即可使用。

失败：

> dbskill 没有更新完成：{简短原因}。处理完 {权限或网络问题} 后，再说一次「更新 dbskill」。

## 边界

- 用户只问版本、更新内容或是否需要更新时，先回答问题，不执行命令。
- 用户明确要求检查更新且希望实际同步时，按本 Skill 更新。
- 官方上游 dontbesilent2025/dbskill 已切断：不做任何同步，其仓库仅作旧版历史回溯用途。
- 不使用 `npx skills update`，该命令可能更新用户安装的其他 Skill。

---

完成当前任务后直接结束。只有用户明确询问下一步，且当前环境已经安装 `/dbs` 时，简短提示：「下一步不确定时，可以输入 `/dbs`。」
