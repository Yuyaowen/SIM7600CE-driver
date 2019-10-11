# OpenWrt添加4G模块（SIM7600CE）驱动

此代码放在OpenWrt的package/中自己创建的目录中即可

+ 配置OpenWrt源代码(make menuconfig)

```
Kernel modules  --->
	USB Support  --->
		<*> kmod-usb-net
		<*>   kmod-usb-net-qmi-wwan
		<*>   kmod-usb-net-rndis
		<*> kmod-usb-ohci
		<*> kmod-usb-serial
		<*> kmod-usb-serial-option
		-*- kmod-usb-serial-wwan
		<*> kmod-usb-uhci
		<*> kmod-usb2

Utilities  --->
	<*> comgt
	<*> usb-modeswitch

Network  --->
	-*- chat
	<*> umbim
	<*> uqmi
	<*> ppp
```

+ 修改内核代码：
> 修改USB转串口驱动option.c （标准kernel下的路径为driver/usb/serial/option.c）
> + Linux3.2 以上版本：
> ```
> #define SIMCOM_SIM7600_VID	0x1E0E
> #define SIMCOM_SIM7600_PID	0x9001
> // for SIM7600 modem for NDIS
> static const struct option_blackkist_info 
> simcom_sim7600_blacklist = {
> .reserved = BITS(5),
> }
> ```
> 在option_ids列表中添加
> ```
> // for for SIM7600 modem for NDIS
> { USB_DEVICE(SIMCOM_SIM7600_VID, SIMCOM_SIM7600_PID),
>   .driver_info = (kernel_ulong_t)&simcom_sim7600_blacklist
> },
> ```
> 在option_probe中过滤掉interface 5
> ```
> /* sim7600 */
> if (serial->dev->descriptor.idVendor == SIMCOM_SIM7600_VID &&
>     serial->dev->descriptor.idProduct == SIMCOM_SIM7600_PID &&
>     serial->interface->cur_altsetting->desc.bInterfaceNumber == 5 )
>     return -ENODEV;
> ```

+ 添加驱动文件
> 配置 CONFIG_USBNET = y
> simcom_wwan.c 放在内核源码树种 drivers/net/usb中
> 修改 Makefile：
> ```
> obj-$(CONFIG_USB_NET)    += usbnet.o simcom_wwan.o
> ```
> 正确加载模块后，会出现4个USB转串口，ifconfig -a命令会看到wwan0设备

+ 在OpenWrt中添加配置，使wwan0自动启动，并且自动获取IP地址
> 在/etc/config/network中添加：
> ```
> config interface 'wan'
>         option ifname 'wwan0'
>         option proto 'dhcp'
> ```
> 然后重启网络/etc/init.d/network restart

+ 拨号
> 五个串口中第三个为拨号口：
> ```
> echo 'AT$QCRMCALL=1,1' > /dev/ttyUSB2
> ```
> 拨号成功就可以看到IP地址了。
