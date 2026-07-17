# 🛠️ macOS config and applications as code

批量改系统设置、装软件。对外就三个命令：

| 命令 | 做什么 |
|------|--------|
| `sh init.sh`（或 `bash init.sh`） | 装机：分步多选 → 系统设置 → 软件 → Dock |
| `sh backup.sh` | 备份个人数据（自动生成快照目录） |
| `sh doctor.sh` | 检查环境（可选） |

装机脚本可上 GitHub；`backup.sh` 生成的快照含密钥，只放本机或外置盘，恢复用快照里的 `restore.sh`。

## ⚠️ 注意

- 受 GFW 影响，跑脚本前先解决网络。
- 部分安装需要 `sudo`；可先 `sudo -v` 刷新时间戳。

## 🚀 装机：`init.sh`

```shell
sh init.sh
# 或
bash init.sh
```

开始时**分步**多选（默认全选，可看说明后逐项取消）：

1. 系统设置（展开为具体 defaults 项）
2. Dock（展开为具体 Dock 项）
3. Homebrew 软件（formula / cask）
4. 插件（Oh My Zsh 等）
5. App Store 应用（若有）

操作：`↑↓` 移动，`空格` 选中/取消，`a` 全选，`n` 全不选，`Enter` 确认进入下一步，`q` 退出。确认后开始装机，中途不再问选项。

主线三块：系统设置 → 软件安装（Brewfile，含 mas）→ Dock。若勾选了 App Store 应用，会在装机前打开 App Store 并等待登录确认。

```shell
sh init.sh --yes             # 跳过多选，默认全选
sh init.sh --from brew       # 从软件安装阶段续跑
sh init.sh --skip-doctor     # 跳过首尾 doctor
sh doctor.sh                 # 单独排查
```

软件按计划 **逐个**下载安装；失败单项会记录并继续。结束打印汇总，并写入 `~/Library/Logs/mac-as-code/init-*.tsv`。

Git 用户名/邮箱不在装机里配置，随 `~/.gitconfig` 走备份 / 恢复。

## 💾 备份 / 恢复（独立管线）

```shell
# 重置前备份 → 自动生成目录，拷到外置盘
sh backup.sh

# 新机：先 sh init.sh 装好应用，再进入该次快照目录恢复
cd ~/Desktop/backup/reset-kit/<时间戳>-<机器名>
sh restore.sh
```

快照含：SSH、**`.gitconfig`（含 Git 用户信息）**、`.zshrc`、iTerm2、CleanShot、Keyboard Maestro、Rime/Squirrel、TextFlash，以及 Brave **插件本地配置**（Sync 不同步的那部分：`Local Extension Settings` + 扩展 IndexedDB）。书签/扩展列表仍靠 Brave Sync。

`TEXTFLASH_APP_PATH` 可指定非默认 TextFlash 路径。恢复前会保留现有文件为 `.before-restore-*`。

## 📝 其他

配置按个人习惯编写，可按需改。`Brewfile` 可用 `brew bundle dump` 更新。CI 只做 `bash -n` 语法检查。
