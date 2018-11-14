该脚本用来同步 CentOS yum 源到本地，供内网中无外网访问权限的主机更新、安装软件。

## 使用方法

在使用之前需要修改 `rsync-centos-yum.sh` 脚本中的变量值：

> include="centos.list"

用于指定包含文件，默认为 centos.list，将同步 CentOS 6，7 两个系统下的文件。

可以修改为：

- centos.list  #同步 CentOS 6，7
- centos6.list #仅同步 CentOS 6
- cnetos7.list #仅同步 CentOS 7

> DST=/data/mirrors/centos

同步文件存放目录，默认为 /data/mirrors/centos，可根据自己的情况修改，需要保证有足够的空间用于存放同步文件。

- 只同步 CentOS 6 大概需要 22G 空间
- 只同步 CentOS 7 大概需要 44G 空间

执行脚本进行同步，同步日志写入文件：`rsync-centos-yum.log`。

```
./rsync-centos-yum.sh
```

或者指定 include 文件执行：

```
./rsync-centos-yum.sh centos7.list
```

加上 -n 参数可以只查看同步文件，不执行同步操作：

```
./rsync-centos-yum.sh centos7.list -n
```

### 提供下载

只需提供 HTTP 服务即可，最简单的方法是用 Python 的 SimpleHTTPServer 模块

```
cd /data/mirrors/ && nohup python -m SimpleHTTPServer 80 &> /var/log/mirrors.log &
```

### 定时同步

将脚本加入 crontab

```
9 0 * * * /scripts/centos-yum-mirror/rsync-centos-yum.sh &> /dev/null
```

### 开机自启

开启自动提供 HTTP 服务，修改 /etc/rc.local 文件，加入内容：

```
cd /data/mirrors/ && nohup python -m SimpleHTTPServer 80 &> /var/log/centos-yum-mirror_access.log &
```

确保 rc.local 有执行权限

```
chmod +x /etc/rc.d/rc.local
```

## 配置 yum 源

在需要配置 yum 源的机器上操作，首先将系统默认的配置文件备份到其他目录

```
cd /etc/yum.repo.d/
mkdir bak
mv *.repo bak
```

创建配置文件：/etc/yum.repo.d/local.repo，内容为如下：（请将 IP 地址更改为提供源的服务器 IP）

```
[base]
name=local-$releasever - Base
baseurl=http://192.168.88.45/centos/$releasever/os/$basearch/
gpgcheck=0

[updates]
name=local-$releasever - Updates
baseurl=http://192.168.88.45/centos/$releasever/updates/$basearch/
gpgcheck=0

[extras]
name=local-$releasever - Extras
baseurl=http://192.168.88.45/centos/$releasever/extras/$basearch/
gpgcheck=0

[centosplus]
name=local-$releasever - Plus
baseurl=http://192.168.88.45/centos/$releasever/centosplus/$basearch/
gpgcheck=0
```

更新 yum 缓存

```
yum clean all
yum makecache
```

## 关于

脚本使用的镜像源地址：

rsync://rsync.mirrors.ustc.edu.cn/centos

by [中国科学技术大学开源软件镜像](http://mirrors.ustc.edu.cn/)
