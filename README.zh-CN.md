# EPLAN API skills

[English](README.md) | [简体中文](README.zh-CN.md)

用于构建 EPLAN Platform P8 加载项的 Agent Skill。

## 安装

### Claude Code 插件

```text
/plugin marketplace add bingyongcao/eplan-api-skills
/plugin install eplan-api@eplan-api-skills
```

### Codex 或通用 Skill

在已克隆仓库的 PowerShell 终端中运行：

```powershell
.\tools\install.ps1 -Target Codex -Scope User
```

同时为两个本地 Agent 安装：

```powershell
.\tools\install.ps1 -Target Both -Scope User
```

安装程序会将规范 Skill 目录复制到 `$HOME/.agents/skills/eplan-api`（Codex）和
`$HOME/.claude/skills/eplan-api`（Claude Code）。如需在仓库范围内安装，请使用
`-Scope Project -ProjectRoot <path>`。

## 更新

### Claude Code 插件

刷新 Marketplace、更新插件，然后重新加载：

```text
/plugin marketplace update eplan-api-skills
/plugin update eplan-api@eplan-api-skills
/reload-plugins
```

### Codex 或通用 Skill

拉取最新更改，然后使用安装时相同的目标和作用域重新运行安装程序：

```powershell
git pull --ff-only
.\tools\install.ps1 -Target Both -Scope User
```

重启 Agent 或开始新会话，使其重新加载更新后的 Skill。
