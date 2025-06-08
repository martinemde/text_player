# TextPlayer

A Ruby interface for running text-based interactive fiction games using the Frotz Z-Machine interpreter. This gem provides structured access to classic text adventure games with multiple output formatters for different use cases.

Inspired by [@danielricks/textplayer](https://davidgriffith.gitlab.io/frotz/) - the original Python implementation.

## Requirements

TextPlayer requires Frotz, a Z-Machine interpreter written by Stefan Jokisch in 1995-1997. More information [here](http://frotz.sourceforge.net/).

Use Homebrew to install the `frotz` package:

```bash
$ brew instal frotz
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

## Usage

### Basic Example

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
response = game.execute_command('go north')
puts response

# Get current score
if score = game.get_score
  current_score, max_score = score
  puts "Score: #{current_score}/#{max_score}"
end

# Save and restore
game.save('my_save')
game.restore('my_save')

# Quit the game
game.quit
```

### Output Formatters

TextPlayer supports three different output formatters for various use cases:

#### Shell Formatter (Default)
Returns formatted text ready for interactive shell use:

```ruby
game = TextPlayer::Session.new('zork1.z5', formatter: :shell)
output = game.start
# Returns: Full game text with prompt (adds ">" if missing)
puts output
```

#### Data Formatter
Returns structured hash with parsed game information:

```ruby
game = TextPlayer::Session.new('zork1.z5', formatter: :data)
result = game.start

puts result[:location]    # "West of House"
puts result[:score]       # 0
puts result[:moves]       # 1
puts result[:output]      # Clean game text
puts result[:has_prompt]  # true/false
```

#### JSON Formatter
Returns JSON string of structured data:

```ruby
game = TextPlayer::Session.new('zork1.z5', formatter: :json)
json_output = game.start
data = JSON.parse(json_output)
puts data['location']  # "West of House"
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

game = TextPlayer::Session.new('zork1.z5', formatter: :shell)
puts game.start

loop do
  command = game.formatter.prompt_for_command
  break if command.nil? || command.downcase == 'quit'

  response = game.execute_command(command)
  puts response
end

game.quit
```

### Error Handling

```ruby
begin
  game = TextPlayer::Session.new('nonexistent.z5')
rescue ArgumentError => e
  puts "Error: #{e.message}"
end

# Check if game is still running
if game.running?
  puts "Game is active"
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

## Game Files

You'll need Z-Machine game files (`.z3`, `.z5`, `.z8` extensions) to play. Many classic interactive fiction games are available from:

- [The Interactive Fiction Archive](https://www.ifarchive.org/)
- [Infocom games](http://www.infocom-if.org/downloads/downloads.html)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/martinemde/text_player.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Credits

This Ruby implementation was inspired by [@danielricks/textplayer](https://github.com/danielricks/textplayer), who wrote a Python interface for Frotz to facilitate training models to automatically play the game.
