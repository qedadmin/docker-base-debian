Custom base image built with Debian 10 and [S6 overlay](https://github.com/just-containers/s6-overlay).

* NIS client
* .. + all necessary packages

## Usage

To get started.

### docker

```
docker create \
  --name=debian10 \
  --net=bridge \
  -e DEFAULTDOMAIN=default-domain \
  -e NISSERVERS=yp.dummydomain.com \
  -e TZ=UTC \
  --restart unless-stopped \
  qedadmin/base-debian
```

## Parameters


| Parameter | Function |
| :---- | --- |
| `-e DEFAULTDOMAIN=` | null\|string for /etc/defaultdomain |
| `-e NISSERVERS=` | null\|string for /etc/yp.conf |
| `-e TZ=Asia/Singapore` | Specify a timezone |
