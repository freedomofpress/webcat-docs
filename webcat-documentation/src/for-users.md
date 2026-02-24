# For Users

## Getting Started

Users can install the WEBCAT extension via the Mozilla Add-ons Store (AMO). Firefox is currently the only supported browser.

👉 **[Get the extension](https://addons.mozilla.org/en-US/firefox/addon/webcat/)**

The extension is currently untested on Firefox for Android and is known not to work on Tor Browser.

Once installed, the extension runs autonomously in the background without any further configuration.

### Successful Validation

When visiting a successfully validated WEBCAT-enrolled website, the following icon will appear on the top-right of the URL bar:

![Screenshot of element.demo.webcat.tech with the icon in the url bar highlighted.](./screenshots/extension-success.jpg)

You can test the extension on the following demo websites:

* [test.demo.webcat.tech](https://test.demo.webcat.tech)
* [element.demo.webcat.tech](https://element.demo.webcat.tech)

### Validation or Integrity Errors

If an integrity or validation error occurs, the user will be redirected to a dedicated error page.

The error page displays a specific error code indicating at which stage of the validation process the issue occurred.

![Screenshot of enrollment-error.demo.webcat.tech being blocked.](./screenshots/extension-enrollment-error.jpg)

You can test various validation and integrity error cases at:

* [enrollment-error.demo.webcat.tech](https://enrollment-error.demo.webcat.tech)
  → Should trigger an enrollment error

* [manifest-error.demo.webcat.tech](https://manifest-error.demo.webcat.tech)
  → Should trigger a manifest validation error

* [integrity-error.demo.webcat.tech](https://integrity-error.demo.webcat.tech)
  → Links on the homepage should trigger file integrity errors

### Error Codes

Below is a reference table describing all WEBCAT error codes.

Each error code indicates the validation stage and failure reason. As an end user, you might want to report any of these errors to the website administrators, if it is safe to do so.

#### Fetch Errors

| Error Code                                | Component | Description                                                             |
| ----------------------------------------- | --------- | ----------------------------------------------------------------------- |
| `ERR_WEBCAT_BUNDLE_FETCH_PROMISE_MISSING` | Fetch     | Internal fetch promise missing when attempting to retrieve bundle data. |
| `ERR_WEBCAT_BUNDLE_FETCH_ERROR`           | Fetch     | Failed to fetch required enrollment or manifest data from the website.  |


#### Bundle Errors

| Error Code                             | Component | Description                                                     |
| -------------------------------------- | --------- | --------------------------------------------------------------- |
| `ERR_WEBCAT_BUNDLE_MALFORMED`          | Bundle    | The WEBCAT bundle structure is invalid or improperly formatted. |
| `ERR_WEBCAT_BUNDLE_MISSING_ENROLLMENT` | Bundle    | Enrollment information is missing from the bundle.              |
| `ERR_WEBCAT_BUNDLE_MISSING_MANIFEST`   | Bundle    | Manifest information is missing from the bundle.                       |
| `ERR_WEBCAT_BUNDLE_MISSING_SIGNATURES` | Bundle    | Signatures are missing from the manifest.              |


#### Enrollment Errors

| Error Code                                    | Component             | Description                                               |
| --------------------------------------------- | --------------------- | --------------------------------------------------------- |
| `ERR_WEBCAT_ENROLLMENT_TYPE_INVALID`          | Enrollment            | Enrollment type is invalid or unsupported.                |
| `ERR_WEBCAT_ENROLLMENT_MISMATCH`              | Enrollment            | Enrollment information does not match the expected value.    |
| `ERR_WEBCAT_ENROLLMENT_POLICY_MALFORMED`      | Enrollment (Sigsum)   | The enrollment policy is malformed.                       |
| `ERR_WEBCAT_ENROLLMENT_POLICY_LENGTH`         | Enrollment (Sigsum)   | The enrollment policy exceeds allowed limits.             |
| `ERR_WEBCAT_ENROLLMENT_SIGNERS_MALFORMED`     | Enrollment (Sigsum)   | The list of signers is malformed.                         |
| `ERR_WEBCAT_ENROLLMENT_SIGNERS_EMPTY`         | Enrollment (Sigsum)   | No valid signers are defined in the enrollment.           |
| `ERR_WEBCAT_ENROLLMENT_SIGNERS_KEY_MALFORMED` | Enrollment (Sigsum)   | A signer's public key is invalid or improperly formatted. |
| `ERR_WEBCAT_ENROLLMENT_THRESHOLD_MALFORMED`   | Enrollment (Sigsum)   | The signature threshold value is malformed.               |
| `ERR_WEBCAT_ENROLLMENT_THRESHOLD_IMPOSSIBLE`  | Enrollment (Sigsum)   | The threshold cannot be satisfied with the given signers. |
| `ERR_WEBCAT_ENROLLMENT_LOGS_MALFORMED`        | Enrollment (Sigsum)   | Transparency log configuration is malformed.              |
| `ERR_WEBCAT_ENROLLMENT_MAX_AGE_MALFORMED`     | Enrollment            | The max-age parameter is invalid.                         |
| `ERR_WEBCAT_ENROLLMENT_TRUSTED_ROOT_MISSING`  | Enrollment (Sigstore) | Trusted root information is missing.                      |
| `ERR_WEBCAT_ENROLLMENT_CLAIMS_MISSING`        | Enrollment (Sigstore) | Required OIDC claims are missing.                         |
| `ERR_WEBCAT_ENROLLMENT_CLAIMS_MALFORMED`      | Enrollment (Sigstore) | OIDC claims are malformed.                                |
| `ERR_WEBCAT_ENROLLMENT_CLAIMS_EMPTY`          | Enrollment (Sigstore) | No OIDC claims were provided.                             |


#### Manifest Errors

| Error Code                                          | Component | Description                                  |
| --------------------------------------------------- | --------- | -------------------------------------------- |
| `ERR_WEBCAT_MANIFEST_VERIFY_FAILED`                 | Manifest  | Manifest signature verification failed.      |
| `ERR_WEBCAT_MANIFEST_THRESHOLD_UNSATISFIED`         | Manifest  | Signature threshold was not satisfied.       |
| `ERR_WEBCAT_MANIFEST_MISSING_TIMESTAMP`             | Manifest  | Required timestamp is missing.               |
| `ERR_WEBCAT_MANIFEST_TIMESTAMP_VERIFY_FAILED`       | Manifest  | Timestamp verification failed.               |
| `ERR_WEBCAT_MANIFEST_EXPIRED`                       | Manifest  | Manifest has expired based on max-age.       |
| `ERR_WEBCAT_MANIFEST_FILES_MISSING`                 | Manifest  | Required file entries are missing.           |
| `ERR_WEBCAT_MANIFEST_DEFAULT_INDEX_MISSING`         | Manifest  | Default index configuration missing.         |
| `ERR_WEBCAT_MANIFEST_DEFAULT_INDEX_MISSING_FILE`    | Manifest  | Default index file not found in manifest.    |
| `ERR_WEBCAT_MANIFEST_DEFAULT_FALLBACK_MISSING`      | Manifest  | Default fallback configuration missing.      |
| `ERR_WEBCAT_MANIFEST_DEFAULT_FALLBACK_MISSING_FILE` | Manifest  | Default fallback file not found in manifest. |
| `ERR_WEBCAT_MANIFEST_DEFAULT_CSP_MISSING`           | Manifest  | Default Content Security Policy missing.     |
| `ERR_WEBCAT_MANIFEST_DEFAULT_CSP_INVALID`           | Manifest  | Default CSP is invalid.                      |
| `ERR_WEBCAT_MANIFEST_EXTRA_CSP_INVALID`             | Manifest  | Additional CSP directive invalid.            |
| `ERR_WEBCAT_MANIFEST_EXTRA_CSP_MALFORMED`           | Manifest  | Additional CSP directive malformed.          |
| `ERR_WEBCAT_MANIFEST_WASM_MISSING`                  | Manifest  | WebAssembly information missing.     |


#### CSP Errors

| Error Code                    | Component | Description                                           |
| ----------------------------- | --------- | ----------------------------------------------------- |
| `ERR_WEBCAT_CSP_PARSE_FAILED` | CSP       | Failed to parse Content Security Policy header.       |
| `ERR_WEBCAT_CSP_MISMATCH`     | CSP       | CSP header does not match the manifest specification. |

#### Header Errors

| Error Code                                | Component | Description                                               |
| ----------------------------------------- | --------- | --------------------------------------------------------- |
| `ERR_WEBCAT_HEADERS_MISSING`              | Headers   | Required WEBCAT headers are missing.                      |
| `ERR_WEBCAT_HEADERS_LOCATION_EXTERNAL`    | Headers   | Redirected to an external location not allowed by policy. |
| `ERR_WEBCAT_HEADERS_FORBIDDEN`            | Headers   | Forbidden header configuration detected.                  |
| `ERR_WEBCAT_HEADERS_DUPLICATE`            | Headers   | Duplicate critical headers detected.                      |
| `ERR_WEBCAT_HEADERS_MISSING_CRITICAL`     | Headers   | Missing required security-critical headers.               |
| `ERR_WEBCAT_HEADERS_ENROLLMENT_MALFORMED` | Headers   | Enrollment header is malformed.                           |


#### URL Errors

| Error Code                   | Component | Description                                      |
| ---------------------------- | --------- | ------------------------------------------------ |
| `ERR_WEBCAT_URL_UNSUPPORTED` | URL       | The visited URL scheme is unsupported by WEBCAT. |

---

#### File Integrity Errors

| Error Code                 | Component | Description                                      |
| -------------------------- | --------- | ------------------------------------------------ |
| `ERR_WEBCAT_FILE_MISMATCH` | File      | A file's hash does not match the manifest entry. |
