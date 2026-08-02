# Skyfig package consumer smoke test

This minimal Swift package depends on Skyfig through a separate package manifest. It compiles the public `SkyfigTokens` API without using the iOS sample app project.

From the repository root, run:

```bash
swift run --package-path Examples/SkyfigPackageConsumer
```

The dependency is local so CI can validate the package boundary before Skyfig has a published release. After the first release, this can be changed to a versioned package URL for external-consumer testing.
