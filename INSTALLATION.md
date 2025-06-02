# Instalación con una línea de comando

## Instalación rápida desde GitHub

Para instalar HTTP Proxy 101 en tu VPS Ubuntu con un solo comando, ejecuta:

```bash
wget --no-cache -O- https://raw.githubusercontent.com/sysdevfiles/proxy-http/main/proxy-http.sh | sudo bash
```

### Instalación alternativa (descarga y ejecuta)

Si prefieres revisar el script antes de ejecutarlo:

```bash
wget https://raw.githubusercontent.com/sysdevfiles/proxy-http/main/proxy-http.sh
chmod +x proxy-http.sh
sudo ./proxy-http.sh
rm proxy-http.sh
```

### Instalación con descarga temporal

```bash
wget --no-cache https://raw.githubusercontent.com/sysdevfiles/proxy-http/main/proxy-http.sh -O proxy-http.sh && chmod +x proxy-http.sh && sudo bash proxy-http.sh && rm proxy-http.sh
```

## Requisitos

- Ubuntu 18.04+ o sistema compatible
- Acceso root (sudo)
- Conexión a internet
- Puerto 80 libre
- Puerto 443 libre (opcional para HTTPS)

## Lo que hace el instalador

1. ✅ Actualiza el sistema
2. ✅ Instala Node.js LTS y dependencias
3. ✅ Crea usuario del sistema `proxy`
4. ✅ Crea directorio `/opt/http-proxy-101`
5. ✅ Instala el servidor proxy
6. ✅ Configura servicio systemd
7. ✅ Configura firewall UFW
8. ✅ Inicia el servicio automáticamente

## Verificación post-instalación

```bash
# Verificar estado del servicio
sudo systemctl status http-proxy-101

# Ver logs
sudo journalctl -u http-proxy-101 -f

# Probar conectividad
curl -I http://localhost:80
```

## Comandos útiles post-instalación

```bash
# Scripts de utilidad creados automáticamente
sudo /opt/http-proxy-101/scripts/status.sh    # Ver estado
sudo /opt/http-proxy-101/scripts/restart.sh   # Reiniciar servicio
sudo /opt/http-proxy-101/scripts/logs.sh      # Ver logs en vivo

# Comandos systemd
sudo systemctl restart http-proxy-101    # Reiniciar
sudo systemctl stop http-proxy-101       # Detener
sudo systemctl start http-proxy-101      # Iniciar
sudo systemctl disable http-proxy-101    # Deshabilitar autostart
```

## Uso del proxy

Una vez instalado, el proxy estará disponible en:

- **Puerto:** 80
- **Protocolo:** HTTP
- **Tipo:** HTTP CONNECT Proxy
- **IP:** Tu IP del servidor

### Configuración en aplicaciones

**HTTP Injector:**
```
Proxy Host: TU_IP_SERVIDOR
Proxy Port: 80
Proxy Type: HTTP
```

**OpenVPN Connect:**
```
http-proxy TU_IP_SERVIDOR 80
```

**Curl:**
```bash
curl --proxy http://TU_IP_SERVIDOR:80 https://httpbin.org/ip
```

## Solución de problemas

### El servicio no inicia
```bash
sudo journalctl -u http-proxy-101 -n 50
sudo systemctl status http-proxy-101
```

### Puerto ocupado
```bash
sudo netstat -tulpn | grep :80
sudo lsof -i :80
```

### Firewall bloqueando
```bash
sudo ufw status
sudo ufw allow 80/tcp
```

### Reinstalar
```bash
sudo systemctl stop http-proxy-101
sudo systemctl disable http-proxy-101
sudo rm -rf /opt/http-proxy-101
sudo userdel proxy
# Luego ejecutar el instalador nuevamente
```

---

## 🚀 Comando de instalación de una línea

```bash
wget --no-cache -O- https://raw.githubusercontent.com/sysdevfiles/proxy-http/main/proxy-http.sh | sudo bash
```

¡Eso es todo! El proxy estará listo para usar en unos minutos.
