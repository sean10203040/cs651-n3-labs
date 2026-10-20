# CS651 Lab N3: Forms, REST APIs, and Cloud Deployment

Express/EJS form handling, a browser `fetch()` JSON API, and a Gemini backend deployed to AWS Elastic Beanstalk.

## Live deployments

Last verified: **October 20, 2026**. These are the current demo URLs; cloud availability depends on the active services and AWS Learner Lab session.

| Lab | Live demo | Deployed application source |
| --- | --- | --- |
| **N3.1** - Traditional HTML forms | [Open Cloud Run app](https://cs651-n31-a6jstwmpja-uw.a.run.app/) | [Original starter at `2e88635`](https://github.com/sean10203040/cs651-n3-labs/tree/2e88635) |
| **N3.2** - REST/JSON and `fetch()` | [Open Cloud Run app](https://cs651-n32-a6jstwmpja-uw.a.run.app/) | Root application at [`14686f9`](https://github.com/sean10203040/cs651-n3-labs/tree/14686f9) |
| **N3.4** - Smart Speech Coach backend | [Open Beanstalk backend](http://cs651-n34-lcho-20261020.us-east-1.elasticbeanstalk.com/) / [Health](http://cs651-n34-lcho-20261020.us-east-1.elasticbeanstalk.com/api/health) | [`n3.4/backend/`](n3.4/backend/) at `14686f9` |

**N3.3 is already graded and was left unchanged.** Its separate frontend/Cloud Run deployment is outside this deployment update; this repository contains the backend copy used for N3.4.

The latest repository changes document and package these deployments. They do not change the application code running at the source commits above.

## Where to show the code

| What to explain | Source |
| --- | --- |
| Express setup, parsers, static files, and error handling | [`app.js`](app.js) |
| Traditional GET/POST form routes and JSON customer API | [`routes/index.js`](routes/index.js) |
| Traditional and REST forms on the same page | [`views/index.ejs`](views/index.ejs) |
| Browser `fetch()`, inline results, timeout, and error handling | [`public/javascripts/customer.js`](public/javascripts/customer.js) |
| Root server startup and cloud `PORT` support | [`bin/www`](bin/www) |
| HTTP integration tests | [`test/customer-api.test.js`](test/customer-api.test.js) |
| Cloud Run container build | [`Dockerfile`](Dockerfile), [deployment guide](docs/cloud-run.md) |
| Speech Coach Express/Gemini backend | [`n3.4/backend/server.js`](n3.4/backend/server.js) |
| Beanstalk process command and setup | [`n3.4/backend/Procfile`](n3.4/backend/Procfile), [deployment guide](n3.4/README.md) |

N3.2 extends N3.1; all original form routes remain in the root application. For the exact N3.1 demo code, use the original starter link above.

## Run locally

Use **Node.js 22** to match the deployed runtimes.

```bash
npm ci
npm start
```

Open [http://localhost:3000](http://localhost:3000). Set `PORT` to change the port, and press **Ctrl+C** to stop the server. This teaching app does not save customer data or send email.

Run the existing HTTP integration tests:

```bash
npm test
```

For the separate AI backend, follow [N3.4 local setup](n3.4/README.md#run-the-backend-locally). A Gemini API key is required only for that backend.

## Class demonstration

1. **N3.1:** Open the original Cloud Run app, enter a name/email, and submit the customer form. The browser navigates to `/readCustomerInfoAndRespond` and receives HTML.
2. **N3.2:** Open the REST app and submit the **Customer Form using REST / JSON**. JavaScript posts JSON to `/api/customer`; the greeting appears on the same page without navigation. The traditional forms still work.
3. Compare the requests in browser developer tools: `application/x-www-form-urlencoded` + HTML navigation versus `application/json` + a JSON fetch response.
4. **N3.4:** Show the backend source and `Procfile`, the Beanstalk environment with health **Ok**, then run the [health and AI requests](n3.4/README.md#verify-the-deployment). Keep the API key hidden.

| Traditional forms | REST/fetch |
| --- | --- |
| Browser submits an HTML form | Browser JavaScript sends JSON |
| Express returns an HTML response | Express returns JSON |
| Browser loads the response document | JavaScript updates the existing document |

### N3.2 API example

```bash
curl -sS https://cs651-n32-a6jstwmpja-uw.a.run.app/api/customer \
  -H 'Content-Type: application/json' \
  -d '{"name":"Linn","email":"linn@example.com"}'
```

```json
{"message":"Welcome Linn","email":"linn@example.com"}
```

Missing, blank, or non-string fields return HTTP 400; non-JSON requests return 415; malformed JSON returns 400; oversized JSON returns 413. The browser form also validates the email and displays request failures inline. See the [design decision](docs/decisions/n3-2-customer-api.md) for the rendering and validation rationale.

## Deployment guides and verification

- [N3.1/N3.2: Cloud Run build, deployment, and shutdown](docs/cloud-run.md)
- [N3.4: Elastic Beanstalk setup, configuration, and cleanup](n3.4/README.md)
- [Deployment verification record](docs/deployment-verification.md)
- [N3.2 assignment](https://borg.csueastbay.edu/~grewe/CS651/Projects/LabFormToREST_API.pdf) and [course lab outline](https://borg.csueastbay.edu/~grewe/CS651/outline.htm)

The forms start from the instructor's [FormData example](https://github.com/grewe/FormData). Do not commit API keys, `.env` files, credentials, dependency installs, or ZIP deployment bundles.
