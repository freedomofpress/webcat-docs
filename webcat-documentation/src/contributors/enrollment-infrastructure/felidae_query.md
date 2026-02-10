# Query Interface

The WEBCAT ABCI application, Felidae, exposes a read only HTTP API for querying chain state. All endpoints use GET.

| Endpoint | Description |
|----------|-------------|
| `GET /` | List of available endpoints (JSON) |
| `GET /config` | Current chain config |
| `GET /oracles` | List of authorized oracles |
| `GET /canonical/leaves` | Canonical state leaves - used by the WEBCAT browser extension for client-side verification together with the latest published `LightBlock` |
| `GET /admin/votes` | Admin voting queue |
| `GET /admin/pending` | Admin pending queue |
| `GET /oracle/votes` | Oracle voting queue (all domains) |
| `GET /oracle/votes/{domain}` | Oracle voting queue for a specific domain |
| `GET /oracle/pending` | Oracle pending queue (all domains) |
| `GET /oracle/pending/{domain}` | Oracle pending queue for a specific domain |
| `GET /snapshot` | Full WEBCAT list, for monitoring (does not provide enough data for full client-side verification) |
| `GET /snapshot/{domain}` | Hash for a specific domain, for monitoring |
