# N3.1 and N3.2: Google Cloud Run

[Back to the main README](../README.md)

## Current services

| Setting | Value |
| --- | --- |
| Google Cloud project | `cs651-n33-lcho-20261014` |
| Region | `us-west1` |
| N3.1 service | `cs651-n31` - [live app](https://cs651-n31-a6jstwmpja-uw.a.run.app/) |
| N3.2 service | `cs651-n32` - [live app](https://cs651-n32-a6jstwmpja-uw.a.run.app/) |
| Runtime | Node.js 22; container listens on Cloud Run's `PORT=8080` |
| Capacity per service | 1 CPU, 256 MiB, minimum 0 instances, maximum 1 instance |
| Billing | Request-based; idle services can scale to zero |
| Runtime identity | Existing `n33-runtime@cs651-n33-lcho-20261014.iam.gserviceaccount.com`; no project roles added |
| Access | Public demo services |

The existing `n33-investigation` service belongs to earlier work and was not changed.

## Build and deploy manually

Run these commands in an authenticated Google Cloud Shell with Docker and access to the project. The Artifact Registry repository `cs651-n3` already exists in `us-west1`.

```bash
git clone https://github.com/sean10203040/cs651-n3-labs.git
cd cs651-n3-labs

gcloud auth configure-docker us-west1-docker.pkg.dev --quiet
```

### N3.1: original forms

Export only the original application files. Copy the current Docker build configuration into the temporary directory without switching the working repository or copying its installed dependencies.

```bash
N31_SOURCE=$(mktemp -d)
git archive 2e88635 app.js bin routes views public package.json package-lock.json \
  | tar -x -C "$N31_SOURCE"
cp Dockerfile .dockerignore "$N31_SOURCE/"

docker build --platform linux/amd64 \
  -t us-west1-docker.pkg.dev/cs651-n33-lcho-20261014/cs651-n3/n31:2e88635 \
  "$N31_SOURCE"
docker push us-west1-docker.pkg.dev/cs651-n33-lcho-20261014/cs651-n3/n31:2e88635
```

### N3.2: root application with REST/fetch

The root Dockerfile copies only the application files and installs dependencies from the lockfile. It does not bundle the separate AI backend or local `node_modules`.

```bash
docker build --platform linux/amd64 \
  -t us-west1-docker.pkg.dev/cs651-n33-lcho-20261014/cs651-n3/n32:14686f9 .
docker push us-west1-docker.pkg.dev/cs651-n33-lcho-20261014/cs651-n3/n32:14686f9
```

The `14686f9` image tag identifies the deployed application source. If application code changes, use a new tag rather than overwriting this version.

### Deploy each image

```bash
for spec in cs651-n31:n31:2e88635 cs651-n32:n32:14686f9; do
  IFS=: read -r service image version <<< "$spec"
  gcloud run deploy "$service" \
    --image="us-west1-docker.pkg.dev/cs651-n33-lcho-20261014/cs651-n3/$image:$version" \
    --project=cs651-n33-lcho-20261014 \
    --region=us-west1 \
    --service-account=n33-runtime@cs651-n33-lcho-20261014.iam.gserviceaccount.com \
    --port=8080 --cpu=1 --memory=256Mi \
    --min=0 --max=1 --allow-unauthenticated
done
```

The deployment used Docker builds in Cloud Shell and pushed the images directly. Managed Cloud Build was not used successfully: the default build service account could not read the uploaded source. No additional IAM roles or automatic deployment pipeline were added to resolve that error.

## Verify

```bash
curl -i https://cs651-n31-a6jstwmpja-uw.a.run.app/
curl -i https://cs651-n32-a6jstwmpja-uw.a.run.app/api/customer \
  -H 'Content-Type: application/json' \
  -d '{"name":"Linn","email":"linn@example.com"}'
```

In the browser, submit the traditional form in N3.1 and the fetch form in N3.2. Check that the first navigates and the second updates the existing page.

## Stop locally or take a cloud demo offline

- **Local:** press Ctrl+C in the terminal running `npm start`.
- **Idle Cloud Run:** minimum instances is zero, so services can scale down automatically. The public URL remains available for future requests.
- **Take a demo offline:** delete only the named service below. This removes its endpoint and service configuration; it does not delete the saved Artifact Registry image. Redeploy the image to restore the service.

```bash
gcloud run services delete cs651-n31 \
  --project=cs651-n33-lcho-20261014 --region=us-west1
gcloud run services delete cs651-n32 \
  --project=cs651-n33-lcho-20261014 --region=us-west1
```

Do not delete `n33-investigation` as part of N3.1/N3.2 cleanup. Retained images and other cloud resources are separate from Cloud Run instance billing.
