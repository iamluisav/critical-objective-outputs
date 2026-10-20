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
| `government.json` | JSON array | Federal roles from the USAJOBS Search API (curated agencies and series), same record shape as `jobs.json` plus `close_date`, `grade`, `series`, `series_code`, `clearance`, `hiring_paths`, `location_count`; no descriptions |
| `feed_greenhouse.xml` | XML | Greenhouse-sourced jobs for board ingestion (description stripped) |
| `feed_ashby.xml` | XML | Ashby-sourced jobs for board ingestion (description stripped) |
| `feed_lever.xml` | XML | Lever-sourced jobs for board ingestion (description stripped) |

All records carry only publicly observable fields: `job_id`, `job_title`,
`company_name`, `company_url`, `company_logo_url`, `job_url`,
`application_link`, `publish_date`, `job_type`, `location`,
`location_type`, `department`, `sector`, `salary_min`, `salary_max`,
`salary_currency`, `pay_source`, `job_function`, `experience_level`.

The `description` field is intentionally excluded from XML feeds. Consumers
that need descriptions should fetch them directly from `application_link`,
which points at the authoritative ATS page. This keeps the public repo
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
artifact paths, run `scripts/check_publish_allowlist.sh` on the staged result,
then commit/push. The gate checks tracked/staged filenames; it does not inspect
all untracked files or validate every field inside allowed JSON/XML. Exporters
must still select public-safe fields. Update the allowlist and producer together
when introducing an artifact type. The local pre-commit hook adds a manual-use
guard when installed.

## Historical note

`monitor-signals.json` appeared briefly in commits on 2026-04-14 before
being removed. It contained internal scoring signals applied to publicly
observable job counts. The contents are low-severity (no credentials,
no PII, no candidate records), but they did not belong here. The allowlist
gate landed on 2026-04-15 to reject disallowed tracked/staged file paths.

History has not been rewritten. The gate and explicit staging reduce recurrence risk;
exporter review remains necessary for allowed files.

## License

See `LICENSE`.
