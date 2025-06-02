#!/bin/bash

# HTTP Proxy 101 - Instalador para VPS Ubuntu
# Instala y configura el servidor proxy como servicio systemd

set -e  # Salir en caso de error

# Variables de configuración
PROJECT_NAME="http-proxy-101"
SERVICE_NAME="http-proxy-101"
PROJECT_DIR="/opt/${PROJECT_NAME}"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
USER="proxy"
NODE_VERSION="18"
VENV_PATH="${PROJECT_DIR}/.venv"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funciones de logging
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Ejecutar comando con manejo de errores
exec_command() {
    local command="$1"
    local description="$2"
    
    log_info "${description}..."
    
    if eval "$command" > /dev/null 2>&1; then
        log_success "${description} completado"
    else
        handle_error "Error en ${description}"
    fi
}

# Verificar si es root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "Este script debe ejecutarse como root (sudo)"
        exit 1
    fi
}

# Verificar distribución Ubuntu
check_ubuntu() {
    if [[ -f /etc/os-release ]]; then
        if grep -q "Ubuntu" /etc/os-release; then
            log_success "Sistema operativo verificado (Ubuntu)"
        else
            log_warning "Este script está optimizado para Ubuntu"
        fi
    else
        log_warning "No se pudo verificar la distribución"
    fi
}

# Actualizar sistema
update_system() {
    exec_command "apt update && apt upgrade -y" "Actualizando sistema"
}

# Instalar dependencias del sistema
install_system_dependencies() {
    local packages=(
        "curl"
        "wget"
        "gnupg"
        "software-properties-common"
        "build-essential"
        "python3"
        "python3-pip"
        "python3-venv"
        "git"
        "ufw"
        "htop"
        "nginx"
        "certbot"
        "rsync"
    )
    
    exec_command "apt install -y ${packages[*]}" "Instalando dependencias del sistema"
}

# Instalar Node.js usando NodeSource
install_nodejs() {
    # Verificar si Node.js ya está instalado
    if command -v node >/dev/null 2>&1; then
        local node_version=$(node --version 2>/dev/null)
        if [[ $node_version == v18.* ]] || [[ $node_version == v16.* ]] || [[ $node_version == v20.* ]]; then
            log_success "Node.js ya está instalado: $node_version"
            return
        fi
    fi

    log_info "Instalando Node.js LTS..."
    
    # Método 1: NodeSource (preferido)
    if install_nodejs_nodesource; then
        return
    fi
    
    # Método 2: Snap (alternativo)
    log_warning "NodeSource falló, intentando con snap..."
    if install_nodejs_snap; then
        return
    fi
    
    # Método 3: Repositorio Ubuntu (última opción)
    log_warning "Snap falló, intentando repositorio Ubuntu..."
    if install_nodejs_ubuntu; then
        return
    fi
    
    log_error "Error: No se pudo instalar Node.js con ningún método"
    exit 1
}

# Instalar Node.js vía NodeSource
install_nodejs_nodesource() {
    log_info "Intentando instalación vía NodeSource..."
    
    # Limpiar instalaciones previas
    apt remove -y nodejs npm >/dev/null 2>&1 || true
    
    # Agregar repositorio NodeSource
    if curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - >/dev/null 2>&1; then
        log_success "Repositorio NodeSource agregado"
    else
        log_error "Error agregando repositorio NodeSource"
        return 1
    fi
    
    # Instalar Node.js
    if apt install -y nodejs >/dev/null 2>&1; then
        local installed_version=$(node --version 2>/dev/null)
        log_success "Node.js instalado vía NodeSource: $installed_version"
        
        # Actualizar npm
        npm install -g npm@latest >/dev/null 2>&1 || true
        return 0
    else
        log_error "Error instalando Node.js vía NodeSource"
        return 1
    fi
}

# Instalar Node.js vía Snap
install_nodejs_snap() {
    log_info "Intentando instalación vía Snap..."
    
    # Instalar snapd si no está
    apt install -y snapd >/dev/null 2>&1 || true
    
    # Instalar Node.js vía snap
    if snap install node --classic >/dev/null 2>&1; then
        local installed_version=$(node --version 2>/dev/null)
        log_success "Node.js instalado vía Snap: $installed_version"
        return 0
    else
        log_error "Error instalando Node.js vía Snap"
        return 1
    fi
}

# Instalar Node.js vía repositorio Ubuntu
install_nodejs_ubuntu() {
    log_info "Intentando instalación vía repositorio Ubuntu..."
    
    # Actualizar repositorios
    apt update >/dev/null 2>&1 || true
    
    # Instalar Node.js y npm del repositorio Ubuntu
    if apt install -y nodejs npm >/dev/null 2>&1; then
        local installed_version=$(node --version 2>/dev/null)
        log_success "Node.js instalado vía Ubuntu: $installed_version"
        
        # Actualizar npm
        npm install -g npm@latest >/dev/null 2>&1 || true
        return 0
    else
        log_error "Error instalando Node.js vía repositorio Ubuntu"
        return 1
    fi
}

# Crear usuario del sistema
create_system_user() {
    if id "$USER" >/dev/null 2>&1; then
        log_success "Usuario $USER ya existe"
    else
        exec_command "useradd --system --shell /bin/false --home $PROJECT_DIR --create-home $USER" "Creando usuario del sistema $USER"
    fi
}

# Crear directorio del proyecto
create_project_directory() {
    exec_command "mkdir -p $PROJECT_DIR" "Creando directorio del proyecto"
    exec_command "chown -R $USER:$USER $PROJECT_DIR" "Configurando permisos"
}

# Copiar archivos del proyecto
copy_project_files() {
    local current_dir=$(pwd)
    
    log_info "Copiando archivos del proyecto..."
    
    # Copiar todos los archivos excepto node_modules y .git
    exec_command "rsync -av --exclude 'node_modules' --exclude '.git' --exclude '.venv' $current_dir/ $PROJECT_DIR/" "Copiando archivos"
    
    # Configurar permisos
    exec_command "chown -R $USER:$USER $PROJECT_DIR" "Configurando permisos de archivos"
    exec_command "chmod +x $PROJECT_DIR/scripts/proxy-http.sh" "Haciendo ejecutable el instalador"
}

# Crear entorno virtual Python
create_virtual_environment() {
    log_info "Creando entorno virtual Python..."
    
    exec_command "sudo -u $USER python3 -m venv $VENV_PATH" "Creando entorno virtual"
    
    # Instalar algunas utilidades Python útiles
    exec_command "sudo -u $USER $VENV_PATH/bin/pip install requests psutil" "Instalando utilidades Python"
}

# Instalar dependencias Node.js
install_node_dependencies() {
    log_info "Instalando dependencias Node.js..."
    
    cd "$PROJECT_DIR"
    
    exec_command "sudo -u $USER npm install --production" "Instalando dependencias npm"
    
    # Instalar herramientas globales
    exec_command "npm install -g nodemon pm2" "Instalando herramientas globales"
}

# Crear archivo de servicio systemd
create_systemd_service() {
    cat > "$SERVICE_FILE" << EOF
[Unit]
Description=HTTP Proxy 101 - Bypass Proxy Server
Documentation=https://github.com/http-proxy-101/server
After=network.target
Wants=network.target

[Service]
Type=simple
User=$USER
Group=$USER
WorkingDirectory=$PROJECT_DIR
Environment=NODE_ENV=production
Environment=PATH=/usr/bin:/usr/local/bin
ExecStart=/usr/bin/node $PROJECT_DIR/src/server.js
ExecReload=/bin/kill -USR2 \$MAINPID
Restart=always
RestartSec=10
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=$SERVICE_NAME

# Seguridad
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=$PROJECT_DIR

# Límites de recursos
LimitNOFILE=65535
LimitNPROC=65535

# Red
IPAddressDeny=any
IPAddressAllow=localhost
IPAddressAllow=10.0.0.0/8
IPAddressAllow=172.16.0.0/12
IPAddressAllow=192.168.0.0/16

[Install]
WantedBy=multi-user.target
EOF

    log_success "Archivo de servicio systemd creado"
}

# Configurar firewall
configure_firewall() {
    log_info "Configurando firewall UFW..."
    
    # Habilitar UFW si no está activo
    ufw --force enable > /dev/null 2>&1 && log_success "UFW habilitado" || log_warning "Error habilitando UFW"
    
    # Permitir SSH
    ufw allow ssh > /dev/null 2>&1 && log_success "SSH permitido" || log_warning "Error permitiendo SSH"
    
    # Permitir puerto 80 (HTTP)
    ufw allow 80/tcp > /dev/null 2>&1 && log_success "Puerto 80 permitido" || log_warning "Error permitiendo puerto 80"
    
    # Permitir puerto 443 (HTTPS)
    ufw allow 443/tcp > /dev/null 2>&1 && log_success "Puerto 443 permitido" || log_warning "Error permitiendo puerto 443"
    
    # Mostrar estado
    log_info "Estado del firewall:"
    ufw status numbered
}

# Habilitar y iniciar servicio
enable_service() {
    exec_command "systemctl daemon-reload" "Recargando systemd"
    exec_command "systemctl enable $SERVICE_NAME" "Habilitando servicio"
    exec_command "systemctl start $SERVICE_NAME" "Iniciando servicio"
    
    # Esperar y verificar estado
    sleep 3
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        log_success "Servicio iniciado correctamente"
    else
        log_warning "El servicio puede no estar funcionando correctamente"
        systemctl status "$SERVICE_NAME" --no-pager
    fi
}

# Crear scripts de utilidad
create_utility_scripts() {
    local scripts_dir="$PROJECT_DIR/scripts"
    
    # Script de estado
    cat > "$scripts_dir/status.sh" << EOF
#!/bin/bash
echo "=== HTTP Proxy 101 Status ==="
systemctl status $SERVICE_NAME
echo ""
echo "=== Logs (últimas 20 líneas) ==="
journalctl -u $SERVICE_NAME -n 20 --no-pager
EOF

    # Script de reinicio
    cat > "$scripts_dir/restart.sh" << EOF
#!/bin/bash
echo "Reiniciando HTTP Proxy 101..."
systemctl restart $SERVICE_NAME
sleep 2
systemctl status $SERVICE_NAME
EOF

    # Script de logs
    cat > "$scripts_dir/logs.sh" << EOF
#!/bin/bash
echo "Logs de HTTP Proxy 101 (Ctrl+C para salir):"
journalctl -u $SERVICE_NAME -f
EOF

    exec_command "chmod +x $scripts_dir/*.sh" "Haciendo ejecutables los scripts de utilidad"
    log_success "Scripts de utilidad creados"
}

# Función de diagnóstico en caso de error
run_diagnostics() {
    echo -e "${YELLOW}
╔══════════════════════════════════════════════════════════════╗
║                   🔍 EJECUTANDO DIAGNÓSTICO                  ║
╚══════════════════════════════════════════════════════════════╝${NC}"

    echo ""
    log_info "Recopilando información del sistema..."
    
    echo "📋 Sistema: $(lsb_release -d 2>/dev/null | cut -f2 || echo 'Ubuntu')"
    echo "🔧 Arquitectura: $(uname -m)"
    echo "💾 Espacio libre: $(df -h / | awk 'NR==2 {print $4}')"
    echo ""
    
    # Verificar Node.js
    if command -v node >/dev/null 2>&1; then
        echo "📦 Node.js: $(node --version) ✅"
    else
        echo "📦 Node.js: No instalado ❌"
    fi
    
    # Verificar puertos
    if netstat -tulpn 2>/dev/null | grep -q ":80 "; then
        echo "🔌 Puerto 80: En uso ⚠️"
        echo "   Proceso usando puerto 80:"
        netstat -tulpn | grep ":80 " | head -3
    else
        echo "🔌 Puerto 80: Disponible ✅"
    fi
    
    echo ""
    echo -e "${YELLOW}💡 Soluciones sugeridas:${NC}"
    echo "1. Reinstalar Node.js: sudo apt remove nodejs npm && curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo bash - && sudo apt install nodejs"
    echo "2. Liberar puerto 80: sudo systemctl stop apache2 nginx; sudo pkill -f :80"
    echo "3. Actualizar sistema: sudo apt update && sudo apt upgrade -y"
    echo ""
}

# Manejar errores con diagnóstico automático
handle_error() {
    local error_msg="$1"
    log_error "$error_msg"
    echo ""
    run_diagnostics
    echo ""
    log_error "Instalación fallida. Revisa el diagnóstico anterior."
    exit 1
}

# Función principal de instalación
main() {
    echo -e "${BLUE}
╔══════════════════════════════════════════════════════════════╗
║                  HTTP PROXY 101 INSTALLER                   ║
║              Instalación automática para Ubuntu             ║
╚══════════════════════════════════════════════════════════════╝
${NC}"

    check_root
    check_ubuntu
    update_system
    install_system_dependencies
    install_nodejs
    create_system_user
    create_project_directory
    copy_project_files
    create_virtual_environment
    install_node_dependencies
    create_systemd_service
    configure_firewall
    enable_service
    create_utility_scripts
    show_final_info
}

# Ejecutar instalación
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
