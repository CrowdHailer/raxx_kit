# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [0.5.0](https://github.com/CrowdHailer/raxx_kit/tree/0.5.0) - 2018-04-28

### Added

- New `HTMLView` module handles templates and HTML escaping

## [0.4.4](https://github.com/CrowdHailer/raxx_kit/tree/0.4.4) - 2018-04-23

### Fixed

- Recompilation is triggered for `.js` and `.css` files.

## [0.4.3](https://github.com/CrowdHailer/raxx_kit/tree/0.4.3) - 2018-04-22

### Fixed

- dotfiles, such as `.gitignore` are prefixed in template to fix issues with priv dir and archives.

## [0.4.2](https://github.com/CrowdHailer/raxx_kit/tree/0.4.2) - 2018-04-21

### Added

- Project information for release on hex.pm.

## [0.4.1](https://github.com/CrowdHailer/raxx_kit/tree/0.4.1) - 2018-04-21

### Added

- Generated project includes a `.gitignore` file.

## [0.4.0](https://github.com/CrowdHailer/raxx_kit/tree/0.4.0) - 2018-03-22

### Added

- Sensible Docker configuration created when using the `--docker` option.
- Add supervised npm scripts to template project with `--node-assets` option.

## [0.3.0](https://github.com/CrowdHailer/raxx_kit/tree/0.3.0) - 2018-02-11

### Added

- Unit test for HomePage action in project template.
- API Blueprint router using the `--apib` option.
- SSL certificates for an https endpoint, default port 8443.

## [0.2.0](https://github.com/CrowdHailer/raxx_kit/tree/0.2.0) - 2018-02-11

Tokumei project is renamed Raxx Kit.
This was to reflect a change in scope.
The focus of Raxx Kit will be project generators for different usecases.
Other features from the Tokumei framework have been migrated to appropriate Raxx middleware projects.

### Added

- `raxx.kit` task, which accepts a `name` and optional `--module`.
