# macOS config and applications as code

通过执行脚本批量完成系统的设置的更改，应用程序的安装等。

完全执行 `sh init.sh` 适用于初始化电脑。
部分执行 `defaults` 相关命令可以统一多个电脑配置。

## 如何改变系统配置

macOS 提供了一个 `defaults` 的命令可以查询和配置各个系统参数，包括但不限于 Dock、触发角、系统偏好等等。

执行命令后瞬间完成配置，不用去 UI 页面 System Settings 依次去找各个要设置的点并修改。

## 如何安装软件

1. 依赖 `brew` 命令安装非 App Store 的软件
2. 依赖 `mas`(通过 brew 安装的命令行应用) 命令安装 App Store 的软件

## 重要

- 受限于 GFW ，部分用户执行这些脚本前先解决好网络问题，否则几乎无法正常执行。
- 有些程序安装需要 `sudo` 权限，需要在对应位置手动输入密码确认权限。或者提前 `sudo -s` 进入 root 用户的 shell (需要确认安装内容安全可控，但是**不建议**对未知程序使用)。


## 开始执行

```shell
sh init.sh
```

依次执行各个项目的安装和配置，下面是按照执行顺序的各个模块的说明。其中 1 和 4 瞬间完成，2 和 3 需要下载软件，时间较长。

1. `defaults_config.sh` 修改 Mac 系统设置，和作者本人的使用习惯相关，包括简单密码、Finder 设置等
2. `brew.sh` 安装 Homebrew，之后安装一些常用的软件
3. `mas.sh` 在 2 的基础上使用 `mas` 安装一些 App Store 的软件(需要提前登录 App Store)
4. `defaults_dock.sh` 修改 Dock 设置(部分设置依赖上述步骤应用安装完成，所以最后执行)

## 其他

本仓库配置均是基于作者本人使用习惯和个人需求，可以根据自己的需求修改。
其中 `Brewfile` 是通过 `brew bundle dump` 生成的，可以通过 `brew bundle` 安装其中的软件。

## 待完善

- [ ] 修改切换输入法的快捷键(取消 Spotlight 相关的快捷键，将切换输入法修改回 ⌘Command + 空格。)
- [ ] 修改 Trackpad 支持 Swipe between pages