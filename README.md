# Local Proxy with Traefik v3 & HTTPS

A Local reverse proxy powered by **Traefik v3** with full **HTTPS** for Docker Compose–based development. Route multiple local services to friendly domains with **trusted, locally issued certificates**.

---

## ✨ What you get
- **HTTPS locally** via [mkcert] certificates
- **Pretty domains** like `api.eng-local.app` instead of ports
- **Traefik dashboard** to see routers/middlewares
- **Zero-collision** networking via a shared Docker network
- **Copy‑paste examples** to expose your own containers

---

## ✅ Prerequisites
- [Docker](https://docs.docker.com/get-docker/) & [Docker Compose](https://docs.docker.com/compose/)
  - Windows: **Docker Desktop** recommended
  - macOS: **OrbStack** recommended
- [mkcert](https://github.com/FiloSottile/mkcert) installed

> **Why mkcert?** It generates locally trusted certs by adding a CA to your system keychain — no browser warnings once set up.

---

## 🚀 Quick start

Clone the repo:
```bash
git clone https://github.com/thilinaperera/local-proxy
cd local-proxy
```

Copy `.env.example` to `.env` and adjust if needed.
```bash
cp .env.example .env
```

Install and generate certificates (first‑time mkcert users must install the local CA):
```bash
# First‑time only
mkcert -install

# Issue a cert for the root domain and all subdomains
./create-certs.sh
```
---

Running the script will create a folder called certs with these files:
-	local-cert.pem
-	local-key.pem

You can copy these files into your project root and use them with backends like Node.js or tooling such as Vite.

#### Installing the CA on other systems
Installing in the trust store does not require the CA key, so you can export the CA certificate and use mkcert to install it in other machines.

- Look for the rootCA.pem file in mkcert -CAROOT
- copy it to a different machine
- set ``$CAROOT`` to its directory or copy the file to the ``'$CAROOT'`` directory
- run ``mkcert -install``
---


Create the shared Docker network (Traefik and your apps will attach to this):
```bash
docker network create local-proxy || true
```

Start Traefik:
```bash
# If your Docker uses Compose < v2 you can also run: docker-compose -f docker-compose.yml up -d
docker compose -f docker-compose.yml up -d
```

Open the dashboard:
- https://traefik.eng-local.app/dashboard/

> If the domain doesn’t resolve yet, see **Add local domains** below.

---

## 🧭 Add local domains (DNS/hosts)
You’ll access services via domains under `<name>.eng-local.app`. Point the names you need to `127.0.0.1`.

Add explicit names you plan to use

``` sh
127.0.0.1 traefik.eng-local.app
# 127.0.0.1 api.eng-local.app
# 127.0.0.1 web.eng-local.app
```

> Note: `/etc/hosts` doesn’t support wildcards. Add entries per subdomain you actually use.

---

## 🧩 Expose your app through Traefik

Attach your service to the **`local-proxy`** network and add Traefik labels. Example `docker-compose.yml` service:

```yaml
api:
  image: containous/whoami:latest # replace with your image
  container_name: auth-api
  networks:
    - local-proxy
  labels:
    # Enable Traefik for this container
    - "traefik.enable=true"

    # HTTP router
    - "traefik.http.routers.api.rule=Host(`api.eng-local.app`)"
    - "traefik.http.routers.api.entrypoints=https"   # use TLS entrypoint
    - "traefik.http.routers.api.tls=true"

networks:
  local-proxy:
    external: true
```

> The bundled Traefik config is already set up to use the `certs/local-cert.pem` and `certs/local-key.pem` you generated with mkcert.

---

## ✅ Verify it works
1. Ensure `api.eng-local.app` resolves to `127.0.0.1` (see **Add local domains**).
2. Start your service and Traefik:
   ```bash
   docker compose up -d # or: docker-compose up -d
   ```
3. Visit **https://api.eng-local.app/** — you should see your service with a valid lock icon.
4. Visit **https://traefik.eng-local.app/dashboard/** for routing details.

---

## 🔧 Troubleshooting

- **Browser shows “Not secure”**
  - Run `mkcert -install` again and restart the browser to trust the local CA.
  - Make sure you used the exact domain in the cert (`eng-local.app` / `*.eng-local.app`).
- **Domain doesn’t resolve**
  - Add the subdomain to `/etc/hosts` (or configure a wildcard resolver).
- **404 from Traefik**
  - Check the router rule label matches the host you’re visiting.
  - Confirm the service and Traefik are on the same Docker network (`local-proxy`).
- **Dashboard unreachable**
  - Ensure `traefik.eng-local.app` resolves to `127.0.0.1` and Traefik is running.

---

## 🧹 Stop & clean up

Stop Traefik:

```bash
docker compose down
```

Remove the shared network (only if you no longer use it for any service):

```bash
docker network rm local-proxy
```

To remove the local CA/certs created by mkcert, see mkcert’s README.

---

## 📄 License

MIT
