# 🚀 Comandos de Instalación Wget

## ✅ Comando Principal (Una línea)

```bash
wget --no-cache -O- https://raw.githubusercontent.com/sysdevfiles/proxy-http/main/proxy-http.sh | sudo bash
```

## 🔄 Comando Alternativo (Descarga y ejecuta)

```bash
wget --no-cache https://raw.githubusercontent.com/sysdevfiles/proxy-http/main/proxy-http.sh -O proxy-http.sh && chmod +x proxy-http.sh && sudo bash proxy-http.sh && rm proxy-http.sh
```

## 📋 Para revisar antes de ejecutar

```bash
# Solo descargar para revisar
wget https://raw.githubusercontent.com/sysdevfiles/proxy-http/main/proxy-http.sh

# Revisar contenido
cat proxy-http.sh

# Ejecutar manualmente
chmod +x proxy-http.sh
sudo ./proxy-http.sh

# Limpiar
rm proxy-http.sh
```

## 🎯 Estructura del Repositorio

Para que los comandos funcionen, el repositorio debe tener esta estructura:

```
https://github.com/sysdevfiles/proxy-http/
├── proxy-http.sh          # ← Script de instalación (RAÍZ)
├── src/
│   └── server.js
├── config/
│   └── config.json
├── docs/
├── examples/
└── test/
```

## ✅ Estado Actual

- ✅ `proxy-http.sh` está en la raíz del proyecto
- ✅ Script funcional y probado
- ✅ URLs correctas en toda la documentación
- ✅ Comandos wget listos para usar

## 🆘 Si la instalación falla

### Diagnóstico automático:
```bash
wget https://raw.githubusercontent.com/sysdevfiles/proxy-http/main/diagnostico.sh
chmod +x diagnostico.sh && sudo ./diagnostico.sh
```

### Instalación manual (método alternativo):
```bash
wget https://raw.githubusercontent.com/sysdevfiles/proxy-http/main/manual-install.sh
chmod +x manual-install.sh && sudo ./manual-install.sh
```

### Guía completa de solución de problemas:
```bash
wget https://raw.githubusercontent.com/sysdevfiles/proxy-http/main/TROUBLESHOOTING.md
cat TROUBLESHOOTING.md
```

## 🚀 Pasos para activar

1. Subir el proyecto a: `https://github.com/sysdevfiles/proxy-http`
2. Asegurar que el repositorio sea público
3. Probar el comando wget desde cualquier VPS Ubuntu

¡Listo para producción! 🎉
