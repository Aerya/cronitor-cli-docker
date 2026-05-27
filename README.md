# Cronitor CLI Docker image via GHCR

Image Docker GHCR personnelle pour CloudCLI / Claude Code UI, basée sur l'upstream :

- https://github.com/cronitorio/cronitor-cli

- builder automatiquement une image,
- mises à jour automatiques depuis l'upstream tous les jours à 4h30 UTC.

## ATTENTION

Ce montage de volumes est risqué, ne pas mettre d'accès sur Internet.

```
      - /etc/crontab:/etc/crontab
      - /etc/cron.d:/etc/cron.d
      - /var/spool/cron:/var/spool/cron
      - /var/run/docker.sock:/var/run/docker.sock
```