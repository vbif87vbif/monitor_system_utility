# Простая утилита для сбора метрик системы по расписанию

__Ставим выполнение утилиты на cron (каждые 10 минут)__
```
*/10 * * * * /bin/bash /some_dir/monitor_utility/monitor_utilility.sh -o "/tmp/log.txt"
```
__Требование по окружению__
- OS: Ubuntu 18.04-22.04
- Доп. пакеты:  ifstat, sysstat

__Пример вывода__
```
=======System information (2023-02-05_22:55:01) =======

=======Output information from func=cpu_func=======
Linux 5.15.0-58-generic (app-serv-edu-3)        02/05/2023      _x86_64_        (2 CPU)

10:55:01 PM  CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest  %gnice   %idle
10:55:02 PM  all    1.50    0.00    1.00    0.00    0.00    0.00    0.00    0.00    0.00   97.50
10:55:03 PM  all    0.00    0.00    0.50    0.00    0.00    0.00    0.00    0.00    0.00   99.50
10:55:04 PM  all    0.51    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00   99.49
10:55:05 PM  all    0.51    0.00    0.51    5.05    0.00    0.00    0.00    0.00    0.00   93.94
10:55:06 PM  all    1.00    0.00    0.50    1.00    0.00    0.00    0.00    0.00    0.00   97.51
Average:     all    0.70    0.00    0.50    1.20    0.00    0.00    0.00    0.00    0.00   97.59

=======Output information from func=memory_func=======

  - run free -m
               total        used        free      shared  buff/cache   available
Mem:            5932        1048        3154           3        1730        4580
Swap:              0           0           0
               total        used        free      shared  buff/cache   available
Mem:            5932        1048        3154           3        1730        4580
Swap:              0           0           0
               total        used        free      shared  buff/cache   available
Mem:            5932        1048        3154           3        1730        4580
Swap:              0           0           0
               total        used        free      shared  buff/cache   available
Mem:            5932        1048        3154           3        1730        4580
Swap:              0           0           0
               total        used        free      shared  buff/cache   available
Mem:            5932        1048        3154           3        1730        4581
Swap:              0           0           0

=======Output information from func=network_func=======
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.129.0.32  netmask 255.255.255.0  broadcast 10.129.0.255
        inet6 fe80::d20d:19ff:fe55:a614  prefixlen 64  scopeid 0x20<link>
        ether d0:0d:19:55:a6:14  txqueuelen 1000  (Ethernet)
        RX packets 209973  bytes 168008368 (168.0 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 145771  bytes 27480436 (27.4 MB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 350965  bytes 92390788 (92.3 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 350965  bytes 92390788 (92.3 MB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

        lo                 eth0       
 KB/s in  KB/s out   KB/s in  KB/s out
    0.85      0.85      0.83      0.64
    1.81      1.81      1.54      1.30
    0.70      0.70      0.68      0.62
    2.18      2.18      1.88      2.45
    3.36      3.36      2.09      3.06

=======Output information from func=disk_func=======

====Echo of lsblk
NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
loop0    7:0    0  63.3M  1 loop /snap/core20/1778
loop1    7:1    0  63.2M  1 loop /snap/core20/1738
loop2    7:2    0 137.3M  1 loop /snap/golangci-lint/104
loop3    7:3    0   103M  1 loop /snap/lxd/23541
loop4    7:4    0 111.9M  1 loop /snap/lxd/24322
loop5    7:5    0  49.6M  1 loop /snap/snapd/17883
loop6    7:6    0  49.8M  1 loop /snap/snapd/17950
loop7    7:7    0 144.4M  1 loop /snap/golangci-lint/109
vda    252:0    0   100G  0 disk 
├─vda1 252:1    0     1M  0 part 
└─vda2 252:2    0   100G  0 part /

====Echo of iostat -dx
Linux 5.15.0-58-generic (app-serv-edu-3)        02/05/2023      _x86_64_        (2 CPU)

Device            r/s     rkB/s   rrqm/s  %rrqm r_await rareq-sz     w/s     wkB/s   wrqm/s  %wrqm w_await wareq-sz     d/s     dkB/s   drqm/s  %drqm d_await dareq-sz     f/s f_await  aqu-sz  %util
loop0            0.01      0.07     0.00   0.00    9.52     8.81    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    0.00   0.01
loop1            0.00      0.01     0.00   0.00    4.89     7.78    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    0.00   0.00
loop2            0.00      0.03     0.00   0.00   34.47    14.88    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    0.00   0.00
loop3            0.00      0.03     0.00   0.00   12.11    17.55    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    0.00   0.00
loop4            0.00      0.04     0.00   0.00   46.59    14.77    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    0.00   0.01
loop5            0.00      0.01     0.00   0.00   54.59     8.09    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    0.00   0.01
loop6            0.05      1.67     0.00   0.00    5.75    37.06    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    0.00   0.04
loop7            0.00      0.03     0.00   0.00    0.01    15.77    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    0.00   0.00
vda              3.73    275.58     0.40   9.59   24.55    73.80    4.81     59.63     3.42  41.51    7.29    12.39    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    0.13   3.33

=======Output information from func=load_func=======

 1 - run /proc/loadavg
0.03 0.02 0.00 1/298 32897

 2 - run /proc/loadavg
0.03 0.02 0.00 1/298 32899

 3 - run /proc/loadavg
0.03 0.02 0.00 1/298 32901

 4 - run /proc/loadavg
0.03 0.02 0.00 1/298 32903

 5 - run /proc/loadavg
0.03 0.02 0.00 1/299 32906
```