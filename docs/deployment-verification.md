# Deployment verification: October 20, 2026

[Back to the main README](../README.md)

**Historical verification:** these checks passed before the demo services were intentionally shut down later on October 20, 2026. The Cloud Run services and Beanstalk environment are now offline.

## Observed results

| Check | Result |
| --- | --- |
| N3.1 public home page | HTTP 200 |
| N3.1 traditional customer POST | HTTP 200; HTML greeting; browser navigated to response |
| N3.2 public home page | HTTP 200 |
| N3.2 `POST /api/customer` | HTTP 200; expected `message` and `email` JSON |
| N3.2 browser fetch form | Greeting rendered without navigation |
| N3.4 Beanstalk environment | Ready / Green / Ok after deployment |
| N3.4 `GET /api/health` | HTTP 200; `{"status":"ok"}` |
| N3.4 `POST /api/askanything` | HTTP 200; nonempty generated speech practice answer |
| Root HTTP integration suite | 8 tests passed |
| Root Docker image | Linux amd64 build passed; container home page and JSON API smoke checks passed |

The public home/API/health endpoints and the N3.4 AI request were checked again during this documentation update. Browser navigation behavior and Beanstalk control-plane health were observed during the deployment earlier the same day. These results record that verification, not continuous uptime monitoring.

## Source and deployment versions

| Service | Application source | Deployed version |
| --- | --- | --- |
| `cs651-n31` (Cloud Run, `us-west1`) | `2e88635` | Image `cs651-n3/n31:2e88635` |
| `cs651-n32` (Cloud Run, `us-west1`) | `14686f9` root app | Image `cs651-n3/n32:14686f9` |
| `cs651-n34-lcho-env` (Beanstalk, `us-east-1`) | `14686f9`, `n3.4/backend/` | Application version `n34-restart-14686f9` |

Artifact Registry images are stored under `us-west1-docker.pkg.dev/cs651-n33-lcho-20261014/`.

The current repository update adds deployment documentation, a Docker build definition, ignore rules, and a placeholder local environment example. It does not change the deployed Express routes or AI backend source. N3.3 remains excluded, and no deployment pipeline was added.

## Demonstration boundaries

- Customer forms are stateless teaching examples; they do not save customer data or send email.
- N3.4 verifies the standalone AI backend. The existing HTTPS Firebase frontend was not reconfigured to use the HTTP Beanstalk endpoint.
- Gemini answers vary and depend on model availability and quota. The configured model is `gemini-3.5-flash-lite`.
- Cloud Run can scale to zero; Beanstalk availability depends on the active Learner Lab environment. These deployments are not guaranteed to remain online indefinitely.

The container build reported 12 dependency audit findings inherited from the starter lockfile (5 low, 1 moderate, 4 high, 2 critical). Dependency upgrades were outside this documentation and packaging update.

## Post-demonstration cleanup

On October 20, 2026 the Beanstalk environment, its EC2 instance/disk/IP, application, and source bundle were removed. Cloud Run services `cs651-n31`, `cs651-n32`, and the earlier private `n33-investigation` test were deleted. Both lab Artifact Registry repositories and the temporary Cloud Build source bucket were deleted. The dedicated N3.4 Gemini key was revoked and its service account removed. The separately maintained graded N3.3 application was not changed.

Source code remains in this repository. The cloud guides describe how to rebuild and redeploy; a new Gemini credential is required.
