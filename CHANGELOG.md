# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [0.8.4](https://github.com/CrowdHailer/raxx_kit/tree/0.8.4) - 2019-01-06

### Added

- `mix raxx.new` added as an alias for `mix raxx.kit` task.

### Removed

- The `--apib` switch did not produce a viable project and has been removed as an option.

## [0.8.3](https://github.com/CrowdHailer/raxx_kit/tree/0.8.3) - 2018-11-24

### Fixed

- With `--ecto` option don't generate an empty migrations directory.

## [0.8.2](https://github.com/CrowdHailer/raxx_kit/tree/0.8.2) - 2018-11-24

### Fixed

- Use `section`-based routes in the generated project to avoid warnings.

## [0.8.1](https://github.com/CrowdHailer/raxx_kit/tree/0.8.1) - 2018-11-24

### Fixed

- Creating empty directories in the generated project.

## [0.8.0](https://github.com/CrowdHailer/raxx_kit/tree/0.8.0) - 2018-11-22

### Added

- Ecto 3.0 boilerplate and postgres service when specifying `--ecto` flag.
- Disabling code reloading with `--no-exsync` flag.
- Code formatting run after the project is generated.

### Changed

- Compilation artifacts no longer pollute the host machine when using `--docker`.
- `--docker` option uses elixir:1.7.4 as base image.

## [0.7.1](https://github.com/CrowdHailer/raxx_kit/tree/0.7.1) - 2018-11-14

### Added

- SASS compilation when specifying the `--node-assets` flag.
- Newly generated projects are formatted on creation.

## [0.7.0](https://github.com/CrowdHailer/raxx_kit/tree/0.7.0) - 2018-10-29

### Changed

- Use Ace `0.18.0`.

## [0.6.0](https://github.com/CrowdHailer/raxx_kit/tree/0.6.0) - 2018-09-12

### Changed

- Use Ace `0.17.0`.

## [0.5.5](https://github.com/CrowdHailer/raxx_kit/tree/0.5.5) - 2018-09-04

### Added

- Home page template demonstrates using variables in a template.
- Setting JavaScript variables is done on the home page.

### Changed

- `--docker` option uses latest (elixir:1.7.3) as base image.

## [0.5.4](https://github.com/CrowdHailer/raxx_kit/tree/0.5.4) - 2018-09-03

### Changed

- Generated `HTMLView` module has been removed, instead `Raxx.Layout` is used

## [0.5.3](https://github.com/CrowdHailer/raxx_kit/tree/0.5.3) - 2018-06-04

### Added

- Moduledoc added to mix task
- Explicit link to favicon in template

## [0.5.2](https://github.com/CrowdHailer/raxx_kit/tree/0.5.2) - 2018-05-10

### Fixed

- Default `secure_port` is now `8443`, and no longer the same as default `port`

## [0.5.1](https://github.com/CrowdHailer/raxx_kit/tree/0.5.1) - 2018-04-29

### Added

- Environment configuration for ports.

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
