Code source of the original project: https://github.com/georchestra/analytics

See https://docs.georchestra.org/analytics/technical_guides/installation/ for the documentation.

## Database migrations

Starting with Analytics 2.2.0, the chart uses an Alembic Job to initialize and
upgrade the database schema. The migration Job is created for every Helm release
revision, upgrades the schema to the configured target and synchronizes the
TimescaleDB access-log policies.

Database migrations are disabled by default. Enable them explicitly after
reviewing the target database and taking any required backup:

```yaml
cli:
  migrations:
    enabled: true
    targetRevision: head
```

For the first upgrade of an existing pre-Alembic installation, enable safe
baseline adoption:

```yaml
cli:
  migrations:
    existingDatabase:
      enabled: true
      baselineRevision: "0001"
```

`bootstrap-existing` validates the expected schema before stamping revision
`0001` and skips databases that are already versioned. Disable this option again
after the first successful adoption.

Vector and the CLI CronJobs use an init container to wait for
`cli.migrations.targetRevision`. This prevents ingestion and aggregation from
starting against an outdated schema. When migrations are enabled, the legacy
SQL entrypoint ConfigMap is not mounted into the built-in TimescaleDB instance;
Alembic is the only schema owner.

The built-in database defaults to TimescaleDB 2.30.2 on PostgreSQL 18. Restores
that contain TimescaleDB 2.26.1 internal catalogs must first be restored with
2.26.1 and upgraded to 2.30.2 before deploying the Alembic migration.

The chart requires an Analytics CLI image containing the database commands. The
default is `georchestra/analytics-cli:2.2.0`; override
`cli.image.repository`, `cli.image.tag` and `cli.image.pullPolicy` while testing
an unpublished build.

Setting `cli.migrations.enabled: false` restores the legacy init-script behavior
for compatibility and omits the aggregation CronJob, which depends on the
Alembic-managed durable queue. It is not recommended for new installations.

## Incremental OGC aggregation

The chart adds a recovery CronJob for the durable OGC aggregation queue:

```yaml
cli:
  migrations:
    enabled: true
  aggregation:
    enabled: true
    schedule: "15 * * * *"
    batchSize: 100
```

Aggregation is disabled by default and must be enabled explicitly after the
Alembic migration has created the persistent stores and durable queue.

The regular `buffer2db` process also drains the queue after ingestion. The
additional CronJob retries pending buckets and processes work queued by other
ingestion commands. It does not disable or remove legacy continuous aggregates;
those operations remain part of the documented, manually validated cutover.
