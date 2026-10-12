[![rubygems.org version](https://img.shields.io/gem/v/etcetera?style=for-the-badge)](https://rubygems.org/gems/etcetera)
[![rubygems.org downloads](https://img.shields.io/gem/dt/etcetera?style=for-the-badge)](https://rubygems.org/gems/etcetera/reverse_dependencies)
[![documentation](https://img.shields.io/badge/docs-rubydoc.info-blue?style=for-the-badge)](https://rubydoc.info/gems/etcetera)
![license](https://img.shields.io/gem/l/etcetera?style=for-the-badge)

# Etcetera

This is a Ruby library that allows you to determine the locations of configuration, data, cache & other files for your application.
Existing Ruby libraries generally do not give you a choice in terms of which standards/conventions they follow.
Etcetera, on the other hand, gives you the choice.

Minimum Ruby version: 4.0.0

Note: Ruby 4.0.0 is required because `Pathname` became a core class & `fiddle` became a bundled gem in that version.

## Conventions

Etcetera supports the following conventions:

- the [XDG base directory](https://standards.freedesktop.org/basedir/latest/)
- Apple's [Standard Directories](https://developer.apple.com/library/content/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html)
- Window's [Known Folder Locations](https://docs.microsoft.com/en-us/windows/win32/shell/knownfolderid)
- the "Unix Single-folder Convention" i.e. everything in `~/.myapp`

## Strategies

Etcetera has 2 modes of operation: `BaseStrategy` & `AppStrategy`:

- With `BaseStrategy`, you just get the location of the respective directory. For eg. for `config_dir`:
  - XDG: `~/.config`
  - Apple: `~/Library/Preferences`
  - Windows: `~\AppData\Roaming`
- With `AppStrategy`, you provide additional information to get the location of your app directory.
  For eg. if you provide the following details: `top_level_domain: "org", author: "Acme Corp", app_name: "Frobnicator Plus"`, you'll get:
  - XDG: `~/.config/frobnicator-plus`
  - Unix: `~/.frobnicator-plus`
  - Apple: `~/Library/Preferences/org.acme-corp.Frobnicator-Plus`
  - Windows: `~\AppData\Roaming\Acme Corp\Frobnicator Plus`

Note: the location of the home (~) is determined by [`Dir.home`](https://docs.ruby-lang.org/en/master/Dir.html#method-c-home).

### Convenience functions

Etcetera also provides convenience functions for selecting the appropriate strategy on each platform:

- `BaseStrategy.choose_base_strategy` & `AppStrategy.choose_app_strategy`: Uses `Windows` on Windows & `XDG` everywhere else.
  This is used by most CLI tools & some GUI tools on each platform.
- `BaseStrategy.choose_native_strategy` & `AppStrategy.choose_native_strategy`: Uses `Windows` on Windows, `Apple` on macOS/iOS, & `XDG` everywhere else.
  This is used by most GUI applications on each platform.

## 

See the [documentation](https://rubydoc.info/gems/etcetera) for examples.

## Ruby port

This is a port of [the Rust crate of the same name](https://github.com/lunacookies/etcetera), version 0.12.0.
Like the crate, it leans on its language's standard library, so it differs from the crate wherever Ruby's standard library differs from Rust's:

- Directories are `Pathname`s rather than `PathBuf`s, & missing directories are `nil` rather than `None`.
- `Pathname#==` compares paths as strings, so `Pathname.new("/foo/") != Pathname.new("/foo")`, unlike `Path`'s component-wise comparison.
- `Dir.home` & `std::env::home_dir` don't always agree on the home directory, for eg. when `HOME` is unset or empty, or on Windows when `HOME` & `USERPROFILE` differ.
- Strategies & `AppStrategyArgs` are `Data` value objects.
- Ruby can't tell macOS & iOS apart, so `choose_native_strategy` picks `Apple` on any `darwin` platform.
