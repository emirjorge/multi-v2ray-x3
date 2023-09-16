# multi-v2ray 3.11.4
a tool to manage v2ray/xray config json, support multiple user && group manage  
![](https://img.shields.io/pypi/v/v2ray-util.svg) 
[![Downloads](https://pepy.tech/badge/v2ray-util)](https://pepy.tech/project/v2ray-util)
[![Downloads](https://pepy.tech/badge/v2ray-util/month)](https://pepy.tech/project/v2ray-util)
![](https://img.shields.io/docker/pulls/jrohy/v2ray.svg)
![](https://img.shields.io/github/license/Jrohy/multi-v2ray.svg)

## [中文](README_CN.md)  [English](README_EN.md) [Español](README.md)

## Características
- Admite administración de Xray, diferentes comandos (v2ray/xray) ingresan a una administración central diferente
- Estadísticas de tráfico de V2ray && Iptables
- Línea de comando para administrar
- Múltiples usuarios y gestión de puertos
- Modo CDN de Cloudflare
- Admite VPS ipv6 puro
- Soporte Docker
- Puerto dinámico
- Prohibir bittorrent
- Puerto de rango
- TcpFastOpen
- Enlace para compartir Vmess/VLESS/Socks5/MTproto
- Modificación del protocolo de soporte:
  - TCP
  - Fake http
  - WebSocket
  - mkcp
  - mKCP + srtp
  - mKCP + utp
  - mKCP + wechat-video
  - mKCP + dtls
  - mKCP + wireguard
  - HTTP/2
  - Socks5
  - MTProto
  - Shadowsocks
  - Quic
  - VLESS_TCP
  - VLESS_TLS
  - VLESS_WS
  - VLESS_REALITY
  - Trojan

## Cómo utilizar
nueva instalación
```
source <(curl -sL https://multi.netlify.app/v2ray.sh)
```

mantener el perfil al actualizar
```
source <(curl -sL https://multi.netlify.app/v2ray.sh) -k
```

desinstalar
```
source <(curl -sL https://multi.netlify.app/v2ray.sh) --remove
```

## Línea de comando
```bash
v2ray/xray [-h|help] [options]
    -h, help             get help
    -v, version          get version
    start                start V2Ray
    stop                 stop V2Ray
    restart              restart V2Ray
    status               check V2Ray status
    new                  create new json profile
    update               update v2ray to latest
    update [version]     update v2ray to special version
    update.sh            update multi-v2ray to latest
    add                  add new group
    add [protocol]       create special protocol, random new port
    del                  delete port group
    info                 check v2ray profile
    port                 modify port
    tls                  modify tls
    tfo                  modify tcpFastOpen
    stream               modify protocol
    cdn                  cdn mode
    stats                v2ray traffic statistics
    iptables             iptables traffic statistics
    clean                clean v2ray log
    log                  check v2ray log
    rm                   uninstall core
```

## Docker Run
default will create random port + random header(srtp | wechat-video | utp | dtls) kcp profile(**if use xray replace image to jrohy/xray**)  
```
docker run -d --name v2ray --privileged --restart always --network host jrohy/v2ray
```

custom v2ray config.json:
```
docker run -d --name v2ray --privileged -v /path/config.json:/etc/v2ray/config.json --restart always --network host jrohy/v2ray
```

check v2ray profile:
```
docker exec v2ray bash -c "v2ray info"
```

**advertencia**: si ejecutas centOS, primero debes cerrar el firewall
```
systemctl stop firewalld.service
systemctl disable firewalld.service
```

## Dependencias
v2ray docker: https://hub.docker.com/r/jrohy/v2ray  
xray docker: https://hub.docker.com/r/jrohy/xray
pip: https://pypi.org/project/v2ray-util/  
python3: https://github.com/Jrohy/python3-install  
acme: https://github.com/Neilpang/acme.sh
