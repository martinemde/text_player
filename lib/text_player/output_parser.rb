# frozen_string_literal: true

module TextPlayer
  # Extracts data from command result
  module OutputParser
    extend self

    SCORE_PATTERN = /Score:\s*(\d+)/i
    MOVES_PATTERN = /Moves:\s*(\d+)/i
    TIME_PATTERN = /(\d{1,2}:\d{2}\s*(?:AM|PM))/i

    def parse(raw_output)
      cleaned = raw_output.dup

      # Extract from original, remove from cleaned copy
      location = extract_location(raw_output)
      score = extract_score(raw_output)
      moves = extract_moves(raw_output)
      time = extract_time(raw_output)
      prompt = extract_prompt(raw_output)

      # Remove what we found from the cleaned copy
      remove_extracted_data!(cleaned, location, score, moves, time, prompt)

      # Final cleanup of remaining text
      output = final_cleanup(cleaned)

      {
        location: location,
        score: score,
        moves: moves,
        time: time,
        prompt: prompt,
        output: output,
        has_prompt: !prompt.nil?
      }
    end

    def extract_location(text)
      lines = text.split("\n")
      first_line = lines.first&.strip

      return nil if first_line.nil? || first_line.empty?

      # Try different location extraction strategies
      location = extract_location_with_stats(first_line) ||
        extract_standalone_location(first_line)

      return nil unless location && valid_location?(location)

      location
    end

    def extract_location_with_stats(line)
      # Handle formats like: " Canyon Bottom                    Score: 0        Moves: 26"
      # or " In the enchanted forest                             5:00 AM      Score: 0"
      parts = line.split(/\s{3,}/)
      return nil if parts.length < 2

      candidate = parts.first.strip
      candidate.empty? ? nil : candidate
    end

    def extract_standalone_location(line)
      # Handle formats like: " Brig" (location on its own line)
      candidate = line.strip
      # Only consider it a location if it doesn't contain stats and isn't an error message
      if !candidate.match?(/(?:Score|Moves|AM|PM):/i) &&
          !candidate.match?(/\d+:\d+/) &&
          !candidate.match?(/[.!?]$/) && # Not a sentence ending with punctuation
          candidate.length < 50 && # Reasonable location length
          !candidate.downcase.include?("response") # Not a generic response
        candidate
      end
    end

    def valid_location?(location)
      location.length.positive? &&
        !location.start_with?("I don't ") &&
        !location.start_with?("I can't ") &&
        !location.start_with?("What do you ") &&
        !location.start_with?("You're ") &&
        !location.start_with?("You ") &&
        !location.start_with?("That's not ") &&
        !location.start_with?("I beg your pardon")
    end

    def extract_score(text)
      match = text.match(SCORE_PATTERN)
      match ? match[1].to_i : nil
    end

    def extract_moves(text)
      match = text.match(MOVES_PATTERN)
      match ? match[1].to_i : nil
    end

    def extract_time(text)
      match = text.match(TIME_PATTERN)
      match ? match[1] : nil
    end

    def extract_prompt(text)
      # Extract prompt from end of text (usually ">")
      lines = text.split("\n")
      last_line = lines.last&.strip
      last_line if last_line&.match?(TextPlayer::PROMPT_REGEX)
    end

    def remove_extracted_data!(text, location, score, moves, time, prompt)
      # Handle location removal
      if location
        lines = text.split("\n")
        first_line = lines.first&.strip

        if first_line && extract_location_with_stats(first_line)
          # Replace status line with just the location name
          lines[0] = location
          text.replace(lines.join("\n"))
        end
      end

      # Remove patterns for extracted data
      text.gsub!(SCORE_PATTERN, "") if score
      text.gsub!(MOVES_PATTERN, "") if moves
      text.gsub!(TIME_PATTERN, "") if time

      # Remove prompt if we extracted it
      if prompt
        lines = text.split("\n")
        if lines.last&.strip == prompt
          lines.pop
          text.replace(lines.join("\n"))
        end
      end
    end

    def final_cleanup(text)
      # Clean up excessive whitespace but preserve paragraph structure
      # Remove more than 2 consecutive newlines (preserve paragraph breaks)
      text.gsub!(/\n{3,}/, "\n\n")
      # Remove lines that are only whitespace
      text.gsub!(/^\s+$/m, "")
      # Clean up any trailing/leading whitespace on lines
      text.gsub!(/[ \t]+$/, "")

      text.strip
    end
  end
end
