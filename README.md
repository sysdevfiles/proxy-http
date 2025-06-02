# HTTP Proxy 101

🚀 **Servidor proxy HTTP simple que responde con código 101 para bypass de restricciones de red.**

Compatible con aplicaciones como HTTP Injector, OpenVPN, y otras herramientas de túnel.

## ⚡ Instalación Rápida (Ubuntu VPS)

```bash
wget --no-cache -O- https://raw.githubusercontent.com/sysdevfiles/proxy-http/main/proxy-http.sh | sudo bash
```

### Instalación Alternativa

```bash
wget --no-cache https://raw.githubusercontent.com/sysdevfiles/proxy-http/main/proxy-http.sh -O proxy-http.sh && chmod +x proxy-http.sh && sudo bash proxy-http.sh && rm proxy-http.sh
```

## ✨ Características

- ✅ **Puerto 80**: Servidor HTTP principal
- ✅ **Código 101**: Respuestas Switching Protocols para bypass
- ✅ **CONNECT**: Soporte completo para túneles HTTPS
- ✅ **Systemd**: Servicio automático en Linux
- ✅ **Firewall**: Configuración UFW automática
- ✅ **Seguridad**: Usuario aislado y permisos mínimos
- ✅ **Logs**: Monitoreo completo con journalctl

## 🎯 Uso

Una vez instalado, el proxy estará disponible en:

- **Host**: Tu IP del servidor
- **Puerto**: 80
- **Tipo**: HTTP Proxy

### Configuración en Apps

**HTTP Injector:**
```
Proxy Host: TU_VPS_IP
Proxy Port: 80  
Proxy Type: HTTP
```

**OpenVPN:**
```
http-proxy TU_VPS_IP 80
```

**Curl:**
```bash
curl --proxy http://TU_VPS_IP:80 https://httpbin.org/ip
```

## 🔧 Gestión del Servicio

```bash
# Ver estado
sudo systemctl status http-proxy-101

# Ver logs en vivo
sudo journalctl -u http-proxy-101 -f

# Reiniciar servicio
sudo systemctl restart http-proxy-101

# Scripts de utilidad
sudo /opt/http-proxy-101/scripts/status.sh
sudo /opt/http-proxy-101/scripts/restart.sh
sudo /opt/http-proxy-101/scripts/logs.sh
```

## 📋 Requisitos

- **OS**: Ubuntu 18.04+ (recomendado 20.04/22.04 LTS)
- **RAM**: 512MB+ (recomendado 1GB)
- **Puertos**: 80 y 443 libres
- **Permisos**: sudo/root

## 🛠️ Desarrollo Local

```bash
git clone https://github.com/sysdevfiles/proxy-http.git
cd proxy-http
npm install
npm start
```

## 📚 Documentación

- [Instalación Completa](INSTALLATION.md)
- [Guía VPS](docs/VPS-DEPLOY.md)
- [Comandos Wget](COMANDOS-WGET.md)
- [Estado del Proyecto](PROYECTO-ESTADO.md)

## 🔥 Lo que hace el instalador

1. ✅ Actualiza Ubuntu y dependencias
2. ✅ Instala Node.js LTS automáticamente  
3. ✅ Crea usuario del sistema `proxy`
4. ✅ Instala servidor en `/opt/http-proxy-101`
5. ✅ Configura servicio systemd
6. ✅ Configura firewall UFW
7. ✅ Inicia servicio automáticamente
8. ✅ Crea scripts de gestión

## ⚠️ Notas Importantes

- Asegúrate de que el puerto 80 esté libre
- El script requiere permisos sudo/root
- Configurado para máxima compatibilidad con apps de túnel
- Logs disponibles en: `journalctl -u http-proxy-101`

## 🚀 Estado del Proyecto

✅ **LISTO PARA PRODUCCIÓN**

- ✅ Script de instalación automática
- ✅ Servicio systemd configurado
- ✅ Documentación completa
- ✅ Comandos wget funcionales
- ✅ Pruebas incluidas

---

**Instalación de una línea:**
```bash
wget --no-cache -O- https://raw.githubusercontent.com/sysdevfiles/proxy-http/main/proxy-http.sh | sudo bash
```

¡Listo en menos de 5 minutos! 🎉
