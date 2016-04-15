# An odd case of docker overlay network speed
ref: https://github.com/UKTradeInvestment/docker-overlay-network-benchmark

Docker overlay is based on VXLAN which is in fact a standardized way to wrap an ethernet package in UDP (ref: https://tools.ietf.org/html/rfc7348). It adds an overhead of 54 bytes on top of each package so you should expect a slightly degraded capacity (approx 4%).

Let's benchmark it before going for a live usage.

And now surprise. Amazon AWS VM after enabling overlay network supplied approx 33% capacity compared to host network 
(w/o VXLAN). What? Why? Am I really using VXLANs? Quick peek into dmesg output confirms that yes.
Let's check something else. Digital Ocean maybe? They are... cheap. So I quickly verified with Digital Ocean, a way less 
sophisticated VM supplier, and it just behaved ok. Overlay network works with approx 94% capacity of host network.

What the hell?

Eventually I've realised that AWS describes t2.small VMs, that I tend to use for testing, as Low/Moderate network capacity.
1 more test, but this time with AWS VM m4.xlarge (Network Performance High) and results are brilliant. 
About 94% capacity. Now we are talking.

```
config                | speed host    | speed overlay
----------------------+---------------+---------------
AWS t2.small          | 892 Mbits/sec | 270 Mbits/sec
AWS m4.xlarge         | 875 Mbits/sec | 822 Mbits/sec
Digital Ocean         | 939 Mbits/sec | 891 Mbits/sec
```

Moral? There is no moral; I can only hope Amazon AWS will soon "fix" their networking stack for t2.smalls...
Because, for instance, they are not the only one supplier on the market ;)


# AWS t2.small
```
export AWS_ACCESS_KEY_ID="TBD"
export AWS_SECRET_ACCESS_KEY="TBD"
export AWS_DEFAULT_REGION="eu-west-1"
export AWS_INSTANCE_TYPE="t2.small"
./iperf-setup.sh test
```

## host network usage (no VXLAN)
```
$ ./iperf-host.sh test
Starting iperf server
ee5b0624e5299c55f5ed6a5406fae978781c2ab06749cc701602b513bb19dc60
[SUM]  0.0-10.1 sec  1.10 GBytes   934 Mbits/sec
[SUM]  0.0-10.1 sec  1.05 GBytes   892 Mbits/sec
[SUM]  0.0-10.1 sec  1001 MBytes   832 Mbits/sec
iperf_host
```

## overlay network usage (VXLAN)
```
$ ./iperf-overlay.sh test
Creating network
fe193d1a10c69409f3533ecd96b8f00d8f1a6ae3f945db261fd83c1ad0a01673
Starting iperf server
94e9e9763a52613cf8bcf84fa07a6416e6658103c40fcc44cf72724741283e6f
[SUM]  0.0-10.4 sec   335 MBytes   271 Mbits/sec
[SUM]  0.0-10.4 sec   333 MBytes   270 Mbits/sec
[SUM]  0.0-10.1 sec   329 MBytes   273 Mbits/sec
iperf_overlay
```



# AWS m4.xlarge
```
export AWS_ACCESS_KEY_ID="TBD"
export AWS_SECRET_ACCESS_KEY="TBD"
export AWS_DEFAULT_REGION="eu-west-1"
export AWS_INSTANCE_TYPE="m4.xlarge"
./iperf-setup.sh xlarge
```

## host network usage (no VXLAN)
```
$ ./iperf-host.sh xlarge
Starting iperf server
d96569c8705c196d25ac6c0474080952b20634b7a47c4d20fa425bac54572d78
[SUM]  0.0-10.1 sec  1.03 GBytes   875 Mbits/sec
[SUM]  0.0-10.1 sec  1.03 GBytes   875 Mbits/sec
[SUM]  0.0-10.1 sec   953 MBytes   792 Mbits/sec
iperf_host
```

## overlay network usage (VXLAN)
```
$ ./iperf-overlay.sh xlarge
Creating network
251fe8e3af028033d29758a4d0768cd34771a00cead78922d2017ef153a306ed
Starting iperf server
95ea06ed1ba4ba3a4e4e37b67bf3411d862823a8edb509181058cfc9a1b4d06c
[SUM]  0.0-10.2 sec  1003 MBytes   827 Mbits/sec
[SUM]  0.0-10.3 sec  1005 MBytes   822 Mbits/sec
[SUM]  0.0-10.2 sec   999 MBytes   822 Mbits/sec
iperf_overlay
```



# Digital Ocean
```
export DIGITALOCEAN_ACCESS_TOKEN="TBD"
./iperf-setup.sh do digitalocean
```

## host network usage (no VXLAN)
```
$ ./iperf-host.sh do
Starting iperf server
5d5e00324ad84659070e1cdb02ddd812d4185b17e9b1de69dd63a104128faa67
[SUM]  0.0-10.1 sec  1.11 GBytes   939 Mbits/sec
[SUM]  0.0-10.2 sec  1.11 GBytes   942 Mbits/sec
[SUM]  0.0-10.1 sec  1.11 GBytes   948 Mbits/sec
iperf_host
```

## overlay network usage (VXLAN)
```
$ ./iperf-overlay.sh do
Creating network
76b8bb61d76985a0132e3ae77dc3e994679bc5a4114f3f44c199b597c4fdf143
Starting iperf server
6bda1ecad24c8d0457f405442a00fc1720a7bb79e70f7004f989dd861b5fb75c
[SUM]  0.0-10.2 sec  1.05 GBytes   887 Mbits/sec
[SUM]  0.0-10.2 sec  1.06 GBytes   892 Mbits/sec
[SUM]  0.0-10.1 sec  1.05 GBytes   891 Mbits/sec
iperf_overlay
```



# Credits
Scripts are based on great article by Mustafa Akin: 
http://www.mustafaak.in/2015/12/05/docker-overlay-performance.html
