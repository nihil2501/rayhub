# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "rayhub"
  spec.version = "0.1.0"
  spec.author = "Oren Mittman"
  spec.authors = ["Oren Mittman"]
  spec.email = ["nihil2501@gmail.com"]
  spec.license = "MIT"
  spec.licenses = ["MIT"]

  spec.summary = "Store and process device readings from the field."
  spec.description = "Use event sourcing to decouple device reading events from their aggregation into summary statistics over various types of measurements."
  spec.homepage = "https://github.com/nihil2501/rayhub"
  spec.required_ruby_version = ">= 3.2.2"

  spec.metadata["allowed_push_host"] = "https://rubygems.pkg.github.com/nihil2501"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  # Is this right? Taken from:
  #   https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-rubygems-registry#connecting-a-package-to-a-repository
  spec.metadata["github_repo"] = "ssh://github.com/nihil2501/rayhub"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
