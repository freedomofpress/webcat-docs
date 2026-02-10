# Testing

Run the standard unit test suite:

```
just test
```

Run the integration tests (spawns a 3-validator network per test):

```
just integration
```

### Block time configuration

Integration tests derive all timing from a configurable block interval (`FELIDAE_BLOCK_TIME_SECS`, default 1). The default keeps CI fast (~2 min). To test with longer block times (e.g. matching production's 60s):

```
just integration 60
```

Or equivalently:

```
FELIDAE_BLOCK_TIME_SECS=60 just integration
```
