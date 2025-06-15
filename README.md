# TextPlayer

A Ruby interface for running text-based interactive fiction games using the Frotz Z-Machine interpreter. This gem provides structured access to classic text adventure games with multiple output formatters for different use cases.

Inspired by [@danielricks/textplayer](https://davidgriffith.gitlab.io/frotz/) - the original Python implementation.

I have chosen not to distribute the games in the ruby gem. You'll need to clone this repository to use the games directly without the full pathname. This is out of an abundance of caution and respect to the owners. Offering them for download, as is done regularly, may be interpreted differently than distributing them in a package.

I am grateful for the ability to use these games for learning and building. Zork is the game that got me started on MUDs as a kid, which is the reason I'm a programmer now.

## Requirements

TextPlayer requires Frotz, a Z-Machine interpreter written by Stefan Jokisch in 1995-1997. More information [here](http://frotz.sourceforge.net/).

Use Homebrew to install the `frotz` package:

```bash
$ brew install frotz
```

If you don't have homebrew, download the source code, build and install.

```bash
$ git clone https://github.com/DavidGriffith/frotz.git
$ cd frotz
$ make dumb
$ make dumb_install # optional, but recommended
```

The `dfrotz` (dumb frotz) binary must be available in your PATH or you will need to pass the path to the dfrotz executable as an argument to TextPlayer.

## Installation

Add to an application:

```bash
$ bundle add text_player
$ bundle install
```

Or install it:

```bash
$ gem install text_player
```

If you'd like to use the games included in the repository, clone it directly from github.com:

```bash
$ git clone git@github.com:martinemde/text_player.git
```

## Usage

You can use the command line to check if it's working:

```bash
$ text_player help
$ text_player play zork1
```

### Basic Example

The point of this library is to allow you to run text based adventure games programmatically.

```ruby
require 'text_player'

# Create a new game session
game = TextPlayer::Session.new('games/zork1.z5')

# Or specify a custom dfrotz path
# This must be dfrotz, the DUMB version of frotz, which installs with frotz.
game = TextPlayer::Session.new('games/zork1.z5', dfrotz: '~/bin/dfrotz')

# Start the game
start_output = game.start
puts start_output

# Execute commands
response = game.call('go north')
puts response

# Get current score
if score = game.score
  current_score, max_score = score.score, score.out_of
  puts "Score: #{current_score}/#{max_score}"
end

# Save and restore
game.save('my_save')
game.restore('my_save')

# Quit the game
game.quit
```

### Save and Restore Operations

```ruby
# Save to default slot (autosave)
save_result = game.save
puts save_result  # Formatted feedback about save operation

# Save to named slot
game.save('before_dragon')

# Restore from default slot
game.restore

# Restore from named slot
game.restore('before_dragon')
```

### Interactive Shell Example

```ruby
require 'text_player'

game = TextPlayer::Session.new('zork1.z5')
formatter = TextPlayer::Formatters::Shell
game.run do |result|
  formatter.new(result).write($stdout)
  command = $stdin.gets
  break if command.nil?
  command
end
```

### Configuring dfrotz Path

By default, TextPlayer looks for the `dfrotz` executable in the system PATH `dfrotz`. You can specify a custom path:

```ruby
# Use local path to compiled dfrotz
game = TextPlayer::Session.new('zork1.z5', dfrotz: './frotz/dfrotz')

# Use absolute path
game = TextPlayer::Session.new('zork1.z5', dfrotz: '/usr/local/bin/dfrotz')
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/martinemde/text_player.

## Game Files

You'll need Z-Machine game files (`.z3`, `.z5`, `.z8` extensions) to play. Many classic interactive fiction games are available from:

- [The Interactive Fiction Archive](https://www.ifarchive.org/)
- [Infocom games](http://www.infocom-if.org/downloads/downloads.html)

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

I have included the same games from [@danielricks/textplayer](https://github.com/danielricks/textplayer), assuming that in the last ~10 years that it has not been a problem.

The games are copyright and licensed by their respective owners.

**Please open an issue on the repository or contact me directly if there are any concerns.**

## Credits

This Ruby implementation was inspired and influenced by [@danielricks/textplayer](https://github.com/danielricks/textplayer), who wrote a Python interface for Frotz to facilitate training models to automatically play the game.
