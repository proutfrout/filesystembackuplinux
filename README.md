# file system backup linux
```
/
├── proc/    ❌ virtuel
├── sys/     ❌ virtuel
├── dev/     ❌ virtuel
├── run/     ❌ runtime
├── tmp/     ❌ temporaire
├── usr/     ❌ réinstallable
├── bin/     ❌ réinstallable
├── lib/     ❌ réinstallable
├── var/
│   ├── cache/   ❌ régénérable
│   ├── log/     ⚠️  forensics seulement
│   ├── lib/     ✅ données apps (mysql, etc.)
│   └── www/     ✅ sites web
├── etc/     ✅ CRITIQUE
├── home/    ✅ CRITIQUE
├── root/    ✅ CRITIQUE
├── opt/     ✅ selon usage
└── srv/     ✅ selon usage
```
