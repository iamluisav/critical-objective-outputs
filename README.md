# critical-objective-outputs

Public publish surface for sanitized job-feed artifacts from the
[Critical Objective](https://criticalobjective.com) pipeline.

This repo is write-only from the pipeline side. It is not a development
repo, it takes no pull requests, and it is not a place to add new
artifact types without updating the allowlist below.

## What's here

| File | Shape | Purpose |
| --- | --- | --- |
| `jobs.json` | JSON array | Slim job records (no descriptions) for website and board consumers |
| `feed_greenhouse.xml` | XML | Greenhouse-sourced jobs for board ingestion (description stripped) |
| `feed_ashby.xml` | XML | Ashby-sourced jobs for board ingestion (description stripped) |
| `feed_lever.xml` | XML | Lever-sourced jobs for board ingestion (description stripped) |

All records carry only publicly observable fields: `job_id`, `job_title`,
`company_name`, `company_url`, `company_logo_url`, `job_url`,
`application_link`, `publish_date`, `job_type`, `location`,
`location_type`, `department`, `sector`.

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

Two producers write to this repo:

1. **CI** — `critical-objective-feed/.github/workflows/build-feed.yml`
   publishes `feed_*.xml` and `jobs.json` on its daily schedule.
2. **No other producer.** The local `daily_run.sh` was removed from the
   publish path on 2026-04-15.

Both producers run `scripts/check_publish_allowlist.sh` before push. The
gate rejects anything not on the explicit allowlist inside that script.
To accept a new artifact here, update the allowlist in the same commit
that introduces the producer. No one-off exceptions.

## Historical note

`monitor-signals.json` appeared briefly in commits on 2026-04-14 before
being removed. It contained internal scoring signals applied to publicly
observable job counts. The contents are low-severity (no credentials,
no PII, no candidate records), but they did not belong here. The allowlist
gate landed on 2026-04-15 to make that class of leak structurally
impossible.

History has not been rewritten. The gate prevents recurrence; that is the
correct long-term fix.

## License

See `LICENSE`.
