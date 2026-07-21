---
name: sqlite-audit
description: >
  Audit SQLite databases, schemas, queries, and application code for performance and operational best practices.
  Use this skill whenever the user mentions SQLite performance, SQLite optimization, SQLite best practices,
  PRAGMA configuration, WAL mode, SQLite indexing strategy, SQLite schema review, or wants to audit any code
  that uses SQLite - even if they don't explicitly say "audit". Also trigger when a user is planning a new
  SQLite-based project and wants guidance on setting it up for production-grade performance.
---

# SQLite Audit

Audit SQLite usage in code, schemas, and configuration for performance and operational correctness.

## How to use this skill

When triggered, do the following:

1. **Gather context** - Read the relevant files (schema definitions, query code, connection setup, migration files). If the user points to specific files, start there. If they say "audit my SQLite usage", scan for `.sql` files, database connection code, and ORM model definitions.

2. **Run the audit** against the checklist below. Not every section applies to every project - skip what's irrelevant and focus on what matters for the user's situation.

3. **Produce the report** in the format described at the bottom.

---

## Audit checklist

### 1. Connection & PRAGMA configuration

The biggest SQLite performance wins come from PRAGMA settings that most projects never configure. Check whether the following are set at connection time (the exact API varies by language, but the PRAGMAs are universal):

| PRAGMA | Recommended | Why |
|---|---|---|
| `journal_mode` | `WAL` | Allows concurrent reads and writes. Without this, readers block writers and vice versa. This is the single most impactful setting. |
| `synchronous` | `NORMAL` | Safe with WAL mode and roughly 3x faster than `FULL`. `OFF` risks corruption on power loss - flag it if you see it. |
| `cache_size` | `-64000` (64 MB) or tuned to workload | Negative values = kilobytes. Default is ~2 MB, which forces frequent disk reads on larger databases. |
| `foreign_keys` | `ON` | Off by default in SQLite. Without this, foreign key constraints are silently ignored - data integrity risk. |
| `busy_timeout` | `5000`+ ms | Without this, concurrent writes immediately return SQLITE_BUSY instead of waiting. Most apps need at least a few seconds. |
| `mmap_size` | `268435456` (256 MB) or appropriate | Memory-mapped I/O can significantly speed up read-heavy workloads. Set to 0 to disable if the database is on a network filesystem. |
| `temp_store` | `FILE` (or omit) | Avoid `MEMORY` - a large VACUUM or complex query can consume enormous RAM. Disk-based temp storage is safer. |
| `auto_vacuum` | `INCREMENTAL` or `FULL` | Without this, deleted data never shrinks the file. `INCREMENTAL` gives more control over when reclamation happens. |
| `wal_autocheckpoint` | `1000` (default) | If set too high, the WAL file grows unboundedly and read performance degrades. If set too low, write throughput drops. Default is usually fine. |

Also check:
- PRAGMAs are set **per connection**, not once at database creation. A common mistake is setting `journal_mode=WAL` in a migration and assuming it persists (it does for `journal_mode`, but most other PRAGMAs reset per connection).
- Connection pooling: if the app uses a pool, PRAGMAs should be set in the pool's connection initialization hook, not just at startup.

### 2. Schema design

**Data types and strictness**
- SQLite uses manifest typing (values have types, not columns) unless you use `STRICT` tables. If data integrity matters, recommend `STRICT` tables or check constraints.
- `INTEGER PRIMARY KEY` is an alias for the rowid and is the fastest possible primary key. Prefer it over `TEXT` primary keys unless there's a strong reason.
- Use `INTEGER` for timestamps (Unix epoch) rather than `TEXT` - it's more compact, sortable, and indexable.
- `WITHOUT ROWID` is beneficial for small lookup tables with non-integer primary keys (like key-value settings tables). Flag opportunities where it applies.

**Indexing**
- Every column that appears in a `WHERE`, `JOIN ON`, or `ORDER BY` clause in a frequent query should have an index (or be part of a composite index).
- Composite indexes: column order matters. The leftmost column should be the one with the highest selectivity (most distinct values) or the one most frequently filtered on alone.
- Partial indexes (`CREATE INDEX ... WHERE condition`) are underused - flag opportunities where a large table is frequently queried with a constant filter (e.g., `WHERE active = 1`).
- Expression indexes (`CREATE INDEX ... ON table(lower(email))`) are useful when queries always apply a function.
- Covering indexes: if a query only needs columns that are all in an index, SQLite can answer it from the index alone without touching the table. Look for hot queries where adding a column or two to the index would make it covering.
- Flag missing indexes on foreign key columns - these are needed for efficient JOIN and CASCADE operations.
- Flag redundant/duplicate indexes (e.g., an index on `(a)` when `(a, b)` already exists).

**Normalization and structure**
- Storing JSON blobs in a column is fine for opaque data, but if the app frequently queries fields inside the JSON, suggest extracting them into proper columns with indexes.
- Flag overly wide tables (30+ columns) that might benefit from vertical partitioning.

### 3. Query performance

**EXPLAIN QUERY PLAN**
- For any query the user flags as slow (or that looks suspicious), run or recommend running `EXPLAIN QUERY PLAN` and interpret the output.
- Watch for `SCAN TABLE` (full table scan) on large tables - this usually means a missing index.
- `USE TEMP B-TREE` in ORDER BY means the sort can't use an index, which is expensive for large result sets.
- `SEARCH TABLE ... USING INDEX` is good - it means an index is being used.

**Common anti-patterns**
- `SELECT *` in application code - fetching unused columns wastes I/O and memory.
- `LIKE '%term%'` - leading wildcards can't use indexes. Suggest FTS5 (full-text search) if this pattern appears in search features.
- N+1 queries: looping through results and issuing a query per row instead of using a JOIN or subquery.
- Not using parameterized queries (both a performance and security issue - prepared statements are cached).
- Large `IN (...)` lists - if more than ~100 values, suggest using a temporary table or CTE instead.
- Unbounded queries without `LIMIT` - fetching millions of rows when only a page is needed.
- `COUNT(*)` on large tables without a covering index - suggest maintaining a count in a separate table if this is a hot path.

**Write performance**
- Bulk inserts without an explicit transaction: SQLite wraps each statement in its own transaction by default. 1000 individual inserts = 1000 fsync calls. Wrapping them in `BEGIN...COMMIT` makes it one fsync.
- Flag any loop that does INSERT/UPDATE without a surrounding transaction.
- For very large bulk loads, suggest temporarily disabling indexes, loading data, then rebuilding indexes.

### 4. Operational practices

**Backups**
- Check if backups use the SQLite Online Backup API or `.backup` command rather than just copying the file (copying a live database can produce a corrupt backup if a write is in progress).
- For WAL mode databases, a backup must include both the `.db` file and the `-wal` and `-shm` files, or use the backup API which handles this.

**VACUUM and maintenance**
- `PRAGMA optimize` should run periodically (ideally before closing each connection, or every few hours for long-lived connections). It updates internal statistics that the query planner uses.
- `VACUUM` rebuilds the entire database file. It's expensive but useful after large deletes. With `auto_vacuum` enabled, manual VACUUM is rarely needed.
- `PRAGMA integrity_check` should be part of any health-check or monitoring setup.

**Concurrency**
- SQLite supports one writer at a time. If the application needs high write concurrency, flag this and suggest strategies: write queuing, batching writes, or considering whether SQLite is the right fit.
- In WAL mode, reads don't block writes and writes don't block reads - but only if the application doesn't hold long-lived read transactions (which prevent WAL checkpointing and cause the WAL file to grow).
- Flag any pattern where a read transaction is held open for a long time (e.g., iterating over a cursor while doing unrelated work).

**File and deployment**
- Database file on a network filesystem (NFS, SMB) is unreliable and can corrupt. Flag it.
- Database file permissions: should not be world-readable if it contains sensitive data.
- The `-journal`, `-wal`, and `-shm` files must be on the same filesystem as the database.

---

## Report format

Structure findings as follows:

```
# SQLite Audit: [project/file name]

## Critical issues
Items that risk data loss, corruption, or severe performance problems.
Each item: what's wrong, where it is, how to fix it.

## Performance improvements
Ordered by estimated impact (highest first).
Each item: current behavior, why it's slow, recommended change.

## Good practices already in place
Brief acknowledgment of things done correctly - this builds trust and
helps the user understand what NOT to change.

## Recommendations summary
A prioritized checklist the user can work through, from most impactful
to least.
```

Keep findings specific - reference exact file paths, line numbers, table names, and queries. Vague advice ("consider adding indexes") is not useful. Instead: "Add an index on `orders.customer_id` - this column appears in a WHERE clause at `app/queries.py:47` and the table has 500k+ rows."

If you don't have enough context to assess something (e.g., you can see the schema but not the queries), say so and tell the user what you'd need to complete the audit.
