# 🛡️ SOC Cheatsheet — Où trouver les fichiers critiques sur Linux

> Référence rapide pour exercices de cybersécurité / incident response.  
> Utile pour : backup, forensics, investigation post-attaque.

---

## 🌐 Web Servers

### NGINX
```
/etc/nginx/                     # Config principale
/etc/nginx/nginx.conf           # Config globale
/etc/nginx/sites-available/     # Vhosts disponibles
/etc/nginx/sites-enabled/       # Vhosts actifs (symlinks)
/etc/nginx/conf.d/              # Configs additionnelles
/var/log/nginx/access.log       # Logs d'accès ⚠️ forensics
/var/log/nginx/error.log        # Logs d'erreurs ⚠️ forensics
/var/www/html/                  # Racine web par défaut
/usr/share/nginx/html/          # Racine alternative
```

### Apache2 (Debian/Ubuntu)
```
/etc/apache2/                   # Config principale
/etc/apache2/apache2.conf       # Config globale
/etc/apache2/sites-available/   # Vhosts disponibles
/etc/apache2/sites-enabled/     # Vhosts actifs
/etc/apache2/mods-enabled/      # Modules actifs
/var/log/apache2/access.log     # Logs d'accès ⚠️ forensics
/var/log/apache2/error.log      # Logs d'erreurs ⚠️ forensics
/var/www/html/                  # Racine web par défaut
```

### Apache (RHEL/CentOS)
```
/etc/httpd/                     # Config principale
/etc/httpd/conf/httpd.conf      # Config globale
/etc/httpd/conf.d/              # Configs additionnelles
/var/log/httpd/access_log       # Logs d'accès ⚠️ forensics
/var/log/httpd/error_log        # Logs d'erreurs ⚠️ forensics
/var/www/html/                  # Racine web par défaut
```

---

## 🗄️ Bases de données

### MySQL / MariaDB
```
/etc/mysql/                     # Config principale
/etc/mysql/my.cnf               # Config globale
/etc/mysql/mysql.conf.d/        # Configs additionnelles
/var/lib/mysql/                 # Données ⚠️ CRITIQUE
/var/log/mysql/error.log        # Logs ⚠️ forensics
/var/log/mysql/mysql.log        # Logs requêtes (si activé)
```
> 💡 Dump propre : `mysqldump -u root -p --all-databases > dump.sql`

### PostgreSQL
```
/etc/postgresql/                # Config principale
/etc/postgresql/<version>/main/ # Config version spécifique
/var/lib/postgresql/            # Données ⚠️ CRITIQUE
/var/lib/postgresql/<ver>/main/ # Cluster principal
/var/log/postgresql/            # Logs ⚠️ forensics
```
> 💡 Dump propre : `pg_dumpall -U postgres > dump.sql`

### MongoDB
```
/etc/mongod.conf                # Config principale
/var/lib/mongodb/               # Données ⚠️ CRITIQUE
/var/log/mongodb/mongod.log     # Logs ⚠️ forensics
```

### Redis
```
/etc/redis/redis.conf           # Config principale
/var/lib/redis/dump.rdb         # Snapshot données ⚠️ CRITIQUE
/var/log/redis/redis-server.log # Logs ⚠️ forensics
```

### SQLite
```
# Pas de chemin standard — chercher avec :
find / -name "*.db" -o -name "*.sqlite" -o -name "*.sqlite3" 2>/dev/null
```

---

## 🐳 Docker

### Fichiers Docker sur l'hôte
```
/var/lib/docker/                # Tout Docker ⚠️ CRITIQUE
/var/lib/docker/volumes/        # Volumes nommés
/var/lib/docker/containers/     # Metadata + logs des conteneurs
/var/lib/docker/overlay2/       # Layers des images (lourd, souvent inutile)
/etc/docker/daemon.json         # Config du daemon Docker
```

### Fichiers Compose / configs
```
/opt/<service>/docker-compose.yml   # Emplacement typique
/srv/<service>/docker-compose.yml   # Alternative courante
/home/<user>/docker-compose.yml     # Projets utilisateur
```

### Trouver les données des conteneurs en cours
```bash
# Voir les mounts de tous les conteneurs actifs
docker inspect $(docker ps -q) \
  --format '{{.Name}} : {{range .Mounts}}{{.Source}} -> {{.Destination}} {{end}}'

# Lister tous les volumes et leur chemin réel
docker volume inspect $(docker volume ls -q)

# Entrer dans un conteneur pour explorer
docker exec -it <nom_conteneur> /bin/bash
```

### Logs des conteneurs
```bash
docker logs <nom_conteneur>
docker logs <nom_conteneur> --tail 100 -f   # Temps réel
# Fichiers bruts :
/var/lib/docker/containers/<id>/<id>-json.log
```

---

## 🔐 SSH & Authentification

```
/etc/ssh/sshd_config            # Config serveur SSH ⚠️ CRITIQUE
/etc/ssh/ssh_host_*             # Clés hôtes du serveur
~/.ssh/authorized_keys          # Clés publiques autorisées ⚠️ IOC
~/.ssh/id_rsa                   # Clé privée utilisateur
~/.ssh/known_hosts              # Hôtes connus
/var/log/auth.log               # Logs auth (Debian) ⚠️ forensics
/var/log/secure                 # Logs auth (RHEL/CentOS) ⚠️ forensics
```

---

## 📨 Mail

### Postfix
```
/etc/postfix/main.cf            # Config principale
/etc/postfix/master.cf          # Services
/var/spool/postfix/             # Files de mail
/var/log/mail.log               # Logs ⚠️ forensics
/var/log/mail.err               # Erreurs ⚠️ forensics
```

### Dovecot
```
/etc/dovecot/dovecot.conf       # Config principale
/etc/dovecot/conf.d/            # Configs additionnelles
/var/mail/                      # Boîtes mail format mbox
/home/<user>/Maildir/           # Boîtes mail format Maildir
/var/log/dovecot.log            # Logs ⚠️ forensics
```

---

## 🔁 Reverse Proxy / Load Balancer

### HAProxy
```
/etc/haproxy/haproxy.cfg        # Config principale ⚠️ CRITIQUE
/var/log/haproxy.log            # Logs ⚠️ forensics
```

### Traefik
```
/etc/traefik/traefik.yml        # Config statique
/etc/traefik/dynamic/           # Config dynamique
# Souvent via Docker labels — voir docker-compose.yml
```

---

## 🔒 TLS / Certificats

```
/etc/ssl/certs/                 # Certificats système
/etc/ssl/private/               # Clés privées ⚠️ CRITIQUE
/etc/letsencrypt/               # Certificats Let's Encrypt ⚠️ CRITIQUE
/etc/letsencrypt/live/<domain>/ # Certs actifs
/etc/letsencrypt/archive/       # Historique des certs
```

---

## ⚙️ Système général

### Config & utilisateurs
```
/etc/passwd                     # Utilisateurs ⚠️ IOC (nouveaux users ?)
/etc/shadow                     # Hash des mots de passe ⚠️ CRITIQUE
/etc/group                      # Groupes
/etc/sudoers                    # Droits sudo ⚠️ IOC
/etc/sudoers.d/                 # Règles sudo additionnelles ⚠️ IOC
/etc/hosts                      # Résolution DNS locale ⚠️ IOC
/etc/crontab                    # Crons système ⚠️ IOC
/etc/cron.d/                    # Crons additionnels ⚠️ IOC
/var/spool/cron/crontabs/       # Crons par utilisateur ⚠️ IOC
```

### Logs système
```
/var/log/syslog                 # Logs système généraux ⚠️ forensics
/var/log/kern.log               # Logs kernel ⚠️ forensics
/var/log/auth.log               # Auth / sudo / SSH ⚠️ forensics
/var/log/dmesg                  # Boot / hardware
/var/log/dpkg.log               # Paquets installés ⚠️ forensics
/var/log/apt/history.log        # Historique apt ⚠️ forensics
/var/log/lastlog                # Dernières connexions
/var/log/wtmp                   # Historique logins (last)
/var/log/btmp                   # Tentatives login échouées (lastb)
```

### Persistance & démarrage
```
/etc/systemd/system/            # Services systemd ⚠️ IOC (nouveaux services ?)
/lib/systemd/system/            # Services systemd système
/etc/init.d/                    # Scripts init legacy
/etc/rc.local                   # Script au démarrage ⚠️ IOC
~/.bashrc                       # Profil bash utilisateur ⚠️ IOC
~/.bash_profile                 # Profil bash login ⚠️ IOC
/etc/profile                    # Profil global ⚠️ IOC
/etc/profile.d/                 # Profils additionnels ⚠️ IOC
```

---

## 🕵️ Commandes utiles pour le SOC

```bash
# Dernières connexions
last -a | head -20
lastb | head -20                # Tentatives échouées

# Utilisateurs connectés en ce moment
w
who

# Processus suspects
ps aux --sort=-%cpu | head -20
ps aux | grep -v "root\|www-data\|postgres"

# Connexions réseau actives
ss -tulnp
netstat -tulnp

# Fichiers modifiés récemment (dernières 24h)
find /etc /var /opt /srv -mtime -1 -type f 2>/dev/null

# Fichiers SUID suspects
find / -perm -4000 -type f 2>/dev/null

# Nouvelles tâches cron
find /var/spool/cron /etc/cron* -mtime -7 2>/dev/null

# Services actifs
systemctl list-units --type=service --state=running

# Historique bash de tous les users
cat /root/.bash_history
cat /home/*/.bash_history
```

---

## 📋 Légende

| Symbole | Signification |
|---------|--------------|
| ⚠️ CRITIQUE | Données essentielles, sauvegarder en priorité |
| ⚠️ forensics | Précieux pour l'investigation, ne pas écraser |
| ⚠️ IOC | Indicator of Compromise — vérifier si modifié |

---

*Cheatsheet SOC — Linux Services File Locations*
