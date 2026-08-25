# EPLAN API skills

[English](README.md) | [简体中文](README.zh-CN.md)

An agent skill for building EPLAN Platform P8 add-ins.

## Install

### Claude Code plugin

```text
/plugin marketplace add bingyongcao/eplan-api-skills
/plugin install eplan-api@eplan-api-skills
```

### Codex or plain-skill

From a PowerShell prompt in the cloned repository:

```powershell
.\tools\install.ps1 -Target Codex -Scope User
```

Install for both local agents:

```powershell
.\tools\install.ps1 -Target Both -Scope User
```

The installer copies the canonical folder to `$HOME/.agents/skills/eplan-api` for Codex and
`$HOME/.claude/skills/eplan-api` for Claude Code. For repository-scoped installation, use
`-Scope Project -ProjectRoot <path>`.

## Update

### Claude Code plugin

Refresh the marketplace, update the plugin, and reload it:

```text
/plugin marketplace update eplan-api-skills
/plugin update eplan-api@eplan-api-skills
/reload-plugins
```

### Codex or plain-skill

Pull the latest changes, then run the installer again with the same target and scope used
during installation:

```powershell
git pull --ff-only
.\tools\install.ps1 -Target Both -Scope User
```

Restart the agent, or start a new session, so it reloads the updated skill.

## Uninstall

### Claude Code plugin

```text
/plugin uninstall eplan-api@eplan-api-skills
```

To also remove the marketplace entry:

```text
/plugin marketplace remove eplan-api-skills
```

### Codex or plain-skill

From a PowerShell prompt in the cloned repository, uninstall the user-scoped Codex skill:

```powershell
.\tools\uninstall.ps1 -Target Codex -Scope User
```

Uninstall from both local agents:

```powershell
.\tools\uninstall.ps1 -Target Both -Scope User
```

For a repository-scoped installation, use `-Scope Project -ProjectRoot <path>`. Restart the agent,
or start a new session, to finish unloading the skill.
