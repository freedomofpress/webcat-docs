# Browser Extension

> We are currently working on this section. The WEBCAT extension source code has a good amount of comments, and can be a a starting point in the meantime.

## Testing
### Information

The extension provides some testing infrastructure. When built and packaged for testing, some functionality is mocked. As such, testing mode is not currently able to cover all production cases.

Specifically, the mocked parts are:

* The *enrollment list* update system
* The local lookup of enrollment metadata

The reason for this is to provide an easy harness to generate enrollment and manifest test cases dynamically, without enrolling them in the *enrollment system* and waiting for it to update.

In the future, if necessary, we could support both production and testing modes simultaneously.

Currently, the extension can be built and packaged using:

```
make package-test
```

Under the hood, `make` invokes:

```
TESTING=true npm run build
```

When that is the case, the following is triggered in `vite.config.ts`:

```ts
resolve: isTesting
  ? {
      alias: {
        "./webcat/db": path.resolve(__dirname, "./src/mocks/db.mock.ts"),
        "./validators": path.resolve(
          __dirname,
          "./src/mocks/validators.mock.ts",
        ),
        "./update": path.resolve(__dirname, "./src/mocks/update.mock.ts"),
      },
    }
  : {},
```

In practice, a few functions in the listed files are replaced with mocked versions when compiled for testing.

Namely:

* The `validators` hook disables the enforcement of HTTPS for non-onion websites (allowing the usage of plaintext `127.0.0.1`)
* The `update` hook disables remote updates, and locally updates the "last updated" date
* The `db` hook asynchronously fetches `http://127.0.0.1:1234/testing-list`, and imports that as the enrollment source of truth

The file `testing-list` is expected to be structured in the following format:

```json
{
  "<hostname>": "<hex enrollment hash>"
}
```

Since policies are per host (and not per origin, meaning that one cannot specify `host:port` for different ports), for the sake of testing it is useful to use hostnames that always resolve locally.

By default, the `.localhost` TLD is defined as a special-use domain and acts as a wildcard that resolves to `127.0.0.1`. This makes it convenient for local testing without modifying `/etc/hosts`.

### Example

To test `webcat-demo-test` locally one has to:

* Clone the repository
* Create the `testing-list` file in the same folder
* Use the WEBCAT CLI to generate a hash of the enrollment information:

  ```
  node webcat-cli/dist/cli.cjs enrollment hash .well-known/webcat/enrollment.json
  ```
* Add the following to `testing-list`:

  ```json
  {
    "webcat-testapp.localhost": "<enrollment hex hash>"
  }
  ```
* Start an HTTP server that:

  * Listens on port `1234`
  * Serves the CSP header as specified in the manifest
  * Serves `testing-list` at `/testing-list`
* Install the extension built using `make package-test` via `about:debugging`
* Visit:

  ```
  http://webcat-testapp.localhost:1234
  ```
