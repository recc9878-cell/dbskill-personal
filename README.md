# dbskill（个人版）

靳扬自用的 dbs 家族打包：`/dbs` 编排入口 + 42 个 Skill，本机在用的原样镜像。

体系源自 dontbesilent 的 dbskill（[dontbesilent2025/dbskill](https://github.com/dontbesilent2025/dbskill)，CC BY-NC 4.0，转载注明出处），在此基础上并入个人扩展（dbs-viewpoint / dbs-hook-pro / dbs-wechat-plus / dbs-density / dbs-bridge / dbs-gpts-sync / dbs-skill-cleaner / dbs-slowisfast）。

## 安装

与本家相同的指令，换成自己的仓库即可：

```bash
npx -y skills add recc9878-cell/dbskill-personal -g --all
```

公开仓库，无需登录 GitHub，能访问 GitHub 即可安装。

## 仓库内容

`skills/` 下 43 个 Skill，与安装清单一致。分工详见各 Skill 的 SKILL.md，或安装后输入 `/dbs` 由编排入口自动匹配。

不收录三个已下线的 skill（dbs-hook、dbs-xhs-title、dbs-agent-migration），其能力由 dbs-title-cover-intro / dbs-content-value 承接；本机备份在 `~/.dbs/retired-skills/`。

## 同步（本机为真源）

本机 `~/.agents/skills/` 是唯一真源，仓库跟随它更新：

```bash
~/dbskill-personal/sync.sh "备注"
```

脚本做三件事：把 `~/.agents/skills/` 下所有 `dbs*` 镜像进 `skills/`（自动剔除下线名单，新装或自建的 skill 自动纳入）→ 提交 → 推送。无变化时不动。
