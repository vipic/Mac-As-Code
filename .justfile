# 通过命令行统一配置电脑的设置信息
set dotenv-load

# 显示当前的配置命令
default:
	@just -l

# 追加 host 配置到 host 文件
append_multiple_to_host:
  @echo "$HOST_LINES" | sudo tee -a /etc/hosts

# 将当前配置备份到单独文件夹
backup:
    just backup_host
    just backup_zshrc

# 备份 host 文件
backup_host:
    mkdir -p /Users/$USER_NAME/backup
    cp /etc/hosts /Users/$USER_NAME/backup/hosts.bak

# 备份 zshrc 文件
backup_zshrc:
    mkdir -p /Users/$USER_NAME/backup
    cp /Users/$USER_NAME/.zshrc /Users/$USER_NAME/backup/zshrc.bak

start: append_multiple_to_host
    sh init.sh