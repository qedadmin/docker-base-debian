Custom base image built with Debian 10 and [S6 overlay](https://github.com/just-containers/s6-overlay).

* NIS client
* Postfix relay
* AutoFs (requires Privileged mode)
* .. + all necessary packages

## Usage

To get started.

### docker

```
docker create \
  --name=debian10 \
  --net=bridge \
  -e DEFAULTDOMAIN=default-domain \
  -e NISSERVERS=yp.int.dummydomain.com \
  -e TZ=UTC \
  -e MAILNAME=node.int.dummydomain.com \
  -e RELAYHOST=smtprelay.dummydomain.com \
  -e MYDESTINATION=node.int.dummydomain.com, localhost.int.dummydomain.com, , localhost
  -v <path to master and map files>:/etc/auto.master.d \
  --privileged
  --restart unless-stopped \
  qedadmin/base-debian
```

## Parameters


| Parameter | Function |
| :---- | --- |
| `-e DEFAULTDOMAIN=` | null\|string for /etc/defaultdomain |
| `-e NISSERVERS=` | null\|string for /etc/yp.conf |
| `-e TZ=UTC` | Specify a timezone |
| `-e MAILNAME=` | Specify a mailname |
| `-e RELAYHOST=` | Specify a relay host |
| `-e MYDESTINATION=` | Specify a destination |
| `-v /etc/auto.master.d` | Location of master (*.autofs) and map files |


### AutoFs
AutoFs can be enabled by adding Master files and Map files under `/etc/auto.master.d` and it will auto-mount directories on an as-needed basis.

Master file - (sample: `/etc/auto.master.d/auto.autofs`)
```
# mount-point [map-type[,format]:]map [options]
# Sample
/- /etc/auto.master.d/home.host --timeout=60
```

Map file (sample: `/etc/auto.master.d/home.host`)
```
# key [-options] location
# Sample
/home    -fstype=nfs,bg,intr    homeserver:/s0/home
```
