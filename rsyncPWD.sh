#!/bin/bash
# ============================================================
#  backup_manual.sh — Sauvegarde rsync, mot de passe manuel
#  Le script te demandera le mot de passe UNE seule fois
#  Usage : ./backup_manual.sh
# ============================================================

# ---------- CONFIGURATION (à adapter) -----------------------
BACKUP_USER="backup"                        # User SSH sur le serveur distant
BACKUP_HOST="192.168.1.100"                 # IP ou hostname du serveur de backup
BACKUP_PORT="22"                            # Port SSH
BACKUP_DEST="/backups/$(hostname)"          # Dossier de destination sur le serveur
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

# Dossiers à exclure
EXCLUDES=(
    "--exclude=/var/lib/apt"
    "--exclude=/var/lib/dpkg/info"
    "--exclude=/var/lib/systemd"
    "--exclude=/var/lib/udev"
)

# ============================================================

DATE=$(date '+%Y-%m-%d %H:%M:%S')
echo "[$DATE] ====== Début de la sauvegarde ======" | tee -a "$LOG_FILE"
echo ""
echo "  Destination : $BACKUP_USER@$BACKUP_HOST:$BACKUP_DEST"
echo "  SSH va te demander le mot de passe pour chaque dossier."
echo ""

ERRORS=0

for SRC in "${SOURCES[@]}"; do

    if [ ! -d "$SRC" ]; then
        echo "[SKIP] $SRC n'existe pas, ignoré." | tee -a "$LOG_FILE"
        continue
    fi

    echo "[INFO] Sauvegarde de $SRC ..." | tee -a "$LOG_FILE"

    rsync -avz --delete \
        "${EXCLUDES[@]}" \
        -e "ssh -p $BACKUP_PORT -o StrictHostKeyChecking=accept-new" \
        "$SRC" \
        "$BACKUP_USER@$BACKUP_HOST:$BACKUP_DEST/" \
        2>&1 | tee -a "$LOG_FILE"

    if [ ${PIPESTATUS[0]} -eq 0 ]; then
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
