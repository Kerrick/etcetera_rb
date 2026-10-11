# Etcetera

This is a Ruby port of [the Rust library of the same name](https://github.com/lunacookies/etcetera).

Etcetera allows you to determine the locations of configuration, data, cache & other files for your application.
Existing Ruby libraries generally do not give you a choice in terms of which standards/conventions they follow.
Etcetera, on the other hand, gives you the choice.

Required Ruby: 3.3.0 or newer.

## Installation

```ruby
gem "etcetera"
```

## Conventions

Etcetera supports the following conventions:

- the [XDG base directory](https://standards.freedesktop.org/basedir/latest/)
- Apple's [Standard Directories](https://developer.apple.com/library/content/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html)
- Windows' [Known Folder Locations](https://learn.microsoft.com/en-us/windows/win32/shell/knownfolderid)
- the "Unix Single-folder Convention" i.e. everything in `~/.myapp`

## Strategies

Etcetera has 2 modes of operation: `Etcetera::BaseStrategy` & `Etcetera::AppStrategy`:

- With `BaseStrategy`, you just get the location of the respective directory. For eg. for `config_dir`:
  - XDG: `~/.config`
  - Apple: `~/Library/Preferences`
  - Windows: `~\AppData\Roaming`
- With `AppStrategy`, you provide additional information to get the location of your app directory.
  For eg. if you provide the following details:

  ```ruby
  Etcetera::AppStrategyArgs.new(
    top_level_domain: "org",
    author: "Acme Corp",
    app_name: "Frobnicator Plus"
  )
  ```

  you'll get:

  - XDG: `~/.config/frobnicator-plus`
  - Unix: `~/.frobnicator-plus`
  - Apple: `~/Library/Preferences/org.acme-corp.Frobnicator-Plus`
  - Windows: `~\AppData\Roaming\Acme Corp\Frobnicator Plus`

Every directory is returned as a [`Pathname`](https://docs.ruby-lang.org/en/master/Pathname.html).
Directories that a platform does not support — `state_dir` & `runtime_dir` on macOS and Windows — are returned as `nil`.

Note: the location of the home (`~`) is determined by [`Dir.home`](https://docs.ruby-lang.org/en/master/Dir.html#method-c-home).
`Etcetera.home_dir` wraps it in a `Pathname`, and raises `Etcetera::HomeDirError` when the home directory cannot be located.

### Convenience functions

Etcetera also provides convenience functions for selecting the appropriate strategy on each platform:

- `Etcetera.choose_base_strategy` & `Etcetera.choose_app_strategy`: Uses `Windows` on Windows & `Xdg` everywhere else.
  This is used by most CLI tools & some GUI tools on each platform.
- `Etcetera::BaseStrategy.choose_native_strategy` & `Etcetera::AppStrategy.choose_native_strategy`: Uses `Windows` on Windows, `Apple` on macOS, & `Xdg` everywhere else.
  This is used by most GUI applications on each platform.

## Usage

```ruby
require "etcetera"

strategy = Etcetera.choose_base_strategy

config_dir  = strategy.config_dir
data_dir    = strategy.data_dir
cache_dir   = strategy.cache_dir
state_dir   = strategy.state_dir
runtime_dir = strategy.runtime_dir
```

```ruby
require "etcetera"

args = Etcetera::AppStrategyArgs.new(
  top_level_domain: "org",
  author: "Acme Corp",
  app_name: "Frobnicator"
)
strategy = Etcetera.choose_app_strategy(args)

config_file = strategy.in_config_dir("settings.toml")
```

## Differences from the Rust crate

- Paths are `Pathname`s rather than Rust's `PathBuf`, and the defaults carry no trailing separator: `~/.config`, not `~/.config/`.
  `Pathname#==` compares the strings it was handed, so compare against the value Etcetera returns rather than a hand-written path with a trailing slash.
- Directories that are unavailable are `nil` rather than `None`.
- `Dir.home` prefers `HOME` over `USERPROFILE` on Windows; the Rust standard library prefers `USERPROFILE`.
  An empty `HOME` is the same problem: the crate reads `USERPROFILE`, while Etcetera raises `Etcetera::HomeDirError`.
  Elsewhere an empty or unset `HOME` falls back to the password database, as in the crate.
- Absolute paths are decided by `Pathname#absolute?`, which on Windows accepts drive-relative paths such as `/foo` and `C:foo` that Rust's `Path::is_absolute` rejects.
  An `XDG_CONFIG_HOME` set to `/foo` is honored here and ignored by the crate.
- The Windows Known Folder Locations are read through `Fiddle`, which ships with every supported Ruby, so there is no C extension or FFI gem to install.
  Fiddle stopped being a default gem in Ruby 4.0, and Bundler hides bundled gems that the application has not asked for, so a Bundler-managed Windows application that wants those folders should add `gem "fiddle"` to its `Gemfile`.
  Without it, Etcetera falls back to the default `AppData` directories, exactly as it does when the API call itself fails.
- Strategies are plain objects; they do not implement `==`, `hash` or `inspect`, where the crate derives `PartialEq`, `Eq`, `Ord`, `Hash` and `Debug`.
- `AppStrategyArgs` is a `Data` value object, so its fields are read-only, unlike Rust's `pub` fields.
- iOS has no Ruby equivalent, so `darwin` selects the Apple strategy.

## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then, run `rake` to run the tests and RuboCop.
You can also run `bin/console` for an interactive prompt.

To install this gem onto your local machine, run `bundle exec rake install`.
Releases are pushed to [RubyGems](https://rubygems.org/) by hand; CI never publishes.

## License

The gem is available as open source under the terms of the [Apache-2.0](LICENSE-APACHE) or [MIT](LICENSE-MIT) licenses.
