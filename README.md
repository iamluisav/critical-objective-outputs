# critical-objective-outputs

Public publish surface for sanitized job-feed artifacts from the
[Critical Objective](https://criticalobjective.com) pipeline.

This repo is write-only from the pipeline side. It is not a development
repo for application features; documentation/contract maintenance is separate
from generated refreshes. It is not a place to add new
artifact types without updating the allowlist below.

## What's here

| File | Shape | Purpose |
| --- | --- | --- |
| `jobs.json` | JSON array | Slim job records (no descriptions) for website and board consumers |
| `jobs-manifest.json` | JSON object, schema version 1 | SHA-256 binding to exact jobs bytes, observed listing/posting counts, observation window and aggregate source coverage; no per-source diagnostics |
| `government.json` (optional; currently absent) | JSON array | Federal roles from the USAJOBS Search API (curated agencies and series), same record shape as `jobs.json` plus `close_date`, `grade`, `series`, `series_code`, `clearance`, `hiring_paths`, `location_count`; no descriptions |
| `feed_greenhouse.xml` | XML | Greenhouse-sourced jobs for board ingestion (description stripped) |
| `feed_ashby.xml` | XML | Ashby-sourced jobs for board ingestion (description stripped) |
| `feed_lever.xml` | XML | Lever-sourced jobs for board ingestion (description stripped) |
| `feed_custom.xml` | XML | Verified official employer careers pages, currently ZeroEyes (same sanitized record shape; no descriptions) |

`government.json` is optional by design. The scheduled producer writes it only when both `USAJOBS_API_KEY` and `USAJOBS_USER_AGENT` are configured and a current fetch succeeds. It is absent from the current public snapshot. The publisher does not synthesize an empty file: absence means the federal source is not configured or was not published, not that federal hiring is zero.

## Coverage summary unit

`jobs-manifest.json` remains schema version 1. New canonical-company snapshots
include `source_summary.unit: "canonical_companies"`. For those snapshots,
`total`, `attempted`, `successful`, `empty`, `failed`, and `skipped` describe
active canonical companies rather than raw source-configuration rows. Exact
duplicate configurations collapse only within the same private source identity;
a verified inactive lifecycle is excluded from the active denominator; and an
unavailable company remains skipped and unknown, never a confirmed zero.

Legacy schema-version-1 manifests without `source_summary.unit` must be read as
`source_configurations`. Unknown unit values are invalid. In particular, public
commit `97d9bf66f3fa2f4a3bfa4c4b517a9180c6019dab` has no unit marker and its
source summary is the legacy configuration-row aggregate. Do not compare its
coverage counts directly with a marked canonical-company snapshot.

All records carry only publicly observable fields: `job_id`, `job_title`,
`company_name`, `company_url`, `company_logo_url`, `job_url`,
`application_link`, `publish_date`, `job_type`, `location`,
`location_type`, `department`, `sector`, `salary_min`, `salary_max`,
`salary_currency`, `pay_source`, `job_function`, `experience_level`.

Source provenance may additionally include `source_posting_id`, `company_slug`,
`company_identity_source`, `curation_tier` (explicit `core`, `adjacent` or
`unknown` only), `source`, `source_type`, `source_posted_at`, `source_updated_at`,
`first_seen_at` and `source_checked_at`. Unknown publication times remain null.
The producer selects these through an explicit field/value allowlist; private
rankings, source records and intelligence are not approved by these additions.

The `description` field is intentionally excluded from XML feeds. Consumers
that need descriptions should fetch them directly from `application_link`,
which points at the authoritative ATS or employer application page. This keeps the public repo
small and keeps us from re-hosting content we don't own.

## What's not here — and will not be accepted

This repo is not a mirror of the private producer. It must never carry:

- scoring, ranking, or tiering data (e.g. `score`, `magnitude`, `coverage_priority`)
- curated intelligence fields (e.g. `current_fit_for_luis`, `why_it_matters`)
- monitor/situation signals (e.g. `monitor-signals.json`)
- company entity registries or source registries
- anything downstream of the Search OS intelligence pipeline
- any data produced by or derived from `intelligence.db`

Intelligence artifacts belong in the private website repo
(`critical-objective-web`), not here. Git history is forever on a public
repo — a transient commit is still a leak.

## Publish contract

Public artifact production belongs to GitHub Actions in `critical-objective-feed`:

1. `build-feed.yml` publishes the scheduled full refresh.
2. `refresh-selected-feeds.yml` publishes bounded employer refreshes on demand.

The laptop `daily_run.sh` publishes private intelligence to the website repo;
it does not publish public jobs/XML here.

The publisher contract is: require tests, serialize writers, stage only explicit
artifact paths (including the paired jobs/manifest files), validate their exact
hash and counts in the producer, run `scripts/check_publish_allowlist.sh` on the staged result,
then commit/push. The gate checks tracked/staged filenames; it does not inspect
all untracked files or validate every field inside allowed JSON/XML. Exporters
must still select public-safe fields. Update the allowlist and producer together
when introducing an artifact type. The local pre-commit hook adds a manual-use
guard when installed.

The custom feed is initially seeded empty with this allowlist change; the
producer's guarded ZeroEyes refresh populates it after source verification.
No registries, source HTML, descriptions, form submissions, or private
intelligence are permitted. The local `daily_run.sh` remains outside the
public publish path.

## Transitional serving boundary

This repository is the current public compatibility layer for sanitized job
artifacts. It is not the long-term storage system or the source of private
intelligence.

The verified owned-code references, documented-but-unverified Job Boardly XML
imports, unknown external-consumer risk and mandatory no-privatize checklist are
maintained in [CONSUMERS.md](CONSUMERS.md).

Current artifacts may remain publicly readable. Long-term observation history,
source health, registries, scoring, research and derived hiring signals belong in
private systems.

Do not add new consumers that hardcode GitHub Raw URLs. New consumers must use
configurable artifact URLs so distribution can move to a Critical Objective-owned
data domain without another application rewrite.

The target is immutable, versioned artifacts in object storage; a small hash-bound
current manifest; stable compatibility feed URLs; and private retention of
historical snapshots. Git history currently retains prior public snapshots and
can be used to reconstruct a time series. That is historical exposure, not the
intended product contract. Do not publish additional derived history here.

## Historical note

`monitor-signals.json` appeared briefly in commits on 2026-04-14 before
being removed. It contained internal scoring signals applied to publicly
observable job counts. The contents are low-severity (no credentials,
no PII, no candidate records), but they did not belong here. The allowlist
gate landed on 2026-04-15 to reject disallowed tracked/staged file paths.

History has not been rewritten. The gate and explicit staging reduce recurrence risk;
exporter review remains necessary for allowed files.

## Usage status

This repository is publicly readable because current production consumers use
unauthenticated artifact URLs. Public visibility is a transport decision, not a
defined license for bulk reuse or redistribution.

No dataset or code license is currently granted here. Add reviewed data-use terms
before representing external reuse rights.

