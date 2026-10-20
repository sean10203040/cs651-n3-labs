# N3.4: Smart Speech Coach on AWS Elastic Beanstalk

[Back to the main README](../README.md)

This lab deploys the Smart Speech Coach Express/Gemini backend to Elastic Beanstalk. The backend source is in [`backend/server.js`](backend/server.js); [`backend/Procfile`](backend/Procfile) starts it with `web: npm start`.

## Current deployment

| Setting | Value |
| --- | --- |
| Backend | [Open service](http://cs651-n34-lcho-20261020.us-east-1.elasticbeanstalk.com/) |
| Health endpoint | [GET /api/health](http://cs651-n34-lcho-20261020.us-east-1.elasticbeanstalk.com/api/health) |
| Application | `cs651-n3-4` |
| Environment | `cs651-n34-lcho-env` (`e-zrhnsfxzdr`) |
| Region | `us-east-1` |
| Platform | Node.js 22 on Amazon Linux 2023 |
| Application version | `n34-restart-14686f9`, source commit `14686f9` |
| Capacity | Single instance; `t3.micro` with `t3.small` fallback; no load balancer or database |
| Gemini model | `gemini-3.5-flash-lite` |

Verified **October 20, 2026**: environment Ready / health Ok, health HTTP 200, and public AI endpoint HTTP 200 with a nonempty answer. See the [verification record](../docs/deployment-verification.md).

## Run the backend locally

Use Node.js 22 or newer:

```bash
cd n3.4/backend
npm ci
cp .env.example .env
```

Set `GEMINI_API_KEY` in your local `.env`, then run:

```bash
npm start
```

Open [http://localhost:3001/api/health](http://localhost:3001/api/health). `PORT` overrides the default 3001. Press Ctrl+C to stop the backend. Keep `.env` private; it is ignored by Git and excluded from deployment bundles.

## Environment configuration

Set these in Elastic Beanstalk's environment properties. The real API key belongs in the cloud environment settings, never in the repository.

```text
GEMINI_API_KEY=<your-current-restricted-key>
geminiAskAnythingModel=gemini-3.5-flash-lite
askAnythingPrompt=You are going to answer questions about Smart Speech Coach. Keep answers concise and on topic.
allowedOrigins=http://localhost:5173,https://smartspeechcoach.web.app
```

The deployed Gemini authorization key is restricted to `generativelanguage.googleapis.com` and bound to a dedicated service account. The key value is not included here.

Set the model explicitly: the source's fallback is `gemini-2.5-flash`, which the API rejected for this new account. On October 20, `gemini-3.8-flash` returned HTTP 503 (high demand), so the deployment uses the verified working `gemini-3.5-flash-lite`. This is an environment setting; the backend code is unchanged.

## Deploy in AWS Learner Lab

1. Start Learner Lab and open the AWS console in `us-east-1`.
2. From `n3.4/backend/`, create the source bundle with application files at the ZIP root:

   ```bash
   zip /tmp/cs651-n34-backend.zip server.js package.json package-lock.json Procfile
   ```

3. Upload that ZIP as a new application version under `cs651-n3-4`. Exclude `.env` and `node_modules`; Beanstalk installs the locked dependencies.
4. Create a **Standard web environment**, choose Node.js 22 / Amazon Linux 2023 and **single instance**, then use the existing service role **LabRole** and instance profile **LabInstanceProfile**.
5. Set the environment properties above. Keep the API key hidden when demonstrating the console.
6. Wait for status **Ready** and health **Ok**, then test both endpoints below. For code updates, upload a new version and deploy it to the existing environment.

## Verify the deployment

```bash
curl -i http://cs651-n34-lcho-20261020.us-east-1.elasticbeanstalk.com/api/health

curl -i http://cs651-n34-lcho-20261020.us-east-1.elasticbeanstalk.com/api/askanything \
  -H 'Content-Type: application/json' \
  -d '{"message":"Give one concise speech practice tip."}'
```

Health returns HTTP 200 with `{"status":"ok"}`. The AI endpoint returns HTTP 200 with an `answer` string; generated wording varies. An empty message returns HTTP 400.

## Compare Cloud Run and Beanstalk

| Cloud Run (N3.1/N3.2) | Elastic Beanstalk (N3.4) |
| --- | --- |
| Deploy a container image | Deploy a ZIP source bundle |
| Managed request-serving instances | Environment backed by an EC2 instance |
| Configured to scale to zero when idle | Single instance remains allocated until stopped or terminated |
| Managed HTTPS service URL | Current demo endpoint is HTTP |

The existing N3.3 Firebase frontend was not changed. An HTTPS frontend cannot call this HTTP backend directly in a browser because of mixed-content restrictions; this N3.4 demo exercises the backend endpoints directly. An HTTPS proxy or load balancer would be required for that frontend integration.

## Cleanup

Terminate only `cs651-n34-lcho-env`, wait for termination, and remove its application version with its source bundle when no longer needed. Confirm its attached instance, disk, and Elastic IP are released. Revoke the dedicated Gemini key if it is no longer needed.

Ending Learner Lab alone retains resources. The environment uses Learner Lab credits while active; inspect retained resources when cleaning up. Leave N3.3 and unrelated lab resources unchanged.
