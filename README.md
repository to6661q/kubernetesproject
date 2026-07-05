# Kubernetes Project — Dockerize & Deploy a Static Website

This is my practice project for learning Docker and Kubernetes from scratch. The idea is simple: take a static website template (HTML/CSS), package it into a Docker image running Apache (`httpd`), then deploy that image to a Kubernetes cluster using a Deployment and a Service.

## Why I built this

I've been learning the basics of containers and orchestration. Instead of just reading theory, I wanted to get hands-on: build my own image, run it in Docker, then go all the way through deploying it to Kubernetes so I could actually see the flow from building an image to it running in a cluster.

## Project structure

```
.
├── Dockerfile          # image definition: web server + template
├── .dockerignore
├── k8s/
│   ├── deployment.yaml # Deployment for running the web pods
│   └── service.yaml    # Service to expose the pods
└── README.md
```

## About the Dockerfile

The base image is **Rocky Linux 9**. I originally used `centos:latest`, but I later found out the official CentOS image on Docker Hub is deprecated and all its tags are EOL, so `yum install` would fail since the mirrors are no longer active. I switched to Rocky Linux because it's a drop-in replacement for CentOS, so none of my `yum` commands needed to change.

What the Dockerfile does:
1. Installs `httpd`, `zip`, `unzip`.
2. Downloads the **Loxury** static template from free-css.com directly at build time (`ADD` from a URL).
3. Extracts the zip, moves the contents into `/var/www/html`, then removes the leftover zip/folder that's no longer needed.
4. Runs `httpd` in the foreground so the container doesn't exit immediately.

Template credit: [Loxury](https://www.free-css.com/assets/files/free-css-templates/download/page258/loxury.zip) from free-css.com.

## Running it locally with Docker

Build the image:

```bash
docker build -t loxury-web:latest .
```

Run the container:

```bash
docker run -d -p 8080:80 --name loxury-web loxury-web:latest
```

Open `http://localhost:8080` in your browser.

## Deploying to Kubernetes

First, push the image to a registry (Docker Hub or any other registry you use), and update the image name in `k8s/deployment.yaml` (`image: toriqnain/loxury-web:latest`) to match your own image if it's different.

```bash
docker tag loxury-web:latest toriqnain/loxury-web:latest
docker push toriqnain/loxury-web:latest
```

Apply the manifests to your cluster (I tested this on Minikube):

```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

Check pod and service status:

```bash
kubectl get pods
kubectl get svc loxury-web-service
```

If you're on Minikube, open the service with:

```bash
minikube service loxury-web-service
```

## Notes / next steps

- Add `livenessProbe` and `readinessProbe` to the Deployment to make it more production-ready.
- Try switching from `NodePort` to `Ingress` once I learn more about Ingress Controllers.
- Multi-stage build to make the image smaller (it's still single-stage for now).
- Add a simple CI pipeline (GitHub Actions) to auto build & push the image.

## License

The code in this repo is free to use for learning purposes. The Loxury template itself follows the license from free-css.com.
