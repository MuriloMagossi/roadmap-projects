#!/bin/bash

# ==========================================
# CONFIGURAÇÕES PADRÃO
# ==========================================
DEFAULT_LOG_DAYS=7       # Arquivar logs mais velhos que X dias
DEFAULT_BACKUP_DAYS=30   # Apagar backups mais velhos que Y dias
LOG_FILE="./archive_history.log"

# ==========================================
# FUNÇÃO CORE: O MOTOR DO ARQUIVAMENTO
# ==========================================
run_archiving() {
    local target_dir=$1
    local days_log=$2
    local days_backup=$3

    # Validações básicas
    if [ -z "$target_dir" ] || [ ! -d "$target_dir" ]; then
        echo "Erro: Diretório '$target_dir' inválido."
        return 1
    fi

    echo ">>> Iniciando processo para: $target_dir"
    
    # Define local de destino (cria pasta 'archives' dentro do diretório alvo)
    local archive_dest="$target_dir/archives"
    mkdir -p "$archive_dest"

    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local archive_name="logs_archive_${timestamp}.tar.gz"
    local full_path="$archive_dest/$archive_name"

    # 1. Compactação Inteligente
    # Encontra arquivos (> dias), usa print0 para lidar com espaços no nome, e envia pro tar
    # O '--no-recursion' evita que ele tente arquivar a própria pasta de archives se ela estiver dentro
    echo "Compactando logs com mais de $days_log dias..."
    
    find "$target_dir" -maxdepth 1 -type f -mtime +$days_log -print0 | \
        tar -czvf "$full_path" --null -T - --no-recursion

    # Verifica se o TAR criou o arquivo (se não tinha logs velhos, o arquivo pode ficar vazio ou dar erro)
    if [ -f "$full_path" ]; then
        echo "Arquivo criado: $archive_name"
        
        # 2. Log da operação
        echo "[$(date)] Arquivado: $archive_name | Origem: $target_dir" >> "$LOG_FILE"

        # 3. Limpeza dos Logs Originais (Perigoso, por isso verificamos se o tar existe antes)
        echo "Removendo logs originais antigos..."
        find "$target_dir" -maxdepth 1 -type f -mtime +$days_log -delete

        # 4. Rotação dos Backups (Apaga .tar.gz muito antigos)
        echo "Verificando backups expirados (mais de $days_backup dias)..."
        find "$archive_dest" -type f -name "*.tar.gz" -mtime +$days_backup -delete
        
        echo ">>> Processo concluído com sucesso!"
    else
        echo "Aviso: Nenhum log antigo encontrado para arquivar ou erro na compactação."
        # Remove arquivo vazio se foi criado
        [ -f "$full_path" ] && rm "$full_path"
    fi
}

# ==========================================
# LÓGICA DE EXECUÇÃO (CLI vs INTERATIVO)
# ==========================================

# Se o usuário passar o diretório como argumento (Modo Automático/Cron)
# Ex: ./smart-archive.sh /var/log/myapp
if [ ! -z "$1" ]; then
    echo "Modo Automático Detectado."
    # Executa usando os padrões definidos no topo
    run_archiving "$1" "$DEFAULT_LOG_DAYS" "$DEFAULT_BACKUP_DAYS"
    exit 0
fi

# Se não houver argumentos, entra no Modo Interativo (Menu)
while true; do
    clear
    echo "=== GERENCIADOR DE LOGS AVANÇADO ==="
    echo "1. Configurar e Rodar Arquivamento"
    echo "2. Instalar no Cron (Agendamento Automático)"
    echo "3. Sair"
    echo ""
    read -p "Escolha uma opção: " option

    case $option in
        1)
            read -p "Diretório dos Logs (Ex: /var/log): " input_dir
            read -p "Arquivar logs com mais de quantos dias? [Padrao: 7]: " input_days
            input_days=${input_days:-7} # Se vazio, usa 7
            
            read -p "Manter backups por quantos dias? [Padrao: 30]: " input_backups
            input_backups=${input_backups:-30}

            run_archiving "$input_dir" "$input_days" "$input_backups"
            read -p "Pressione Enter para voltar..."
            ;;
        2)
            read -p "Qual diretório deve ser monitorado diariamente? " cron_dir
            if [ -d "$cron_dir" ]; then
                # Pega o caminho absoluto do script
                SCRIPT_PATH=$(realpath "$0")
                # Cria a linha do cron para rodar as 03:00 am
                CRON_CMD="0 3 * * * $SCRIPT_PATH $cron_dir"
                
                # Adiciona ao crontab atual
                (crontab -l 2>/dev/null; echo "$CRON_CMD") | crontab -
                echo "Agendado com sucesso para as 03:00am!"
                echo "Comando adicionado: $CRON_CMD"
            else
                echo "Diretório inválido."
            fi
            read -p "Pressione Enter para voltar..."
            ;;
        3)
            echo "Saindo..."
            exit 0
            ;;
        *)
            echo "Opção inválida."
            sleep 1
            ;;
    esac
done