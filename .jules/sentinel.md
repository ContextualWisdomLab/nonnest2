## 2024-07-01 - Avoid Security Theater in Pure Math Packages
**Vulnerability:** N/A (General finding for this repo)
**Learning:** This is a purely statistical mathematical package (`nonnest2`) performing likelihood calculations and matrix operations. It has no web endpoints, network access, or file I/O operations that parse untrusted external data. As such, adding argument type bounds or structural validations (which are standard statistical error handling) should NOT be presented as security enhancements. Treating them as such creates "security theater".
**Prevention:** Do not create security PRs for standard error checking in mathematical libraries without an actual vector of exploitation.
