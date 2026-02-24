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
| `GET /enrollment/votes` | Oracle enrollment voting queue (all domains) |
| `GET /enrollment/votes/{domain}` | Oracle enrollment voting queue for a specific domain |
| `GET /enrollment/pending` | Oracle enrollment pending queue (all domains) |
| `GET /enrollment/pending/{domain}` | Oracle enrollment pending queue for a specific domain |
| `GET /snapshot` | Full WEBCAT list, for monitoring (does not provide enough data for full client-side verification) |
| `GET /snapshot/{domain}` | Hash for a specific domain, for monitoring |
