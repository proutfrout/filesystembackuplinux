#!/bin/bash
# ============================================================
#  rsyncSSH.sh — Sauvegarde rsync vers serveur distant
#  Usage : ./rsyncSSH.sh
# ============================================================

# ---------- CONFIGURATION (à adapter) -----------------------
BACKUP_USER="backup"                        # User SSH sur le serveur distant
BACKUP_HOST="192.168.1.100"                 # IP ou hostname du serveur de backup
BACKUP_PORT="22"                            # Port SSH
BACKUP_DEST="/backups/$(hostname)"          # Dossier de destination sur le serveur
SSH_KEY="/root/.ssh/id_rsa"                 # Clé SSH privée
LOG_FILE="/var/log/backup.log"              # Fichier de log local
# ------------------------------------------------------------

# Dossiers à sauvegarder
SOURCES=(
    "/etc"
    "/home"
    "/root"
    "/var/lib"
    "/var/www"
    "/var/spool/cron"
    "/opt"
    "/srv"
)

# Dossiers à exclure dans /var/lib (trop lourds ou inutiles)
EXCLUDES=(
    "--exclude=/var/lib/apt"
    "--exclude=/var/lib/dpkg/info"
    "--exclude=/var/lib/systemd"
    "--exclude=/var/lib/udev"
)

# ============================================================

DATE=$(date '+%Y-%m-%d %H:%M:%S')
echo "[$DATE] ====== Début de la sauvegarde ======" | tee -a "$LOG_FILE"

ERRORS=0

for SRC in "${SOURCES[@]}"; do

    # Vérifie que le dossier existe
    if [ ! -d "$SRC" ]; then
        echo "[SKIP] $SRC n'existe pas, ignoré." | tee -a "$LOG_FILE"
        continue
    fi

    echo "[INFO] Sauvegarde de $SRC ..." | tee -a "$LOG_FILE"

    rsync -avz --delete \
        "${EXCLUDES[@]}" \
        -e "ssh -p $BACKUP_PORT -i $SSH_KEY -o StrictHostKeyChecking=accept-new" \
        "$SRC" \
        "$BACKUP_USER@$BACKUP_HOST:$BACKUP_DEST/" \
        >> "$LOG_FILE" 2>&1

    if [ $? -eq 0 ]; then
        echo "[OK]   $SRC sauvegardé avec succès." | tee -a "$LOG_FILE"
    else
        echo "[ERR]  Erreur lors de la sauvegarde de $SRC !" | tee -a "$LOG_FILE"
        ERRORS=$((ERRORS + 1))
    fi

done

DATE=$(date '+%Y-%m-%d %H:%M:%S')
if [ $ERRORS -eq 0 ]; then
    echo "[$DATE] ====== Sauvegarde terminée avec succès ======" | tee -a "$LOG_FILE"
else
    echo "[$DATE] ====== Sauvegarde terminée avec $ERRORS erreur(s) ======" | tee -a "$LOG_FILE"
    exit 1
fi
