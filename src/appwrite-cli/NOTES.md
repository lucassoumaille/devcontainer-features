## Connexion conservée

La CLI garde sa session dans `~/.appwrite/prefs.json`. La feature monte le volume nommé `appwrite-cli-config` sur `/mnt/appwrite-config` et crée le lien `~/.appwrite -> /mnt/appwrite-config` : `appwrite login` survit aux rebuilds. La CLI essaie d'abord de ranger le refresh token dans le trousseau système. Un conteneur n'en a pas, donc elle l'écrit dans `prefs.json` et affiche un avertissement : c'est le comportement attendu.

Le volume appartient à l'UID qui l'a créé (1000 pour `node` et `vscode`). Ne déclarez ni un autre montage sur `/mnt/appwrite-config`, ni `XDG_CONFIG_HOME` pour la CLI, dans `devcontainer.json`.

## Mise en place dans un nouveau projet

Exemple avec le template `node`.

1. **Créer le projet**

   ```bash
   git init
   devcontainer templates apply -t ghcr.io/lucassoumaille/devcontainer-templates/node
   ```

   Ou, dans VS Code : *Dev Containers: Add Dev Container Configuration Files…*

2. **Ajouter la feature** dans `.devcontainer/devcontainer.json`, à côté d'`ai-tools`, puis *Rebuild Container* :

   ```jsonc
   "features": {
       "ghcr.io/lucassoumaille/devcontainer-features/ai-tools:1": {},
       "ghcr.io/lucassoumaille/devcontainer-features/appwrite-cli:1": {}
       // version figée : "ghcr.io/lucassoumaille/devcontainer-features/appwrite-cli:1": { "version": "28.10.2" }
   }
   ```

3. **Dans le conteneur**

   ```bash
   appwrite login          # une seule fois : la session est gardée dans le volume
   appwrite init project   # crée appwrite.config.json à la racine
   npm install node-appwrite   # SDK serveur
   # ou : npm install appwrite  # SDK client web
   ```

   `appwrite.config.json` décrit le projet et ses ressources (collections, functions, buckets). Il se commite, et on le déploie avec `appwrite push`. Les anciens projets utilisent encore `appwrite.json`, que la CLI lit toujours.

4. **Secrets**, au choix :

   - un `.env` ignoré par git (ajoutez `.env` à `.gitignore`) :

     ```dotenv
     APPWRITE_ENDPOINT=https://<region>.cloud.appwrite.io/v1
     APPWRITE_PROJECT_ID=<project-id>
     APPWRITE_API_KEY=<api-key>
     ```

   - ou une clé qui reste sur l'hôte, transmise par `devcontainer.json` :

     ```json
     "remoteEnv": { "APPWRITE_API_KEY": "${localEnv:APPWRITE_API_KEY}" }
     ```

   La clé API ne va jamais dans du code front.

5. **Règles pour les agents** : copiez ce bloc dans le `CLAUDE.md` du projet.

   ```markdown
   ## Appwrite
   - Backend: Appwrite Cloud. Schema (collections, functions, buckets) is defined in the Appwrite config file at the repo root; change it there and deploy with `appwrite push`, never only in the console.
   - Server code uses `node-appwrite` with `APPWRITE_API_KEY`; browser code uses `appwrite` and must never receive the API key.
   - Set document/bucket permissions explicitly; do not default to `Role.any()` for writes.
   - Ask before running `appwrite push` or any command that changes the Cloud project.
   ```

6. **Python (Functions Appwrite)** : même feature dans le template `python`, avec le SDK `appwrite` de pip (`pip install appwrite`). La feature a besoin de `npm` : gardez la feature `node` ou une image qui fournit Node.js.

7. **Déconnexion** : sur l'hôte, `docker volume rm appwrite-cli-config`.
