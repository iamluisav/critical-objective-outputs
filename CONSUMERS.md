# Consumer inventory and sunset gate

This repository is a transitional public compatibility layer. Public readability
is currently required by known unauthenticated consumers; public Git history is
not the intended long-term data plane.

## Verified owned-code consumers

The following references are verified in the current
`iamluisav/critical-objective-web` source:

| Consumer | Artifact | Current behavior | Migration seam |
| --- | --- | --- | --- |
| Website jobs runtime | `jobs.json` | Defaults to the Raw GitHub URL; `JOBS_ARTIFACT_URL` can override it | `PUBLIC_ARTIFACT_BASE_URL` resolves the hash-bound object-plane pointer |
| Website jobs metadata and share summaries | `jobs-manifest.json` | Resolved beside `jobs.json`, or through `JOBS_MANIFEST_URL` | The object-plane pointer owns the immutable jobs/manifest pair |
| Website federal jobs runtime | `government.json` | Defaults to the Raw GitHub URL; `GOVERNMENT_ARTIFACT_URL` can override it | The object-plane pointer may supply the optional artifact |
| Website local sync utility | `jobs.json` | `scripts/fetch-jobs.js` reads the Raw GitHub URL | Update or retire after production cutover |

A code-search result proves the reference exists. It does not prove the deployed
environment has no override. Deployment configuration and live requests must be
checked during cutover.

## Documented external consumer

Maintained Critical Objective documentation says Job Boardly imports sanitized
XML feeds for `jobs.criticalobjective.com`. The exact active Job Boardly feed
URLs and enabled imports have **not** been independently inventoried in its
administrative surface during this review.

Treat every XML artifact as in use until that inventory is complete:

- `feed.xml`
- `feed_greenhouse.xml`
- `feed_ashby.xml`
- `feed_lever.xml`
- `feed_custom.xml`

## Unknown consumers

Because this repository and its Raw GitHub URLs are public, other XML/JSON
consumers may exist. Repository search cannot enumerate external readers.
Absence from owned code is not evidence of zero consumers.

Before sunset, use every available source of evidence:

- Job Boardly configuration and successful-import timestamps
- owned repository and deployment configuration search
- object-origin/CDN request logs during shadow operation
- public-site synthetic checks
- a defined compatibility window for previously published URLs

Unknown external consumers remain an explicit migration risk. Do not silently
reinterpret them as absent.

## No-privatize gate

Do **not** make this repository private, archive it, delete artifacts, or stop
GitHub publication until all of these are true:

- [ ] The object plane has completed seven eligible scheduled dual-publications.
- [ ] Every public pointer and referenced artifact passes exact byte, SHA-256,
      count, media-type and no-redirect verification.
- [ ] The website is configured for the new prefix-root base and production jobs,
      status, APIs and share cards are verified.
- [ ] The exact active Job Boardly XML imports are recorded and moved to stable
      replacement URLs.
- [ ] Unknown-consumer risk has been observed through the compatibility window
      and explicitly accepted.
- [ ] Rollback to the GitHub artifacts has been tested before GitHub publication
      is disabled.
- [ ] The final GitHub mirror commit and replacement pointer are recorded in the
      private operating log.

A visibility change does not revoke prior public clones or caches.

## Target boundary

The durable architecture is:

- code and reviewed configuration in private Git repositories;
- one immutable run/snapshot envelope with exact provenance;
- current sanitized artifacts on a Critical Objective-owned public object plane;
- durable longitudinal observations in a private append-only ledger;
- Search OS as a rebuildable analytical view plus human judgment.

This repository should disappear from the runtime path only after the reversible
dual-publish and consumer-cutover gates pass.
