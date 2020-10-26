# Drcom-Padavan

---

<p align="center">
  <a href="https://openwrt.org/"><img src="https://s1.ax1x.com/2020/10/15/07lZZR.png"></a>
</p>
<p align="center">
    <a href="https://github.com/hisaner/Drcom-Padavan"><img src="https://img.shields.io/badge/release-v0.1-brightgreen.svg"></a>
    <a href="http://opt.cn2qq.com/padavan/"><img src="https://img.shields.io/badge/platform-Padavan-blue.svg"></a>
    <a href="https://opensource.org/licenses/GPL-3.0"><img src="https://img.shields.io/badge/license-AGPLv3-blue.svg"></a>
</p>

# 免责声明
> 1. 在根据本教程进行实际操作时，如因您操作失误导致出现的一切意外由您自行承担；
> 2. 该技术仅供学习交流，请勿将此技术应用于任何商业行为，所产生的法律责任由您自行承担；


# 准备工作

-**一款已刷入第三方系统([Padavan](http://opt.cn2qq.com/padavan/))的路由器**
- 该路由器刷入不死[Breed](https://breed.hackpascal.net/)。详见[恩山](https://www.right.com.cn/forum/thread-161906-1-1.html)
- 一根网线
- 下载软件[Xshell](https://www.netsarang.com/zh/xshell/)

# 前言

> 1.本教程教您如何在[Drcom](https://wiki.archlinux.org/index.php/Drcom_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))下使用路由器的curl模拟登录请求

> 2.本教程适合使用[Drcom](https://wiki.archlinux.org/index.php/Drcom_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))进行web上网的用户，同时，要求您的路由器支持刷入第三方系统，如padavan。
本校您可直接修改替换`auto_login.sh`文件中的`账号`和`密码`。注意，其中@运营商一项，移动是@cmcc，联通是@unicom（未测），如是联通账号自行修改。接着你可直接跳至**脚本上传到路由器**，如无法使用请自行获取curl连接，可能问题是需要修改wlanacip，自行测试。

> 3.关于晚上定时断网问题，详见**定时断网问题**

> 4.本教程适合本身玩过路由的用户，完全没有任何了解不建议操作，可以直接使用网口PPPoE上网（无需刷路由固件）。教程陆陆续续写了许久，如有问题自行搜索解决，也可提交。

# 原理
学校有线网络 Web 认证的本质，就是发送一个 HTTP-POST 请求到认证服务器。因此，我们只需要用 curl 构造一个 POST 请求，并且在每次路由器重启后都发送一遍即可实现自动认证。<br />
尽管不同学校的 POST 请求可能会有些许差别，但只要使用了Web认证，其原理和实现方法都是相同的。

# 抓取 HTTP POST 请求

- 使用 Chrome 的开发者工具来抓取请求：Chrome浏览器打开任意一个网站，跳转到认证页面之后，右键->检查，打开开发者工具， 选择 network，勾选 Preserve log．
- 在登录页面填写帐号密码信息，点击登录， 即可看到相关的 HTTP 请求，找到 Request Method 为 POST 的那个，右键->Copy-> Copy as cURL，即可得到认证所需的 curl 命令．使用该命令即可进行登录认证，无需在打开网页之后跳转到认证页面进行网页认证了．而 curl 支持多个平台的。
- 将复制到的 cURL 粘贴到任意文本编辑器中，以待进一步的处理。
#修改 cURL 使其永久可用
- 首先将末尾的 `--compressed --insecure`去除。分析 cURL，前大半部分都是 HTTP 请求的标头（`-H` 后的内容），`User-Agent`你可以酌情作些修改或者忽略不变不影响。
- 后面的 `--data-raw` 部分，是我们需要关注的部分。根据抓到的请求，`DDDDD=%2C0%2C` 后是我们的宽带账号，`&upass=`后是我们的宽带密码。
- 为了构造可永久使用的 cURL，首先要确保宽带账号、宽带密码是正确的。由于内网IP是由DHCP自动分配的，最后需要处理的，就是内网 IP 。在 Padavan 的 Linux 环境下，你可以使用以下命令获取当前的内网 IP：
```Bash
ifconfig | grep inet | grep -v inet6 | grep -v 127 | grep -v 192 | awk '{print $(NF-2)}' | cut -d ':' -f2
```
- 我们用变量 `CURRENT_IP`存储获得的内网IP，并在curl命令中进行了替换。需要注意的是，要在bash命令的引号中使用变量的话，引号必须为双引号，而不能采用由 Chrome 复制得来的单引号。

# 扩展AP

- 确保路由已连接校园内网络，考虑到网口限速，网口直接可以普通路由PPPoE拨号无检测。2.4G干扰大。建议连接方式选择使用5GWiFi扩展桥接方式。
- [![BKahVO.jpg](https://s1.ax1x.com/2020/10/26/BKahVO.jpg)](https://imgchr.com/i/BKahVO)


# 脚本上传到路由器

- 进入路由器192.168.123.1管理后台，在 高级设置->系统管理->服务->终端服务 中启用ssh服务。
- 打开 Xshell 终端，新建会话使用 ssh 连接到路由器。Padavan 的默认网关 IP 为 192.168.123.1，用户名密码为 admin
-输入默认密码 admin 即可 ssh 登录到路由器。随后执行以下命令：
```
cd /etc/storage		#进入存储脚本的目录
vi auto_login.sh	#新建并编辑自动登录脚本
```
- 在 vi 编辑器下，按 i 进入编辑模式，将之前准备好的脚本粘贴上去，然后按 esc 退出编辑模式，随后输入 :wq 并回车即可保存。再执行以下命令赋予脚本执行权限：
```
chmod +x auto_login.sh
```
- 完成后，执行 exit 即可断开 ssh 连接。登录到路由器后台，在`系统管理 > 恢复/导出/上传设置 > 保存 /etc/storage/ 内容到闪存` 点击 提交。
[![BK0CD0.png](https://s1.ax1x.com/2020/10/26/BK0CD0.png)](https://imgchr.com/i/BK0CD0)
- 最后，在 `自定义设置 > 脚本 > 在 WAN 上行/下行启动后执行` 的内容后添加一行：/etc/storage/auto_login.sh，并点击页面最下方的 应用本页面设置即可。
[![BKwRAO.jpg](https://s1.ax1x.com/2020/10/26/BKwRAO.jpg)](https://imgchr.com/i/BKwRAO)

# 定时断网问题

为了不用每天早上手动重新连接，可以通过使用crontab来解决。
crontab命令用于设置周期性被执行的指令。该命令从标准输入设备读取指令，并将其存放于“crontab”文件中，以供之后读取和执行。
cron 系统调度进程。 可以使用它在每天的非高峰负荷时间段运行作业，或在一周或一月中的不同时段运行。cron是系统主要的调度进程，可以在无需人工干预的情况下运行作业。crontab命令允许用户提交、编辑或删除相应的作业。
将下列语句加入到`高级设置->自定义设置->脚本->自定义 Crontab 定时任务配置:`后保存。
```
# 早上6点定时重新连接（重启wan口）：
0 6 * * 1-5 restart_wan #删除开头的#启动命令
```
