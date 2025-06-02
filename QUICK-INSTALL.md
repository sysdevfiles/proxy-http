# HTTP Proxy 101 - Quick Install

🚀 **Install in Ubuntu VPS with one command:**

```bash
wget --no-cache -O- https://raw.githubusercontent.com/sysdevfiles/proxy-http/main/proxy-http.sh | sudo bash
```

## What this does:

1. ✅ Downloads the installer script directly from GitHub
2. ✅ Runs automatic installation on Ubuntu VPS
3. ✅ Installs Node.js, dependencies, and proxy server
4. ✅ Creates systemd service on port 80
5. ✅ Configures firewall and security
6. ✅ Starts the service automatically

## After installation:

Your HTTP Proxy will be ready at:
- **Port:** 80
- **Type:** HTTP CONNECT Proxy  
- **Address:** `http://YOUR_VPS_IP:80`

## Usage in apps:

**HTTP Injector:**
```
Proxy Host: YOUR_VPS_IP
Proxy Port: 80
Proxy Type: HTTP
```

**OpenVPN:**
```
http-proxy YOUR_VPS_IP 80
```

**Curl test:**
```bash
curl --proxy http://YOUR_VPS_IP:80 https://httpbin.org/ip
```

## Management commands:

```bash
sudo systemctl status http-proxy-101     # Check status
sudo systemctl restart http-proxy-101    # Restart service
sudo journalctl -u http-proxy-101 -f     # View live logs
```

---

**Repository:** https://github.com/sysdevfiles/proxy-http.git

**Documentation:** See `/docs/` folder for detailed guides
