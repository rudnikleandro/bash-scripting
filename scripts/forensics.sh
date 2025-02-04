#!/bin/bash

OUT_DIR="/tmp/forensics_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUT_DIR"

if [ "$EUID" -ne 0 ]; then
    echo "Necessário permissões de administrador!" 
    exit 1
fi

echo "Extraindo informações do sistema..."
echo "Data e hora: $(date)" > "$OUT_DIR/system_info.txt"
who -a >> "$OUT_DIR/system_info.txt"
uptime >> "$OUT_DIR/system_info.txt"
hostnamectl >> "$OUT_DIR/system_info.txt"
df -h >> "$OUT_DIR/disk_usage.txt"
free -m >> "$OUT_DIR/memory.txt"

echo "Extraindo processos em execução..."
ps aux --forest > "$OUT_DIR/processes.txt"

echo "Extraindo dados de conexões..."
ss -tulpan > "$OUT_DIR/network_connections.txt"

echo "Extraindo informações de usuários..."
cat /etc/passwd > "$OUT_DIR/users.txt"
cat /etc/group > "$OUT_DIR/groups.txt"

echo "Extraindo histórico de comandos..."
cat /root/.bash_history > "$OUT_DIR/root_history.txt" 2>/dev/null
for user in $(ls /home/); do
    cat "/home/$user/.bash_history" > "$OUT_DIR/${user}_history.txt" 2>/dev/null
done

echo "Extraindo informações de arquivos recentes..."
find / -type f -mtime -3 -exec ls -lah {} + 2>/dev/null > "$OUT_DIR/recent_files.txt"

echo "Verificando arquivos suspeitos..."
find / -type f -perm -4000 2>/dev/null > "$OUT_DIR/suid_files.txt"
find / -type f -name "*.sh" -o -name "*.py" -o -name "*.php" -o -name "*.exe" -o -name "*.bat" 2>/dev/null > "$OUT_DIR/suspicious_files.txt"

echo "Compilando informações..."
tar -czf "$OUT_DIR.tar.gz" -C "/tmp" "$(basename $OUT_DIR)"
rm -rf "$OUT_DIR"

echo "Extração completa! Arquivo salvo em: $OUT_DIR.tar.gz"
