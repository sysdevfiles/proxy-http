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
NODE_VERSION="20"

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

# Ejecutar comando con logging básico
exec_command() {
    local command="$1"
    local description="$2"
    
    log_info "${description}..."
    
    if eval "$command" >> /var/log/http-proxy-101-install.log 2>&1; then
        log_success "${description} completado"
        return 0
    else
        log_error "${description} falló"
        echo "Ver logs: tail -f /var/log/http-proxy-101-install.log"
        return 1
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
        "git"
        "ufw"
        "htop"
        "netstat-nat"
        "lsof"
        "net-tools"
    )
    
    exec_command "apt install -y ${packages[*]}" "Instalando dependencias del sistema"
}

# Detectar y configurar Node.js automáticamente
detect_and_fix_nodejs() {
    log_info "Detectando y configurando Node.js..."
    
    # Buscar Node.js en ubicaciones comunes
    local node_paths=(
        "/usr/bin/node"
        "/snap/bin/node"
        "/usr/local/bin/node" 
        "/opt/node/bin/node"
        "$(which node 2>/dev/null || echo '')"
    )
    
    local working_node=""
    local best_version=0
    
    # Encontrar la mejor versión de Node.js disponible
    for path in "${node_paths[@]}"; do
        if [[ -n "$path" && -x "$path" ]]; then
            local version=$($path --version 2>/dev/null | sed 's/v\([0-9]*\).*/\1/' || echo "0")
            if [[ $version -ge 16 && $version -gt $best_version ]]; then
                working_node="$path"
                best_version=$version
            fi
        fi
    done
    
    if [[ -n "$working_node" ]]; then
        local node_version=$($working_node --version 2>/dev/null)
        log_success "Node.js encontrado: $node_version en $working_node"
        
        # Crear enlace simbólico automáticamente si es necesario
        if [[ "$working_node" != "/usr/bin/node" ]]; then
            log_info "Creando enlace simbólico automático..."
            ln -sf "$working_node" /usr/bin/node 2>/dev/null && \
                log_success "Enlace /usr/bin/node creado" || \
                log_warning "No se pudo crear enlace /usr/bin/node"
                
            # También para npm
            local npm_path=$(dirname "$working_node")/npm
            if [[ -x "$npm_path" ]]; then
                ln -sf "$npm_path" /usr/bin/npm 2>/dev/null && \
                    log_success "Enlace /usr/bin/npm creado" || \
                    log_warning "No se pudo crear enlace /usr/bin/npm"
            fi
        fi
        
        return 0
    fi
    
    return 1
}

# Instalar Node.js con múltiples métodos y auto-reparación
install_nodejs() {
    # Intentar detectar Node.js existente primero
    if detect_and_fix_nodejs; then
        return 0
    fi
    
    log_info "Instalando Node.js..."
    
    # Limpiar instalaciones problemáticas
    apt remove -y nodejs npm >/dev/null 2>&1 || true
    apt autoremove -y >/dev/null 2>&1 || true
    
    # Método 1: NodeSource (mejor opción)
    log_info "Método 1: NodeSource..."
    if curl -fsSL https://deb.nodesource.com/setup_20.x 2>/dev/null | bash - >/dev/null 2>&1; then
        if apt install -y nodejs >/dev/null 2>&1; then
            if detect_and_fix_nodejs; then
                log_success "Node.js instalado vía NodeSource"
                return 0
            fi
        fi
    fi
    
    # Método 2: Snap (fallback común en Ubuntu)
    log_info "Método 2: Snap..."
    if command -v snap >/dev/null 2>&1; then
        if snap install node --classic >/dev/null 2>&1; then
            sleep 2  # Esperar que snap termine
            if detect_and_fix_nodejs; then
                log_success "Node.js instalado vía Snap"
                return 0
            fi
        fi
    fi
    
    # Método 3: Repositorios Ubuntu (último recurso)
    log_info "Método 3: Repositorios Ubuntu..."
    if apt update >/dev/null 2>&1 && apt install -y nodejs npm >/dev/null 2>&1; then
        if detect_and_fix_nodejs; then
            log_success "Node.js instalado desde repositorios Ubuntu"
            return 0
        fi
    fi
    
    log_error "CRÍTICO: No se pudo instalar Node.js con ningún método"
    return 1
}

# Mostrar solución básica de problemas
show_basic_troubleshooting() {
    echo ""
    echo -e "${YELLOW}🔧 Auto-diagnóstico del sistema:${NC}"
    
    # Node.js
    echo -n "Node.js en /usr/bin/node: "
    if [[ -x "/usr/bin/node" ]]; then
        echo -e "${GREEN}✓ $(/usr/bin/node --version 2>/dev/null || echo 'Error')${NC}"
    else
        echo -e "${RED}✗ No encontrado${NC}"
    fi
    
    # Snap Node.js
    echo -n "Node.js en /snap/bin/node: "
    if [[ -x "/snap/bin/node" ]]; then
        echo -e "${GREEN}✓ $(/snap/bin/node --version 2>/dev/null || echo 'Error')${NC}"
    else
        echo -e "${YELLOW}⚠ No encontrado${NC}"
    fi
    
    # Servicio
    echo -n "Servicio $SERVICE_NAME: "
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        echo -e "${GREEN}✓ Activo${NC}"
    else
        echo -e "${RED}✗ Inactivo${NC}"
    fi
    
    # Puerto 80
    echo -n "Puerto 80: "
    if netstat -tuln 2>/dev/null | grep -q ":80 "; then
        echo -e "${GREEN}✓ En uso${NC}"
    else
        echo -e "${YELLOW}⚠ Libre${NC}"
    fi
    
    echo ""
    echo -e "${BLUE}Ver logs detallados: journalctl -u $SERVICE_NAME -n 20${NC}"
    echo ""
}

# Detectar y liberar puerto 80 automáticamente
check_and_free_port_80() {
    log_info "Verificando disponibilidad del puerto 80..."
    
    # Función auxiliar para verificar puerto
    port_in_use() {
        netstat -tuln 2>/dev/null | grep -q ":80 " || \
        ss -tuln 2>/dev/null | grep -q ":80 " || \
        lsof -i :80 >/dev/null 2>&1
    }
    
    # Verificar si el puerto 80 está en uso
    if port_in_use; then
        log_warning "Puerto 80 ocupado, liberando automáticamente..."
        
        # Identificar procesos usando el puerto 80 (múltiples métodos)
        local processes=""
        
        # Método 1: netstat
        if command -v netstat >/dev/null 2>&1; then
            processes+=" $(netstat -tulpn 2>/dev/null | grep ":80 " | awk '{print $7}' | cut -d'/' -f1 | sort -u | grep -v "^$")"
        fi
        
        # Método 2: ss
        if command -v ss >/dev/null 2>&1; then
            processes+=" $(ss -tulpn 2>/dev/null | grep ":80 " | awk '{print $7}' | cut -d',' -f2 | cut -d'=' -f2 | sort -u | grep -v "^$")"
        fi
        
        # Método 3: lsof
        if command -v lsof >/dev/null 2>&1; then
            processes+=" $(lsof -t -i :80 2>/dev/null | sort -u)"
        fi
        
        # Limpiar lista de procesos
        processes=$(echo "$processes" | tr ' ' '\n' | sort -u | grep -v "^$" | tr '\n' ' ')
        
        if [[ -n "$processes" ]]; then
            log_info "Procesos encontrados en puerto 80: $processes"
            
            # Paso 1: Detener servicios web comunes automáticamente
            local web_services=("apache2" "nginx" "httpd" "lighttpd" "caddy" "traefik")
            local stopped_services=""
            
            for service in "${web_services[@]}"; do
                if systemctl is-active --quiet "$service" 2>/dev/null; then
                    log_info "Deteniendo servicio: $service"
                    if systemctl stop "$service" >/dev/null 2>&1; then
                        log_success "Servicio $service detenido"
                        stopped_services+="$service "
                        
                        # Deshabilitar para evitar conflictos futuros
                        if systemctl disable "$service" >/dev/null 2>&1; then
                            log_success "Servicio $service deshabilitado permanentemente"
                        else
                            log_warning "No se pudo deshabilitar $service"
                        fi
                    else
                        log_warning "No se pudo detener $service"
                    fi
                fi
            done
            
            # Paso 2: Esperar y verificar
            if [[ -n "$stopped_services" ]]; then
                log_info "Esperando liberación del puerto..."
                sleep 3
            fi
            
            # Paso 3: Verificar procesos restantes y terminarlos
            if port_in_use; then
                log_warning "Puerto aún ocupado, terminando procesos restantes..."
                
                # Obtener PIDs actuales
                local current_pids=""
                if command -v lsof >/dev/null 2>&1; then
                    current_pids=$(lsof -t -i :80 2>/dev/null | sort -u | tr '\n' ' ')
                else
                    current_pids=$(netstat -tulpn 2>/dev/null | grep ":80 " | awk '{print $7}' | cut -d'/' -f1 | sort -u | grep -v "^$" | tr '\n' ' ')
                fi
                
                if [[ -n "$current_pids" ]]; then
                    # Primero SIGTERM
                    for pid in $current_pids; do
                        if [[ "$pid" =~ ^[0-9]+$ ]] && kill -0 "$pid" 2>/dev/null; then
                            log_info "Terminando proceso graciosamente: $pid"
                            kill -TERM "$pid" 2>/dev/null
                        fi
                    done
                    
                    # Esperar
                    sleep 3
                    
                    # Luego SIGKILL si es necesario
                    if port_in_use; then
                        current_pids=$(lsof -t -i :80 2>/dev/null | sort -u | tr '\n' ' ' || netstat -tulpn 2>/dev/null | grep ":80 " | awk '{print $7}' | cut -d'/' -f1 | sort -u | grep -v "^$" | tr '\n' ' ')
                        
                        if [[ -n "$current_pids" ]]; then
                            log_warning "Forzando cierre de procesos persistentes..."
                            for pid in $current_pids; do
                                if [[ "$pid" =~ ^[0-9]+$ ]] && kill -0 "$pid" 2>/dev/null; then
                                    log_info "Matando proceso: $pid"
                                    kill -9 "$pid" 2>/dev/null
                                fi
                            done
                            sleep 2
                        fi
                    fi
                fi
            fi
        fi
        
        # Verificación final con múltiples intentos
        local attempts=0
        local max_attempts=3
        
        while [[ $attempts -lt $max_attempts ]] && port_in_use; do
            attempts=$((attempts + 1))
            log_info "Intento $attempts/$max_attempts: Verificando puerto 80..."
            sleep 2
        done
        
        if port_in_use; then
            log_error "No se pudo liberar el puerto 80 completamente después de $max_attempts intentos"
            show_port_troubleshooting
            return 1
        else
            log_success "Puerto 80 liberado correctamente"
        fi
    else
        log_success "Puerto 80 disponible"
    fi
    
    return 0
}

# Mostrar información específica de problemas con puerto 80
show_port_troubleshooting() {
    echo ""
    echo -e "${YELLOW}🔧 Diagnóstico detallado del puerto 80:${NC}"
    echo ""
    
    # Verificar múltiples métodos de detección
    echo -e "${BLUE}1. Verificación con netstat:${NC}"
    local netstat_result=$(netstat -tulpn 2>/dev/null | grep ":80 ")
    if [[ -n "$netstat_result" ]]; then
        echo -e "${RED}Procesos encontrados:${NC}"
        echo "$netstat_result"
    else
        echo -e "${GREEN}No se encontraron procesos${NC}"
    fi
    
    echo ""
    echo -e "${BLUE}2. Verificación con ss:${NC}"
    if command -v ss >/dev/null 2>&1; then
        local ss_result=$(ss -tulpn 2>/dev/null | grep ":80 ")
        if [[ -n "$ss_result" ]]; then
            echo -e "${RED}Procesos encontrados:${NC}"
            echo "$ss_result"
        else
            echo -e "${GREEN}No se encontraron procesos${NC}"
        fi
    else
        echo -e "${YELLOW}ss no disponible${NC}"
    fi
    
    echo ""
    echo -e "${BLUE}3. Verificación con lsof:${NC}"
    if command -v lsof >/dev/null 2>&1; then
        local lsof_result=$(lsof -i :80 2>/dev/null)
        if [[ -n "$lsof_result" ]]; then
            echo -e "${RED}Procesos encontrados:${NC}"
            echo "$lsof_result"
        else
            echo -e "${GREEN}No se encontraron procesos${NC}"
        fi
    else
        echo -e "${YELLOW}lsof no disponible - instalando...${NC}"
        apt update >/dev/null 2>&1 && apt install -y lsof >/dev/null 2>&1
        if command -v lsof >/dev/null 2>&1; then
            local lsof_result=$(lsof -i :80 2>/dev/null)
            if [[ -n "$lsof_result" ]]; then
                echo -e "${RED}Procesos encontrados:${NC}"
                echo "$lsof_result"
            else
                echo -e "${GREEN}No se encontraron procesos${NC}"
            fi
        else
            echo -e "${RED}No se pudo instalar lsof${NC}"
        fi
    fi
    
    echo ""
    echo -e "${BLUE}4. Servicios web instalados:${NC}"
    local web_services=("apache2" "nginx" "httpd" "lighttpd" "caddy" "traefik")
    for service in "${web_services[@]}"; do
        if systemctl list-unit-files 2>/dev/null | grep -q "^${service}\.service"; then
            local status=$(systemctl is-active "$service" 2>/dev/null || echo "inactive")
            local enabled=$(systemctl is-enabled "$service" 2>/dev/null || echo "disabled")
            
            if [[ "$status" == "active" ]]; then
                echo -e "  $service: ${RED}$status${NC} (${enabled})"
            else
                echo -e "  $service: ${GREEN}$status${NC} (${enabled})"
            fi
        fi
    done
    
    echo ""
    echo -e "${BLUE}5. Comandos de reparación manual:${NC}"
    echo -e "${YELLOW}# Verificar procesos:${NC}"
    echo "sudo netstat -tulpn | grep :80"
    echo "sudo ss -tulpn | grep :80"
    echo "sudo lsof -i :80"
    echo ""
    echo -e "${YELLOW}# Detener servicios web:${NC}"
    echo "sudo systemctl stop apache2 nginx httpd lighttpd"
    echo "sudo systemctl disable apache2 nginx httpd lighttpd"
    echo ""
    echo -e "${YELLOW}# Matar procesos específicos:${NC}"
    echo "sudo pkill -f ':80'"
    echo "sudo kill -9 \$(sudo lsof -t -i :80)"
    echo ""
    echo -e "${YELLOW}# Re-ejecutar instalador:${NC}"
    echo "curl -fsSL https://raw.githubusercontent.com/tu-usuario/http-proxy-101/main/proxy-http.sh | sudo bash"
    echo ""
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
    log_info "Instalando archivos del proyecto..."
    
    # Crear estructura de directorios
    mkdir -p "$PROJECT_DIR/src"
    mkdir -p "$PROJECT_DIR/config" 
    mkdir -p "$PROJECT_DIR/scripts"
    mkdir -p "$PROJECT_DIR/test"
    
    log_info "Creando package.json..."
    cat > "$PROJECT_DIR/package.json" << 'EOF'
{
  "name": "http-proxy-101",
  "version": "1.0.0",
  "description": "Servidor proxy HTTP que responde con código 101 para bypass de restricciones de red",
  "main": "src/server.js",
  "scripts": {
    "start": "node src/server.js",
    "dev": "nodemon src/server.js",
    "test": "node test/test-proxy.js"
  },
  "keywords": [
    "proxy",
    "http", 
    "bypass",
    "tunnel",
    "101",
    "ssl",
    "https",
    "http-injector",
    "vpn"
  ],
  "author": "HTTP Proxy 101",
  "license": "MIT",
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "helmet": "^7.1.0",
    "compression": "^1.7.4"
  },
  "devDependencies": {
    "nodemon": "^3.0.2"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
EOF

    log_info "Creando server.js..."
    cat > "$PROJECT_DIR/src/server.js" << 'EOF'
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');

const app = express();
const PORT = process.env.PORT || 80;
const HOST = process.env.HOST || '0.0.0.0';

// Middleware de seguridad y optimización
app.use(helmet({
    contentSecurityPolicy: false,
    crossOriginEmbedderPolicy: false
}));
app.use(cors());
app.use(compression());
app.use(express.json({ limit: '10mb' }));

// Ruta principal - Responder con HTTP 101
app.all('*', (req, res) => {
    // Headers para HTTP 101 Switching Protocols
    res.status(101);
    res.set({
        'Connection': 'Upgrade',
        'Upgrade': 'websocket',
        'Sec-WebSocket-Accept': 'dummy',
        'Sec-WebSocket-Protocol': 'chat',
        'Cache-Control': 'no-cache',
        'Pragma': 'no-cache'
    });
    
    // Log de la petición
    const timestamp = new Date().toISOString();
    console.log(`${timestamp} - ${req.method} ${req.url} - ${req.ip}`);
    
    // Respuesta con código 101
    res.end('HTTP/1.1 101 Switching Protocols\r\n\r\n');
});

// Iniciar servidor
const server = app.listen(PORT, HOST, () => {
    console.log(`🚀 HTTP Proxy 101 iniciado en ${HOST}:${PORT}`);
    console.log(`💾 PID: ${process.pid}`);
});

// Manejo de señales para cierre graceful
process.on('SIGTERM', () => {
    console.log('🔄 Cerrando servidor...');
    server.close(() => {
        console.log('✅ Servidor cerrado');
        process.exit(0);
    });
});
EOF

    log_info "Creando config.json..."
    cat > "$PROJECT_DIR/config/config.json" << 'EOF'
{
    "port": 80,
    "host": "0.0.0.0",
    "timeout": 30000,
    "maxConnections": 1000
}
EOF

    # Configurar permisos
    chown -R $USER:$USER "$PROJECT_DIR"
    
    log_success "Archivos del proyecto creados correctamente"
    
    # Verificar que package.json existe
    if [[ -f "$PROJECT_DIR/package.json" ]]; then
        log_success "package.json verificado en $PROJECT_DIR"
    else
        log_error "package.json no se creó correctamente"
        return 1
    fi
}

# Instalar dependencias Node.js
install_node_dependencies() {
    log_info "Instalando dependencias Node.js..."
    
    cd "$PROJECT_DIR"
    
    # Verificar que package.json existe
    if [[ ! -f "package.json" ]]; then
        log_error "package.json no encontrado en $PROJECT_DIR"
        return 1
    fi
    
    # Función para ejecutar npm con timeout
    run_npm_with_timeout() {
        local cmd="$1"
        local timeout_seconds=300  # 5 minutos máximo
        
        log_info "Ejecutando: $cmd (timeout: ${timeout_seconds}s)"
        
        # Ejecutar con timeout
        if timeout "$timeout_seconds" bash -c "$cmd"; then
            return 0
        else
            local exit_code=$?
            if [[ $exit_code -eq 124 ]]; then
                log_error "Comando npm excedió timeout de ${timeout_seconds} segundos"
            else
                log_error "Comando npm falló con código: $exit_code"
            fi
            return 1
        fi
    }
    
    # Detectar y solucionar problemas de Snap Node.js
    fix_snap_nodejs_issues() {
        local nodejs_path=$(which node 2>/dev/null || which nodejs 2>/dev/null)
        
        if [[ "$nodejs_path" == *"snap"* ]]; then
            log_warning "Node.js detectado vía Snap, configurando npm para evitar conflictos..."
            
            # Crear directorio npm global seguro
            local npm_global_dir="$PROJECT_DIR/.npm-global"
            sudo -u $USER mkdir -p "$npm_global_dir"
            
            # Configurar npm para usar directorio alternativo
            sudo -u $USER npm config set prefix "$npm_global_dir"
            sudo -u $USER npm config set cache "$PROJECT_DIR/.npm-cache"
            sudo -u $USER npm config set tmp "$PROJECT_DIR/.npm-tmp"
            
            # Limpiar configuraciones problemáticas
            sudo -u $USER npm config delete userconfig 2>/dev/null || true
            sudo -u $USER npm config delete globalconfig 2>/dev/null || true
            
            # Crear directorios necesarios
            sudo -u $USER mkdir -p "$PROJECT_DIR/.npm-cache"
            sudo -u $USER mkdir -p "$PROJECT_DIR/.npm-tmp"
            
            log_success "Configuración npm para Snap completada"
            return 0
        fi
        return 1
    }
    
    # Aplicar correcciones si es necesario
    fix_snap_nodejs_issues
    
    # Limpiar caché npm y node_modules previos
    log_info "Limpiando instalación previa..."
    sudo -u $USER rm -rf node_modules package-lock.json 2>/dev/null || true
    
    # Limpiar cache npm de forma segura
    log_info "Limpiando cache npm..."
    if ! sudo -u $USER npm cache clean --force 2>/dev/null; then
        log_warning "No se pudo limpiar cache npm, continuando..."
    fi
    
    # Configurar npm
    sudo -u $USER npm config set registry https://registry.npmjs.org/
    
    # Método 1: Instalación estándar con timeout
    log_info "Método 1: Instalación estándar de dependencias..."
    if run_npm_with_timeout "sudo -u $USER npm install --production --no-optional --no-audit --no-fund"; then
        log_success "Dependencias Node.js instaladas correctamente"
        return 0
    fi
    
    # Método 2: Sin cache para evitar problemas de Snap
    log_warning "Método 1 falló, intentando sin cache..."
    if run_npm_with_timeout "sudo -u $USER npm install --production --no-optional --no-audit --no-fund --cache-min 0"; then
        log_success "Dependencias instaladas sin cache"
        return 0
    fi
    
    # Método 3: Instalación manual una por una con timeout
    log_warning "Método 2 falló, instalando dependencias una por una..."
    local packages=("express" "cors" "helmet" "compression")
    local all_success=true
    
    for package in "${packages[@]}"; do
        log_info "Instalando $package individualmente..."
        if run_npm_with_timeout "sudo -u $USER npm install $package --production --no-optional --no-audit --no-fund"; then
            log_success "$package instalado correctamente"
        else
            log_error "Error instalando $package"
            all_success=false
        fi
    done
    
    if $all_success; then
        log_success "Todas las dependencias instaladas individualmente"
        return 0
    fi
    
    # Método 4: Último recurso - usar Node.js de sistema sin Snap
    log_error "Todos los métodos npm fallaron"
    log_info "Método 4: Intentando reinstalar Node.js sin Snap..."
    
    # Remover Snap Node.js problemático
    if command -v snap >/dev/null 2>&1 && snap list 2>/dev/null | grep -q "node"; then
        log_info "Removiendo Node.js de Snap..."
        snap remove node >/dev/null 2>&1 || true
        sleep 2
    fi
    
    # Limpiar instalaciones previas
    apt remove -y nodejs npm >/dev/null 2>&1 || true
    apt autoremove -y >/dev/null 2>&1 || true
    
    # Instalar Node.js desde NodeSource
    log_info "Instalando Node.js desde NodeSource..."
    if curl -fsSL https://deb.nodesource.com/setup_20.x | bash - >/dev/null 2>&1; then
        if apt install -y nodejs >/dev/null 2>&1; then
            # Verificar nueva instalación
            if detect_and_fix_nodejs; then
                log_success "Node.js reinstalado exitosamente"
                # Reintentar instalación de dependencias
                cd "$PROJECT_DIR"
                if run_npm_with_timeout "sudo -u $USER npm install --production --no-optional --no-audit --no-fund"; then
                    log_success "Dependencias instaladas después de reinstalar Node.js"
                    return 0
                fi
            fi
        fi
    fi
    
    # Método 5: Fallback con servidor básico sin dependencias
    log_warning "Método 4 falló, creando servidor básico..."
    
    # Crear node_modules básico manualmente
    sudo -u $USER mkdir -p node_modules
    
    # Verificar si al menos Node.js está disponible para servidor básico
    if command -v node >/dev/null 2>&1; then
        log_warning "Creando servidor básico alternativo..."
        create_fallback_server
        
        # Modificar el servicio systemd para usar server-basic.js
        if [[ -f "/etc/systemd/system/http-proxy-101.service" ]]; then
            sed -i 's|src/server.js|src/server-basic.js|g' /etc/systemd/system/http-proxy-101.service 2>/dev/null || true
        fi
        
        log_warning "Servidor configurado en modo básico (sin dependencias externas)"
        log_warning "Funcionalidad limitada pero operacional"
        return 0
    fi
    
    log_error "CRÍTICO: No se pudieron instalar las dependencias Node.js"
    log_error "El servidor proxy podría no funcionar correctamente"
    return 1
}

# Verificar y auto-reparar instalación completa
verify_and_fix_installation() {
    log_info "Verificando instalación completa..."
    
    # Verificar Node.js
    if ! /usr/bin/node --version >/dev/null 2>&1; then
        log_warning "Node.js no funciona, intentando auto-reparación..."
        if ! detect_and_fix_nodejs; then
            log_error "No se pudo reparar Node.js automáticamente"
            return 1
        fi
    fi
    
    # Verificar archivos del proyecto
    if [[ ! -f "$PROJECT_DIR/src/server.js" ]]; then
        log_error "Archivo principal del servidor no encontrado"
        return 1
    fi
    
    # Verificar dependencias npm
    if [[ ! -d "$PROJECT_DIR/node_modules" ]]; then
        log_info "Instalando dependencias faltantes..."
        cd "$PROJECT_DIR"
        if ! sudo -u "$USER" npm install --production >/dev/null 2>&1; then
            log_warning "Error instalando dependencias npm"
        fi
    fi
    
    # Verificar servicio
    if ! systemctl is-enabled "$SERVICE_NAME" >/dev/null 2>&1; then
        log_info "Habilitando servicio..."
        systemctl enable "$SERVICE_NAME" >/dev/null 2>&1
    fi
    
    local node_version=$(/usr/bin/node --version 2>/dev/null || echo "Error")
    log_success "Verificación completada - Node.js: $node_version"
    return 0
}



# Crear archivo de servicio systemd
create_systemd_service() {
    # Detectar la ruta de Node.js para el servicio
    local node_exec_path="/usr/bin/node"
    
    # Verificar que Node.js esté disponible
    if [[ ! -x "$node_exec_path" ]]; then
        log_error "Node.js no encontrado en $node_exec_path"
        exit 1
    fi
    
    log_info "Creando servicio systemd con Node.js en: $node_exec_path"
    
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
Environment=PATH=/usr/bin:/usr/local/bin:/snap/bin
ExecStart=$node_exec_path $PROJECT_DIR/src/server.js
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

# Habilitar y iniciar servicio con verificación automática
enable_service() {
    exec_command "systemctl daemon-reload" "Recargando systemd"
    exec_command "systemctl enable $SERVICE_NAME" "Habilitando servicio"
    
    # Intentar iniciar el servicio
    log_info "Iniciando servicio..."
    if systemctl start "$SERVICE_NAME" 2>/dev/null; then
        sleep 3
        if systemctl is-active --quiet "$SERVICE_NAME"; then
            log_success "Servicio iniciado correctamente"
            return 0
        fi
    fi
    
    # Si falla, intentar auto-reparación
    log_warning "Servicio falló al iniciar, intentando auto-reparación..."
    
    if verify_and_fix_installation; then
        log_info "Reintentando inicio del servicio..."
        systemctl start "$SERVICE_NAME" 2>/dev/null
        sleep 3
        
        if systemctl is-active --quiet "$SERVICE_NAME"; then
            log_success "Servicio reparado e iniciado"
        else
            log_error "Servicio sigue fallando después de reparación"
            show_basic_troubleshooting
        fi
    else
        log_error "No se pudo reparar automáticamente"
        show_basic_troubleshooting
    fi
}

# Crear scripts de utilidad simplificados
create_utility_scripts() {
    local scripts_dir="$PROJECT_DIR/scripts"
    mkdir -p "$scripts_dir"
    
    # Script de estado simple
    cat > "$scripts_dir/status.sh" << 'EOF'
#!/bin/bash
echo "=== HTTP Proxy 101 Status ==="
systemctl status http-proxy-101 --no-pager
echo ""
echo "=== Últimos logs ==="
journalctl -u http-proxy-101 -n 10 --no-pager
EOF

    # Script de reinicio con auto-reparación
    cat > "$scripts_dir/restart.sh" << 'EOF'
#!/bin/bash
echo "Reiniciando HTTP Proxy 101..."

# Verificar Node.js
if [[ ! -x "/usr/bin/node" ]] && [[ -x "/snap/bin/node" ]]; then
    echo "Reparando enlace Node.js..."
    sudo ln -sf /snap/bin/node /usr/bin/node
fi

systemctl restart http-proxy-101
sleep 2
systemctl status http-proxy-101 --no-pager
EOF

    # Copiar script de test si existe en el workspace
    if [[ -f "scripts/test-installation.sh" ]]; then
        cp "scripts/test-installation.sh" "$scripts_dir/"
        chmod +x "$scripts_dir/test-installation.sh"
        log_success "Script de test copiado"
    fi

    chmod +x "$scripts_dir"/*.sh
    chown -R "$USER:$USER" "$scripts_dir"
    log_success "Scripts de utilidad creados"
}

# Mostrar información de logs y solución de errores
show_error_help() {
    local error_step="$1"
    
    echo -e "${YELLOW}
╔══════════════════════════════════════════════════════════════╗
║                    ❌ ERROR EN INSTALACIÓN                   ║
╚══════════════════════════════════════════════════════════════╝${NC}"
    
    echo ""
    log_error "Error en: $error_step"
    echo ""
    echo -e "${YELLOW}🔍 Para diagnosticar el problema:${NC}"
    echo "  journalctl -n 50 | grep -i error"
    echo "  systemctl status $SERVICE_NAME"
    echo ""
    echo -e "${YELLOW}💡 Soluciones comunes:${NC}"
    case "$error_step" in
        *"Node.js"*)
            echo "  1. sudo apt remove nodejs npm"
            echo "  2. sudo apt update && sudo apt install nodejs npm"
            echo "  3. node --version (verificar)"
            ;;
        *"puerto"*)
            echo "  1. sudo netstat -tulpn | grep :80"
            echo "  2. sudo systemctl stop apache2 nginx"
            echo "  3. sudo pkill -f :80"
            ;;
        *)
            echo "  1. sudo apt update && sudo apt upgrade"
            echo "  2. Verificar logs: journalctl -u $SERVICE_NAME -f"
            echo "  3. Reintentar instalación"
            ;;
    esac
    echo ""
    echo -e "${YELLOW}📋 Logs útiles:${NC}"
    echo "  • Ver estado: systemctl status $SERVICE_NAME"
    echo "  • Ver logs: journalctl -u $SERVICE_NAME -f"
    echo "  • Errores sistema: journalctl -p err -n 10"
    echo ""
}

# Mostrar información final
show_final_info() {
    local node_version=$(/usr/bin/node --version 2>/dev/null || echo "Error")
    local service_status="Inactivo"
    
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        service_status="✅ Activo"
    else
        service_status="❌ Inactivo"
    fi
    
    echo -e "${GREEN}
╔══════════════════════════════════════════════════════════════╗
║                    🚀 INSTALACIÓN COMPLETADA                 ║
╚══════════════════════════════════════════════════════════════╝${NC}

📋 Estado del sistema:
   • Servicio: $service_status
   • Node.js: $node_version
   • Puerto: 80 (HTTP)

🌐 Configurar en HTTP Injector:
   • Host: $(curl -s ifconfig.me 2>/dev/null || echo "TU_IP_VPS")
   • Port: 80
   • Type: HTTP

🔧 Comandos útiles:
   • Estado: systemctl status $SERVICE_NAME
   • Logs: journalctl -u $SERVICE_NAME -f
   • Reiniciar: systemctl restart $SERVICE_NAME

${GREEN}✅ Proxy HTTP 101 listo para usar!${NC}
"

    # Test rápido automático
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        echo -e "${BLUE}🧪 Realizando test automático...${NC}"
        
        # Test básico de respuesta
        local test_result=$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 http://localhost:80/ 2>/dev/null)
        
        if [[ "$test_result" == "101" ]]; then
            echo -e "${GREEN}✅ Test exitoso - Proxy respondiendo con código 101${NC}"
        else
            echo -e "${YELLOW}⚠️ Test básico: código $test_result (esperado: 101)${NC}"
        fi
        
        # Ofrecer test completo
        echo ""
        echo -e "${BLUE}Para ejecutar test completo de la instalación:${NC}"
        echo "bash ${PROJECT_DIR}/scripts/test-installation.sh"
    fi
}

# Crear servidor básico alternativo sin dependencias externas
create_fallback_server() {
    log_info "Creando servidor básico alternativo sin dependencias externas..."
    
    cat > "$PROJECT_DIR/src/server-basic.js" << 'EOF'
const http = require('http');
const url = require('url');

// Configuración básica
const PORT = process.env.PORT || 80;
const HOST = process.env.HOST || '0.0.0.0';

// Función para agregar headers CORS básicos
function addCorsHeaders(res) {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS, CONNECT');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With');
    res.setHeader('Access-Control-Max-Age', '86400');
}

// Función para agregar headers de seguridad básicos
function addSecurityHeaders(res) {
    res.setHeader('X-Content-Type-Options', 'nosniff');
    res.setHeader('X-Frame-Options', 'DENY');
    res.setHeader('X-XSS-Protection', '1; mode=block');
}

// Crear servidor HTTP
const server = http.createServer((req, res) => {
    const parsedUrl = url.parse(req.url, true);
    const method = req.method;
    
    // Agregar headers
    addCorsHeaders(res);
    addSecurityHeaders(res);
    
    // Log de conexión
    console.log(`${new Date().toISOString()} - ${method} ${req.url} - ${req.connection.remoteAddress}`);
    
    try {
        // Responder según el método
        if (method === 'OPTIONS') {
            // Preflight CORS
            res.writeHead(200);
            res.end();
        } else if (method === 'CONNECT') {
            // HTTP CONNECT para proxy
            res.writeHead(101, 'Switching Protocols', {
                'Connection': 'Upgrade',
                'Upgrade': 'TCP'
            });
            res.end();
        } else {
            // Respuesta estándar HTTP 101
            res.writeHead(101, 'Switching Protocols', {
                'Connection': 'Upgrade',
                'Upgrade': 'websocket',
                'Content-Type': 'text/plain'
            });
            res.end('HTTP/1.1 101 Switching Protocols\r\n\r\n');
        }
    } catch (error) {
        console.error('Error manejando petición:', error);
        res.writeHead(500, { 'Content-Type': 'text/plain' });
        res.end('Internal Server Error');
    }
});

// Manejar errores del servidor
server.on('error', (error) => {
    console.error('Error del servidor:', error);
    if (error.code === 'EADDRINUSE') {
        console.error(`Puerto ${PORT} ya está en uso`);
        process.exit(1);
    }
});

// Manejar cierre graceful
process.on('SIGTERM', () => {
    console.log('Recibida señal SIGTERM, cerrando servidor...');
    server.close(() => {
        console.log('Servidor cerrado correctamente');
        process.exit(0);
    });
});

process.on('SIGINT', () => {
    console.log('Recibida señal SIGINT, cerrando servidor...');
    server.close(() => {
        console.log('Servidor cerrado correctamente');
        process.exit(0);
    });
});

// Iniciar servidor
server.listen(PORT, HOST, () => {
    console.log(`🚀 Servidor HTTP Proxy 101 (modo básico) ejecutándose en http://${HOST}:${PORT}`);
    console.log(`📅 Iniciado: ${new Date().toISOString()}`);
    console.log(`🔧 Modo: Básico (sin dependencias externas)`);
    console.log(`💡 Responde con HTTP 101 - Switching Protocols`);
});
EOF

    # Cambiar propietario
    chown -R $USER:$USER "$PROJECT_DIR/src/server-basic.js"
    chmod 644 "$PROJECT_DIR/src/server-basic.js"
    
    log_success "Servidor básico alternativo creado en src/server-basic.js"
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
    check_and_free_port_80  # Liberar puerto 80 automáticamente
    install_nodejs
    create_system_user
    create_project_directory
    copy_project_files
    install_node_dependencies
    create_systemd_service
    configure_firewall
    enable_service
    create_utility_scripts
    create_fallback_server  # Crear servidor básico alternativo
    
    # Verificación final automática
    if verify_and_fix_installation; then
        show_final_info
    else
        log_error "Instalación completada con errores"
        show_basic_troubleshooting
    fi
}

# Ejecutar instalación
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
