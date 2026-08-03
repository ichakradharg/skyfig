# Rendered DocC site

Skyfig publishes API reference and conceptual guides as a static DocC site on GitHub Pages. The site is generated from the public Swift documentation comments and the catalog in `Sources/Skyfig/Skyfig.docc`.

For this repository, the published site is [Skyfig documentation on GitHub Pages](https://ichakradharg.github.io/skyfig/). In a team-owned fork, GitHub assigns a different Pages URL; open **Settings → Pages** and select **Visit site** after enabling deployment.

## Publishing

After this workflow is merged, configure **Settings > Pages** for the repository to use **GitHub Actions** as its build source. Every relevant change merged to `main`, or a manual run of **Publish DocC site**, generates and deploys the static site. This is a per-repository GitHub setting, so a team-owned fork must enable it independently.

The repository site is served below the `skyfig` path, so DocC's static-hosting transform is configured with that base path. This keeps page navigation and deep links correct on GitHub Pages.

DocC's generated content begins at `documentation/skyfig`. The Pages workflow copies `Docs/pages-index.html` into the rendered site root so the repository URL redirects there instead of showing a 404 page.

## Preview locally

Use the DocC plugin's local preview server while editing documentation:

```bash
swift package --disable-sandbox preview-documentation --target Skyfig
```

For a static-output check that matches Pages generation:

```bash
swift package --allow-writing-to-directory .build/docc-site \
  generate-documentation --target Skyfig \
  --disable-indexing \
  --transform-for-static-hosting \
  --hosting-base-path skyfig \
  --output-path .build/docc-site
```

The generated `.build/docc-site` directory is build output and must not be committed.
