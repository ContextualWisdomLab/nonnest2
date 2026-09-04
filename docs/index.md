# nonnest2

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/ContextualWisdomLab/nonnest2)

`nonnest2` is an R package for evidence-based comparison of nested and non-nested statistical models. It implements Vuong-style distinguishability and relative-fit procedures and provides confidence intervals for differences in AIC and BIC.

## Start here

The task-first [README](https://github.com/ContextualWisdomLab/nonnest2/blob/master/README.md) covers installation, a worked example, model-alignment requirements, supported adapter contracts, verification, statistical interpretation, and contribution guidance.

The public API is intentionally small:

- `vuongtest()` — distinguishability and relative-fit comparison;
- `icci()` — information-criterion difference intervals for non-nested models that satisfy the distinguishability condition; and
- `llcont()` — model-specific casewise log-likelihood contributions.

## Statistical boundary

Compared models must refer to the same dependent variable(s), the same observations, and the same observation order. `nonnest2` does not currently verify row alignment. `llcont()` likelihood contributions and score contributions therefore share the observation ordering, while `vc1` / `vc2` are parameter covariance matrices whose rows and columns must match the score parameter ordering consumed by `calcAB()`; they are not observation-level inputs.

`icci()` is valid only for non-nested models that are distinguishable according to the `vuongtest()` variance/distinguishability test. Nested or indistinguishable pairs must not be interpreted through its intervals.

These procedures compare fitted models under their assumptions. They do not establish causal validity, substitute for identification or data-quality checks, or turn information criteria into proof of scientific truth. Consequential analyses should preserve the exact package revision, fitted-model inputs, and software environment needed for reproduction.

## Verification

For a checked-out revision:

```bash
R CMD build .
R CMD check nonnest2_*.tar.gz
```

Use current exact-head CI evidence when deciding whether a revision is fit for use; documentation presence is not a release or quality receipt.

## License and commercial-use boundary

The inherited package metadata declares `GPL-2 | GPL-3`. ContextualWisdomLab maintenance of this repository does not create a new permissive grant over upstream copyright. GPL permits commercial use under its terms, but GPL-family source is outside ContextualWisdomLab's normal inbound commercial baseline.

See [commercial-license-boundary.md](commercial-license-boundary.md) for the recorded immutable provenance, constraints, and closure paths. This documentation source must not be read as approval for incorporation into a ContextualWisdomLab commercial product while that boundary remains unresolved.

## More documentation

- [README](https://github.com/ContextualWisdomLab/nonnest2/blob/master/README.md) — product overview, usage, adapters, and interpretation
- [Product and technical gap baseline](product-technical-gap-baseline.md) — current scientific, integration, release, and licensing gaps
- [Commercial license boundary](commercial-license-boundary.md) — provenance and policy status
- [Vignettes](https://github.com/ContextualWisdomLab/nonnest2/tree/master/vignettes) — longer worked material in the source tree
- [Ask DeepWiki](https://deepwiki.com/ContextualWisdomLab/nonnest2) — repository-aware navigation and questions

This file is only a publication-ready documentation source. It does not itself establish GitHub Pages publication or a released package artifact.
