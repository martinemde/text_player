# frozen_string_literal: true

require_relative "lib/text_player/version"

Gem::Specification.new do |spec|
  spec.name = "text_player"
  spec.version = TextPlayer::VERSION
  spec.authors = ["Cardiff Emde", "Martin Emde"]
  spec.email = ["cardiff.emde@gmail.com", "me@martinemde.com"]

  spec.summary = "Ruby gem for playing Zork and other text-based adventure games"
  spec.description = "Ruby gem for playing Zork and other text-based adventure games that provides a programmatic interface for interacting with the game."
  spec.homepage = "https://github.com/martinemde/text_player"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/martinemde/text_player"
  spec.metadata["changelog_uri"] = "https://github.com/martinemde/text_player/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ games/ test/ spec/ features/ .git .github appveyor Gemfile .rspec .standard.yml .rubocop.yml Rakefile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency "thor"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
