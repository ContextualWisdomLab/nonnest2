## 2024-05-24 - Avoid Redundant Matrix Inversions in Formulaic Translations
**Learning:** Formulaic translation of statistical math into R code often leads to redundant matrix inversions (like computing `chol2inv(chol(A))` twice). This is an O(n^3) operation that causes unnecessary overhead.
**Action:** Always check for repeated identical calculations, especially expensive ones like matrix inversions or decompositions, and cache their results in variables to be reused.
