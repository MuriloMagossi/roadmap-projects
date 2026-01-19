# top -bn1 | grep "Cpu(s)" #comando para ver uso total da cpu

# mpstat 1 1 #comando para ver uso total da CPU (necessário 'sudo apt install sysstat')
# vmstat 1 2 | tail -1 | awk '{printf "CPU Total: 100%% | Usado: %.1f%% | Livre: %.1f%%\n", 100-$15, $15}'

# free -h #memoria RAM uso e livre
# free -m | awk 'NR==2{printf "Total: %s MB | Usado: %s MB (%.2f%%) | Livre: %s MB (%.2f%%)\n", $2, $3, $3*100/$2, $4, $4*100/$2 }'

# df -h --total | tail -1 #para disco, saida simples
# df --total -h | tail -1 | awk '{printf "Disco Total: %s | Usado: %s (%s) | Livre: %s\n", $2, $3, $5, $4}'

# ps -eo pid,%cpu,comm --sort=-%cpu | head -n 6 #5 procesos que mais estão usando CPU
# ps -eo pid,%mem,comm --sort=-%cpu | head -n 6 #5 procesos que mais estão usando RAM

echo "========================================================"
echo "               RELATÓRIO DE SAÚDE DO SERVIDOR           "
echo "========================================================"

# --- TOTAIS ---
echo ">>> VISÃO GERAL"
vmstat 1 2 | tail -1 | awk '{printf "CPU   : Total: 100%%    | Usado: %.1f%%       | Livre: %.1f%%\n", 100-$15, $15}'
free -m | awk 'NR==2{printf "RAM   : Total: %s MB | Usado: %s MB (%.0f%%) | Livre: %s MB\n", $2, $3, $3*100/$2, $4}'
df -h --total | tail -1 | awk '{printf "Disco : Total: %s    | Usado: %s (%s)    | Livre: %s\n", $2, $3, $5, $4}'
echo "--------------------------------------------------------"

# --- TOP CPU ---
echo ">>> TOP 5 PROCESSOS (CPU CONSUMPTION)"
ps -eo pid,%cpu,%mem,comm --sort=-%cpu | head -n 6
echo "--------------------------------------------------------"

# --- TOP MEM ---
echo ">>> TOP 5 PROCESSOS (MEMORY CONSUMPTION)"
ps -eo pid,%mem,%cpu,comm --sort=-%mem | head -n 6
echo "========================================================"

