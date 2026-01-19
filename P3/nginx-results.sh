#!/bin/bash

# Define o arquivo de log (mude se necessário)
LOG_FILE="nginx-access.log.txt"

# Verifica se o arquivo existe
if [ ! -f "$LOG_FILE" ]; then
    echo "Erro: O arquivo '$LOG_FILE' não foi encontrado."
    exit 1
fi

# --- 1. IPs ---
echo "Top 5 IP addresses with the most requests:"
awk '{print $1}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -n 5 | \
awk '{ print $2 " - " $1 " requests" }'

echo "" # Linha em branco para separar

# --- 2. Caminhos (Paths) ---
echo "Top 5 most requested paths:"
awk '{print $7}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -n 5 | \
awk '{ print $2 " - " $1 " requests" }'

echo ""

# --- 3. Status Codes ---
echo "Top 5 response status codes:"
awk '{print $9}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -n 5 | \
awk '{ print $2 " - " $1 " requests" }'

echo ""

# --- 4. User Agents (Bônus, caso precise) ---
echo "Top 5 user agents:"
awk -F\" '{print $6}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -n 5 | \
awk '{ print $2 " - " $1 " requests" }'