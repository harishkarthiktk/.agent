# Boolean Auth State

## Anti-pattern
Using a boolean `isLoggedIn` (default `false`) to track authentication. Conflates "haven't checked yet" with "not logged in", causing LoginForm to flash during async auth restoration in useEffect.

## Positive pattern
Use a three-state value: `loading | authenticated | unauthenticated`. Render a splash/loading screen during the `loading` state. Only show LoginForm when definitively `unauthenticated`.

## Detection signal
- Auth state initialized as `false` or `null` with no separate loading flag
- LoginForm flickers on page load for already-authenticated users
- useEffect that checks auth and redirects, paired with a boolean guard
