# Skyfig architecture

Skyfig separates credentialed design import from package consumption:

```text
Figma sync -> canonical JSON -> typed Swift -> reviewed release -> app adoption
```

Figma credentials and raw responses remain in the publisher workflow. The canonical JSON is reviewed source data, the generator produces ``SkyfigTokens``, and applications consume released package versions without credentials or runtime network access.

For the full architecture and trust-boundary guide, see the [repository architecture guide](https://github.com/ichakradharg/skyfig/blob/main/Docs/ARCHITECTURE.md).
