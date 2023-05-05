## Next-Js project

#

# for Node 18

- node:   18.16.0
- npm:    ...
- yarn:   1.22.19
- next:   13.4.1
- react:  18.2.0

## for Node 17

- node:   17.1.0
- npm
- next:   13.3.0
- react:  18.2.0

#

- Bibliografie:
    - https://nextjs.org/docs/getting-started
    - https://github.com/vercel/next.js/discussions/16995#discussioncomment-2074122



### Init
```bash
make init-app
```
- nume app:     'app'   [specificat in Makefile, se va crea si folderul]
- se va selecta: - No  - TypeScript
                 - Yes - ESLint   [nu e neaparat]
                 - Yes - `src/` directory
                 - Yes - Use App Router (recommended)
                 - NO  - experimental `app` directory
                 - NO  - Would you like to customize the default import alias

- [IMPORTANT]
- trebuie editat in `package.json` script-ul de build:
    ```json
    {
        "scripts": {
            "build": "next build && next export",
        }
    }
    ```
- iar `in next.config.js`:
    ```javascript
    // ...
    const nextConfig = {
        //reactStrictMode: true,
        output: 'export',
        distDir: 'dist'
    }
    // ...
    ```


### Run [dev mode]
```bash
make start-dev
```

### Build for production
```bash
make start-prod
```
==> /app/.next/static
