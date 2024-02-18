# MacOS config and applications as code

通过执行脚本批量完成系统的设置的更改，应用程序的安装等。

适用于初始化电脑，或者多个电脑统一配置。不用去 UI 设置页面挨个查找并设置。应用程序也不用依次下载安装。

### 如何改变系统配置

Mac 提供了一个 `defaults` 的命令可以查询和配置各个系统参数，包括但不限于 Dock、触发角、系统偏好等等。

执行 `defaults` 命令后瞬间完成配置，不用去 System Settings 依次去找各个要设置的点并修改。

### 如何安装软件

安装软件主要依赖 `brew` ，通过 `brew` 安装非 App Store 的软件。并且 `brew` 安装一个叫做 `mas` 的命令行软件，可以安装和更新 App Store 的软件。