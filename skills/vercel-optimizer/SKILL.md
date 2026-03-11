# Vercel Optimizer

**Skill Name**: vercel-optimizer
**Description**: Comprehensive guide to reducing origin transfer and optimizing Flask applications for deployment on Vercel

## Overview

This skill provides 14 optimization strategies for reducing data transfer from your Flask origin server, improving performance, reducing costs, and enhancing scalability.

## Optimization Strategies

### 1. Response Compression (Smart Implementation)

Only compress what's worthwhile using Flask-Compress with intelligent configuration:
- Compress min size: 1KB
- Compression level: 4 (balanced)
- Target MIME types: HTML, JSON, CSS, JavaScript
- Exclude already-compressed formats

```python
from flask_compress import Compress

app.config.update({
    'COMPRESS_MIN_SIZE': 1024,
    'COMPRESS_LEVEL': 4,
    'COMPRESS_MIMETYPES': [
        'text/html',
        'application/json',
        'text/css',
        'application/javascript'
    ],
    'COMPRESS_EXCLUDE': ['.jpg', '.png', '.gif', '.mp4', '.pdf', '.zip']
})
```

### 2. Efficient Data Serialization

Select only needed database fields instead of returning all columns:

```python
# Inefficient - all columns
users = User.query.all()
return jsonify([user.to_dict() for user in users])

# Efficient - specific fields only
users = User.query.with_entities(User.id, User.name, User.email).all()
return jsonify([
    {'id': u.id, 'n': u.name, 'e': u.email}
    for u in users
])
```

### 3. Response Pagination

Implement database-level pagination:

```python
@app.route('/api/users')
def get_users():
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 50, type=int)

    pagination = User.query.paginate(page=page, per_page=per_page)

    return jsonify({
        'users': [u.to_dict() for u in pagination.items],
        'pagination': {
            'page': pagination.page,
            'pages': pagination.pages,
            'total': pagination.total,
            'next': pagination.next_num if pagination.has_next else None,
            'prev': pagination.prev_num if pagination.has_prev else None
        }
    })
```

### 4. GraphQL-like Field Selection

Allow clients to specify which fields they need:

```python
@app.route('/api/flexible')
def flexible_response():
    fields = request.args.get('fields', 'id,name').split(',')

    query = User.query
    selected_fields = []
    for field in fields:
        if hasattr(User, field):
            selected_fields.append(getattr(User, field))

    if selected_fields:
        query = query.with_entities(*selected_fields)

    results = query.limit(100).all()
    return jsonify(results)
```

### 5. Response Caching at Multiple Levels

Cache full responses and components separately using Redis:

```python
from flask_caching import Cache

cache = Cache(config={'CACHE_TYPE': 'redis', 'CACHE_REDIS_URL': 'redis://localhost:6379/0'})

@app.route('/expensive-query')
@cache.cached(timeout=300, query_string=True)
def expensive():
    data = complex_calculation()
    return jsonify(data)

@app.route('/composite')
def composite():
    users = cache.get('all_users') or fetch_users()
    stats = cache.get('user_stats') or calculate_stats()
    return jsonify({'users': users[:10], 'stats': stats})
```

### 6. Binary Protocols Instead of JSON

Use MessagePack for more compact serialization:

```python
import msgpack
from flask import Response

@app.route('/api/binary')
def binary_data():
    data = {'large': [list(range(1000)) for _ in range(100)]}
    packed = msgpack.packb(data, use_bin_type=True)

    return Response(
        packed,
        content_type='application/msgpack',
        headers={'X-Data-Format': 'msgpack'}
    )
```

### 7. Delta Updates / Partial Responses

Only return changed data on subsequent requests:

```python
@app.route('/api/delta')
def delta_updates():
    last_modified = request.headers.get('If-Modified-Since')

    if last_modified:
        changes = get_changes_since(last_modified)
        return jsonify({
            'delta': changes,
            'full_sync': False
        })

    return jsonify({'full_sync': True, 'data': get_all_data()})
```

### 8. Content Delivery Network (CDN) Integration

Set proper cache headers for CDN:

```python
@app.after_request
def set_cdn_headers(response):
    if response.status_code == 200:
        if request.path.startswith('/api/static/'):
            response.headers['Cache-Control'] = 'public, max-age=86400'
            response.headers['CDN-Cache-Control'] = 'max-age=86400'
        elif request.path.startswith('/api/'):
            response.headers['Cache-Control'] = 's-maxage=60, stale-while-revalidate=300'

    return response
```

### 9. Response Minification

Remove whitespace from JSON responses (~30% smaller):

```python
import json

def minify_json(data):
    return json.dumps(data, separators=(',', ':'))

@app.route('/api/minified')
def minified():
    data = {'large': [[i for i in range(100)] for _ in range(100)]}

    response = app.response_class(
        response=minify_json(data),
        status=200,
        mimetype='application/json'
    )

    return response
```

### 10. Protocol Buffers for Large APIs

Use Protocol Buffers for highly efficient binary serialization:

```python
# user.proto
"""
syntax = "proto3";
message User {
    int32 id = 1;
    string name = 2;
    string email = 3;
}
"""

# app.py
import user_pb2
from flask import Response

@app.route('/api/protobuf')
def protobuf_response():
    users = user_pb2.Users()

    for db_user in User.query.limit(100):
        u = users.users.add()
        u.id = db_user.id
        u.name = db_user.name
        u.email = db_user.email

    return Response(
        users.SerializeToString(),
        content_type='application/x-protobuf'
    )
```

### 11. Connection Keep-Alive & HTTP/2

Use production servers with keep-alive support:

```python
from gevent.pywsgi import WSGIServer

if __name__ == '__main__':
    http_server = WSGIServer(('0.0.0.0', 5000), app)
    http_server.serve_forever()

# Or with gunicorn:
# gunicorn --worker-class gevent --workers 4 --keepalive 5 app:app
```

### 12. Data Deduplication in Arrays

Use columnar format to reduce repeated structure:

```python
@app.route('/api/optimized-list')
def optimized_list():
    users = User.query.all()

    keys = ['id', 'name', 'email']
    values = []

    for user in users:
        values.append([user.id, user.name, user.email])

    return jsonify({
        'keys': keys,
        'values': values,
        '_meta': {'format': 'columnar'}
    })
```

### 13. Streaming Responses for Large Data

Stream large responses instead of buffering:

```python
from flask import stream_with_context, Response
import json

@app.route('/api/stream')
def stream_large():
    def generate():
        yield '['

        first = True
        for user in User.query.yield_per(100):
            if not first:
                yield ','
            first = False

            yield json.dumps({
                'id': user.id,
                'n': user.name
            })

        yield ']'

    return Response(
        stream_with_context(generate()),
        content_type='application/json'
    )
```

### 14. Load Testing & Monitoring

Add metrics middleware to identify bottlenecks:

```python
import time

@app.before_request
def start_timer():
    request.start_time = time.time()

@app.after_request
def log_response(response):
    size = len(response.get_data())
    duration = time.time() - request.start_time

    if size > 1024 * 100:
        app.logger.warning(
            f'Large response: {request.path} - {size/1024:.1f}KB - {duration:.3f}s'
        )

    response.headers['X-Response-Size'] = size
    response.headers['X-Response-Time'] = f'{duration:.3f}s'

    return response
```

## Implementation Priority

1. **First**: Add pagination to all list endpoints
2. **Second**: Implement response caching (Redis/Memcached)
3. **Third**: Add compression with sensible defaults
4. **Fourth**: Optimize database queries (select only needed fields)
5. **Fifth**: Set proper CDN/cache headers
6. **Sixth**: Consider binary protocols for large data transfers
7. **Seventh**: Implement streaming for very large responses
8. **Eighth**: Add monitoring to identify bottlenecks

## Quick Wins for Immediate Reduction

```python
@app.after_request
def optimize_responses(response):
    # 1. Minify JSON responses in production
    if (app.config['ENV'] == 'production' and
        response.content_type == 'application/json' and
        len(response.get_data()) > 1024):

        data = json.loads(response.get_data())
        response.set_data(json.dumps(data, separators=(',', ':')))

    # 2. Always set content-length header
    response.headers['Content-Length'] = len(response.get_data())

    return response
```

## Key Insight

The most effective strategy is often **sending less data** rather than **compressing what you send**. Focus on API design, efficient queries, and intelligent caching first, then add compression as a complementary optimization.
