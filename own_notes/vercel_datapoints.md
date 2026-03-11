# Vercel Usage Metrics

## Usage Table

| Metric | Current Usage | Pro Limit | Business Limit |
|--------|---------------|-----------|----------------|
| Fast Data Transfer | 11.91 GB | 100 GB | 1 TB |
| Fast Origin Transfer | 14.29 GB | 10 GB | 100 GB |
| Edge Requests | 233K | 1M | 10M |
| Edge Request CPU Duration | 13s | 1h | 1h |
| Microfrontends Routing | 0 | 50K | - |
| ISR Reads | 1.4K | 1M | 10M |
| ISR Writes | 52 | 200K | 2M |
| Function Invocations | 252K | 1M | 1M |
| Function Duration | 0 GB-Hrs | 100 GB-Hrs | 1,000 GB-Hrs |
| Fluid Provisioned Memory | 6.7 GB-Hrs | 360 GB-Hrs | 1,440 GB-Hrs |
| Fluid Active CPU | 2h 42m | 4h | 16h |
| Edge Function Execution Units | 0 | 500K | 1M |
| Edge Middleware Invocations | 0 | 1M | 1M |
| Edge Config Reads | 0 | - | - |
| Edge Config Writes | 0 | - | - |
| Artifacts | 0 B | - | - |
| Blob Data Storage | 0 B | 1 GB | 5 GB |
| Blob Simple Operations | 0 | 10K | 100K |
| Blob Advanced Operations | 0 | 2K | 10K |
| Blob Data Transfer | 0 B | 10 GB | 100 GB |
| Cron Job Invocations | 0 | - | - |
| Drain Volume | 0 B | - | - |
| Web Analytics Events | 0 | 50K | 100K |
| Speed Insights Data Points | 0 | 10K | - |
| Monitoring | 0 | - | - |
| Observability Events | 0 | - | - |
| Image Optimization - Source Images | 0 | 1,000 | 5,000 |
| Image Optimization - Transformations | 0 | 5K | 10K |
| Image Optimization - Cache Reads | 0 | 300K | 600K |
| Image Optimization - Cache Writes | 0 | 100K | 200K |
| Private Data Transfer | 0 B | - | - |
| Sandbox Creations | 0 | 5K | - |
| Sandbox Active CPU | 0s | 5h | - |
| Sandbox Provisioned Memory | 0 GB-Hrs | 420 GB-Hrs | - |
| Sandbox Data Transfer | 0 B | 20 GB | - |
| Sandbox Storage | 0 B | 15 GB | - |

---

## Optimization Strategies by Category

### Data Transfer Optimization

**Fast Data Transfer** (Outbound to users)
- Enable compression on responses (gzip, brotli) - reduces payload size by 60-80%
- Serve images at appropriate sizes (lazy load, responsive images)
- Use HTTP caching headers aggressively (`Cache-Control: public, max-age=31536000` for immutable assets)
- Implement request deduplication on the client side
- Consider image optimization services for on-the-fly resizing

**Fast Origin Transfer** (Data pulled during builds/operations)
- Cache external API responses locally during static generation
- Batch API requests to minimize round trips
- Only fetch data needed for static pages; defer dynamic data to client-side loading
- Use webhooks instead of polling for data updates
- Compress responses from origin services if possible
- For static site generators: pre-fetch and cache all dependencies before build

**Private Data Transfer**
- Keep internal services on Vercel's infrastructure (avoid egress to external services)
- Use environment variables for configuration instead of fetching from external config servers
- Cache database query results at the edge when possible

### Compute Optimization

**Edge Requests**
- Implement response caching at the edge to reduce repeated processing
- Use 304 Not Modified responses for unchanged content
- Combine multiple small requests into fewer batch requests
- Consider if all requests need to hit your origin or if some can be served from cache

**Edge Request CPU Duration**
- Optimize middleware execution - only run necessary middleware per route
- Use efficient algorithms in hot paths
- Cache expensive computations (regex patterns, template compilation)
- Move CPU-heavy work to build time rather than request time
- Use native modules instead of pure JavaScript for performance-critical code

**Function Invocations**
- Reuse database connections across invocations (connection pooling)
- Implement request batching where applicable
- Use function caching to avoid recomputation
- Cold start optimization: keep dependencies lean, use bundling tools
- Consider consolidating multiple small functions into fewer larger ones

**Function Duration** (GB-seconds)
- Reduce function memory footprint (use lightweight libraries, remove unnecessary dependencies)
- Optimize database queries (add indexes, use select specific columns)
- Use async operations to reduce blocking time
- Cache computation results across function calls
- Profile functions to identify bottlenecks before optimization

### Persistent Compute (Fluid)

**Fluid Provisioned Memory & Active CPU**
- Only use persistent runtimes when necessary (e.g., background jobs, WebSocket connections)
- Right-size memory allocations based on actual needs
- Implement auto-scaling based on demand
- Stop instances when not in use
- Consider alternative approaches (scheduled functions, event-driven architecture)

### Incremental Static Regeneration

**ISR Reads/Writes**
- Extend cache TTL for pages that change infrequently
- Use background regeneration during off-peak hours
- Only regenerate pages when source data actually changes
- Implement smart invalidation (only regenerate affected pages)

### Storage & Blobs

**Blob Data Storage**
- Set lifecycle policies to delete old/unused blobs
- Compress data before storing
- Use appropriate storage tier (hot vs. cold storage)

**Blob Operations** (Simple & Advanced)
- Batch read/write operations when possible
- Cache frequently accessed blobs
- Use CDN for frequently served blobs

**Artifacts**
- Clean up old build artifacts automatically
- Compress artifacts before storage
- Only store essential build outputs

### Image Processing

**Image Optimization**
- Enable format negotiation (WebP for modern browsers)
- Set appropriate quality levels for different image types
- Cache transformed images aggressively
- Pre-generate common transformation sizes at build time
- Monitor source image quality - don't upload unnecessarily high resolution

### Monitoring & Analytics

**Web Analytics Events**
- Sample events in high-traffic periods (track 100% in low traffic, 10% in high traffic)
- Disable analytics for internal/bot traffic using filters
- Only track essential events, not every interaction
- Batch event submissions to reduce request count

**Speed Insights Data Points**
- Sample Real User Monitoring (RUM) at lower percentages in production
- Use synthetic monitoring for consistent baselines
- Filter out bot/crawler traffic

**Edge Config Reads & Writes**
- Cache config values at startup rather than reading per request
- Use longer cache TTLs for rarely-changing configuration
- Batch config reads when possible
- Minimize write frequency by only updating when values actually change
- Use bulk update operations instead of individual writes
- Implement optimistic UI updates with eventual consistency

**Monitoring & Observability Events**
- Set appropriate log levels (ERROR/WARN in production, DEBUG only when troubleshooting)
- Sample trace data rather than capturing 100% (use 1-10% sampling)
- Filter out noisy/low-value events
- Aggregate metrics locally before sending to observability platform
- Use structured logging to reduce event payload sizes

### Edge Functions & Middleware

**Edge Function Execution Units**
- Keep edge functions minimal - they run on every request globally
- Avoid heavy computation at the edge (defer to serverless functions or origin)
- Cache results when possible to avoid repeated executions
- Use edge functions only for lightweight tasks (auth checks, redirects, header manipulation)
- Monitor execution unit consumption to identify inefficient functions

**Edge Middleware Invocations**
- Only run middleware on routes that need it (use matcher patterns in config)
- Keep middleware logic simple and fast
- Avoid external API calls from middleware when possible
- Use edge config or environment variables instead of fetching config
- Chain middleware efficiently to avoid redundant processing

### Microfrontends & Architecture

**Microfrontends Routing**
- Use path-based routing instead of subdomain routing where possible
- Implement client-side routing for microfrontend navigation to reduce server hits
- Cache microfrontend manifests aggressively
- Lazy load microfrontends only when needed
- Use shared dependencies to reduce bundle duplication

### Scheduled Tasks

**Cron Job Invocations**
- Adjust cron schedules to minimum required frequency
- Batch operations within single cron execution instead of multiple jobs
- Use longer intervals for non-critical tasks
- Implement idempotency to safely retry failed jobs without duplication
- Consider event-driven alternatives where cron polling is unnecessary

### Sandbox Optimization

**Sandbox Creations**
- Reuse existing sandboxes instead of creating new ones
- Implement sandbox pooling for frequently used configurations
- Clean up idle sandboxes promptly
- Use long-lived sandboxes for development, ephemeral for CI/CD

**Sandbox Active CPU & Provisioned Memory**
- Right-size sandbox resources based on actual workload
- Implement auto-shutdown for idle sandboxes
- Use development mode sandboxes only when actively developing
- Monitor resource utilization to identify over-provisioned sandboxes

**Sandbox Data Transfer & Storage**
- Minimize data sync between local and sandbox environments
- Use .vercelignore to exclude unnecessary files from sandbox
- Clean up temporary files and logs regularly
- Compress large files before transferring to sandboxes

### Advanced Features

**Drain Volume**
- Implement graceful shutdown handlers to reduce drain volume
- Use health checks to route traffic away before shutdown
- Keep in-flight request processing time minimal
- Consider connection draining timeouts based on actual request duration

**Blob Data Transfer**
- Use CDN caching for frequently accessed blobs
- Implement client-side caching with appropriate cache headers
- Compress blobs before storage to reduce transfer size
- Use range requests for large files instead of full downloads
- Consider edge locations when storing blobs to minimize transfer distances

### Scaling & Limits

**General Strategy**
- Monitor metrics regularly to catch growth before hitting limits
- Upgrade plan tier when approaching limits (sometimes cost-effective vs. optimization effort)
- Implement feature flags to disable expensive features in high-traffic periods
- Auto-scale resources based on demand patterns
- Use Vercel's built-in performance monitoring to identify optimization opportunities




