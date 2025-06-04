# HTTP Proxy 101

🚀 **Servidor proxy HTTP que responde con código 101 para bypass de restricciones de red**

Compatible con HTTP Injector, OpenVPN y otras herramientas de túnel.

## ⚡ Instalación Rápida (Ubuntu VPS)

```bash
wget --no-cache https://raw.githubusercontent.com/sysdevfiles/proxy-http/main/proxy-http.sh -O proxy-http.sh && chmod +x proxy-http.sh && sudo bash proxy-http.sh && rm proxy-http.sh
```

**¡Eso es todo!** El instalador detecta y corrige automáticamente cualquier problema con Node.js y puertos.

## ✨ Características

- ✅ **Auto-detección**: Encuentra y configura Node.js automáticamente
- ✅ **Auto-reparación**: Corrige problemas de instalación sin intervención
- ✅ **Puerto 80 libre**: Detecta y libera automáticamente conflictos en puerto 80
- ✅ **Detección de servicios**: Para automáticamente Apache, Nginx, Lighttpd, etc.
- ✅ **Código 101**: Respuestas "Switching Protocols" para bypass
- ✅ **Systemd**: Servicio automático con reinicio automático
- ✅ **Multi-método**: Instala Node.js via NodeSource, Snap o repos Ubuntu
- ✅ **Diagnóstico avanzado**: Muestra información detallada en caso de problemas

## 🎯 Uso en HTTP Injector

Después de la instalación, usa estos datos:

```
Host: TU_IP_VPS
Port: 80
Type: HTTP
```

## 🔧 Comandos Útiles

```bash
# Ver estado del servicio
systemctl status http-proxy-101

# Ver logs en tiempo real  
journalctl -u http-proxy-101 -f

# Reiniciar servicio
systemctl restart http-proxy-101

# Script de reinicio con auto-reparación
/opt/http-proxy-101/scripts/restart.sh

# Debugging de instalación (si hay problemas)
cd /opt/http-proxy-101
npm --version
node --version
ls -la package.json
ls -la node_modules/
```

## 🚨 Solución de Problemas

Si el instalador se cuelga en "Instalando dependencias Node.js":

1. **Verificar Node.js y npm**:
   ```bash
   which node
   which npm  
   node --version
   npm --version
   ```

2. **Instalar manualmente si es necesario**:
   ```bash
   cd /opt/http-proxy-101
   sudo npm install --production --no-optional --no-audit --no-fund
   ```

3. **Usar servidor básico sin dependencias**:
   ```bash
   systemctl stop http-proxy-101
   cp /opt/http-proxy-101/src/server-basic.js /opt/http-proxy-101/src/server.js
   systemctl start http-proxy-101
   ```

## 🛠️ Solución de Problemas

### Node.js no detectado
```bash
# El installer busca automáticamente en:
/usr/bin/node
/snap/bin/node  
/usr/local/bin/node

# Si tienes problemas, verifica manualmente:
which node
node --version
```

### Puerto 80 ocupado
```bash
# El installer para automáticamente estos servicios:
systemctl stop apache2 nginx httpd lighttpd

# Verificar manualmente:
netstat -tulpn | grep :80
```

## 📋 Requisitos

- Ubuntu 18.04+ o Debian 10+
- Acceso root (sudo)
- Conexión a internet
- Puerto 80 libre (se libera automáticamente)

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama feature (`git checkout -b feature/nueva-caracteristica`)
3. Commit tus cambios (`git commit -am 'Agrega nueva característica'`)
4. Push a la rama (`git push origin feature/nueva-caracteristica`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para detalles.
