# 🛠️ macOS config and applications as code

通过执行脚本批量完成系统设置更改、应用程序安装等。

本仓库分两条独立管线：

| 管线 | 命令 | 是否上 GitHub |
|------|------|----------------|
| 装机（可复现的配置与软件清单） | `bootstrap.sh` / `init.sh` | ✅ 仓库内脚本、`Brewfile`、`defaults_*` |
| 个人数据备份 / 恢复 | `backup.sh` → 快照内 `restore.sh` | ❌ 快照含密钥与私有数据，只放本机或外置盘 |

## ⚙️ 如何改变系统配置

macOS 提供了一个 `defaults` 的命令可以查询和配置各个系统参数，包括但不限于 Dock、触发角、系统偏好等等。

执行命令后瞬间完成配置，不用去 UI 页面 System Settings 依次去找各个要设置的点并修改。

## 📦 如何安装软件

1. 依赖 `brew` 命令安装非 App Store 的软件
2. 依赖 `mas`(通过 brew 安装的命令行应用) 命令安装 App Store 的软件

## ⚠️ 重要

- 受限于 GFW ，部分用户执行这些脚本前先解决好网络问题，否则几乎无法正常执行。
- 有些程序安装需要 `sudo` 权限，需要在对应位置手动输入密码确认权限。或者提前 `sudo -v` 刷新 sudo 时间戳 (有效期内后续脚本不再询问密码)。


## 🚀 装机管线

如果希望初始化时顺便配置 Git 全局用户名和邮箱，先复制个人配置模板并填写：

```shell
cp configs/user.env.example configs/user.env
```

在 `configs/user.env` 中填写：

```shell
GIT_USER_NAME="你的名字"
GIT_USER_EMAIL="你的邮箱"
```

`configs/user.env` 不会被提交到仓库。如果没有创建或没有填完整，初始化脚本会提示并跳过 Git 用户信息配置，不会修改当前机器的 Git 全局配置。

### 新机推荐：`bootstrap.sh`

```shell
bash bootstrap.sh
```

固定顺序：`doctor --pre` → `init` → `doctor --post`。只负责装环境和系统偏好，**不**调用备份快照的恢复。

- 装机前 `--pre`：只查会挡住安装的硬门槛（macOS、CLT、git、Brewfile、可选 `user.env`），不检查尚未安装的 Homebrew / Oh My Zsh
- 装机后 `--post`：验收 brew、mas、Oh My Zsh 是否已就绪

常用参数：

```shell
bash bootstrap.sh --skip-doctor
bash bootstrap.sh --from brew
```

### 只跑初始化：`init.sh`

```shell
bash init.sh
```

依次执行各个项目的安装和配置，下面是按照执行顺序的各个模块的说明。系统设置和 Dock 配置通常很快完成，软件和 Oh My Zsh 安装需要联网下载，时间较长。

1. `defaults_config.sh` 修改 Mac 系统设置，和作者本人的使用习惯相关，包括简单密码、Finder 设置等
2. `git_config.sh` 从 `configs/user.env` 读取 Git 用户信息，并在配置完整时写入全局 Git 配置
3. `brew.sh` 安装 Homebrew，再按 `Brewfile` **逐个**下载并安装 formula / cask；单个失败会记录并继续。随后处理 App Store 应用（见下）
4. `oh_my_zsh.sh` 非交互安装 Oh My Zsh
5. `defaults_dock.sh` 修改 Dock 设置（部分设置依赖上述步骤应用安装完成，所以最后执行）

应用安装清单以 `Brewfile` 为准；`mas.sh` 也可单独补装 App Store 应用，会读取 `Brewfile` 中未被注释的 `mas` 条目，不再维护第二份应用列表。

**软件安装行为：**

- 每个应用会先提示「正在下载」，再提示「正在安装」，不再黑盒批量等到最后才出结果
- 单个应用或单个步骤失败不会中断整条流水线，后续继续执行
- App Store（mas）采用「全有或全无」：安装前打开 App Store，等你登录后按 Enter 再装；若输入 `s` 则**全部跳过**，避免未登录时装一部分、失败一部分
- 全部步骤结束后打印成功 / 失败 / 跳过汇总，并把结果保存到 `~/Library/Logs/mac-as-code/init-*.tsv`

如果初始化结果不理想，可以运行 `bash doctor.sh`（或 `--pre` / `--post`）检查环境，辅助定位问题。它只做检查，不会安装软件或修改系统配置。

仓库的 GitHub Actions 只执行 `bash -n` 语法校验，不会在 CI 中运行会修改 macOS 设置或安装软件的脚本。

`init.sh` 支持断点续跑，跳过已成功执行的前置步骤（一般不必用：失败项已在汇总中列出，且流水线会继续跑完）：

```shell
bash init.sh --from brew    # 跳过 defaults 和 git，从 brew 开始
bash init.sh --from zsh     # 从 Oh My Zsh 开始
```

步骤名：`defaults`、`git`、`brew`、`zsh`、`dock`。

## 💾 备份 / 恢复管线（独立，不上 GitHub）

与装机管线分开：仓库只提供 `backup.sh` 脚本；真正的个人数据快照由脚本自动生成目录，**不要提交到 GitHub**。

### 备份

```shell
bash backup.sh
```

默认在 `~/Desktop/backup/reset-kit/<时间戳>-<机器名>/` 下自动创建快照目录，并写入自带的 `restore.sh`。备份完成后，把整个快照目录拷到外置硬盘即可。

快照内容包括：

- `~/.ssh`
- `~/.gitconfig`
- `~/.zshrc`
- iTerm2 偏好
- CleanShot 偏好
- Keyboard Maestro 数据和偏好
- Rime/Squirrel 配置、词库和用户词库
- TextFlash 数据和偏好（通过应用内置脚本备份）
- Brave 插件本地配置（见下；书签/扩展列表仍靠 Brave Sync）

### 恢复

进入**该次备份生成的快照目录**，执行其中的 `restore.sh`（不经过 `bootstrap.sh`）：

```shell
cd ~/Desktop/backup/reset-kit/20260619-120000-MacBook
bash restore.sh
```

`restore.sh` 只读取自身所在目录，不依赖本仓库其它文件。建议在新机先跑完 `bash bootstrap.sh`（应用已安装）再执行恢复，这样配置才有落点；若 restore 覆盖了 Oh My Zsh 生成的 `.zshrc`，以快照为准，属预期行为。

### Brave 插件本地配置

Brave Sync 可以同步书签和扩展列表，但多数插件写在本机的配置不会进 Sync。备份只抓这些不同步的数据：

- `Local Extension Settings`（`chrome.storage.local`）
- `IndexedDB` 下的 `chrome-extension_*`（部分插件的本地库）

不备份整个浏览器 Profile（Cookie、历史、缓存等）。恢复后建议：先打开 Brave 并登录 Sync 拉回扩展，再确认各插件本地设置是否已恢复。

TextFlash 默认读取 `/Applications/TextFlash.app` 内置的备份脚本。如果安装在其他路径，可以通过环境变量指定：

```shell
TEXTFLASH_APP_PATH="$HOME/Applications/TextFlash Dev.app" bash backup.sh
```

恢复 TextFlash 时同样可用 `TEXTFLASH_APP_PATH`。恢复前会把现有配置挪成 `.before-restore-时间戳`。`.ssh`、Git 与 shell 配置属于敏感数据，只适合可信离线介质。

如果 macOS 首次提示 Terminal 访问桌面或应用配置目录，请允许；拒绝后对应步骤可能失败。

## 📝 其他

本仓库配置均是基于作者本人使用习惯和个人需求，可以根据自己的需求修改。
其中 `Brewfile` 是通过 `brew bundle dump` 生成的，可以通过 `brew bundle` 安装其中的软件。
