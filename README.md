# package-siege

Siege is an open source regression test and benchmark utility. It can stress test a single URL with a user defined number of simulated users, or it can read many URLs into memory and stress them simultaneously. <https://www.joedog.org/siege-home/>

See <https://github.com/JoeDog/siege/releases> for releases.

## Generating the RPM package

Edit the `Makefile` to ensure that you are setting the intended version, then run `make`.

```bash
make
```
