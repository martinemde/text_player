# frozen_string_literal: true

module TextPlayer
  module OutputParser
    SCORE_PATTERN = /Score:\s*(\d+)/i
    MOVES_PATTERN = /Moves:\s*(\d+)/i
    TIME_PATTERN = /(\d{1,2}:\d{2}\s*(?:AM|PM))/i

    def self.parse_status_line(text)
      return [{}, text] if text.nil? || text.empty?

      lines = text.split("\n")
      return [{}, text] if lines.empty?

      # Extract data from the first few lines (status area)
      location = nil
      score = nil
      moves = nil
      time = nil
      lines_to_remove = 0

      # Check first line for location and stats
      first_line = lines.first&.strip
      if first_line && !first_line.empty?
        location = extract_location(first_line)
        score = extract_score(first_line)
        moves = extract_moves(first_line)
        time = extract_time(first_line)

        # If we found location or stats on first line, mark it for removal
        if location || score || moves || time
          lines_to_remove = 1
        end
      end

      # Check second line for additional stats (like "Moves:0" in certain games)
      if lines.length > 1
        second_line = lines[1]&.strip
        if second_line && !second_line.empty?
          # Only check for stats, not location on second line
          score ||= extract_score(second_line)
          moves ||= extract_moves(second_line)
          time ||= extract_time(second_line)

          # If we found stats on second line, include it in removal
          if (score && second_line.match?(SCORE_PATTERN)) ||
              (moves && second_line.match?(MOVES_PATTERN)) ||
              (time && second_line.match?(TIME_PATTERN))
            lines_to_remove = [lines_to_remove, 2].max
          end
        end
      end

      # Build data hash with only non-nil values
      data = {}
      data[:location] = location if location
      data[:score] = score if score
      data[:moves] = moves if moves
      data[:time] = time if time

      # Remove status lines from output if we extracted anything
      remaining = if data.any? && lines_to_remove > 0
        remaining_lines = lines[lines_to_remove..]
        # If we extracted a location, prepend it to the remaining content
        if location
          remaining_lines.unshift(location)
        end
        remaining_lines.join("\n")
      else
        text
      end

      [data, remaining]
    end

    def self.extract_location(line)
      # Handle formats like:
      # " Canyon Bottom                    Score: 0        Moves: 26"
      # " In the enchanted forest                             5:00 AM      Score: 0"
      parts = line.split(/\s{3,}/)

      if parts.length >= 2
        candidate = parts.first.strip
        return candidate unless candidate.empty?
      end

      # Handle standalone location (no stats)
      candidate = line.strip
      if !candidate.match?(/(?:Score|Moves|AM|PM):/i) &&
          !candidate.match?(/\d+:\d+/) &&
          !candidate.match?(/[.!?]$/) &&
          candidate.length < 50 &&
          !candidate.downcase.include?("response") &&
          valid_location?(candidate)
        candidate
      end
    end

    def self.extract_score(text)
      match = text.match(SCORE_PATTERN)
      match ? match[1].to_i : nil
    end

    def self.extract_moves(text)
      match = text.match(MOVES_PATTERN)
      match ? match[1].to_i : nil
    end

    def self.extract_time(text)
      match = text.match(TIME_PATTERN)
      match ? match[1] : nil
    end

    def self.extract_prompt(text)
      return [{}, text] if text.nil? || text.empty?

      lines = text.split("\n")
      return [{}, text] if lines.empty?

      last_line = lines.last&.strip
      if last_line&.match?(TextPlayer::PROMPT_REGEX)
        remaining = lines[0...-1].join("\n")
        [{prompt: last_line}, remaining]
      else
        [{}, text]
      end
    end

    def self.valid_location?(location)
      location.length.positive? &&
        !location.start_with?("I don't ") &&
        !location.start_with?("I can't ") &&
        !location.start_with?("What do you ") &&
        !location.start_with?("You're ") &&
        !location.start_with?("You ") &&
        !location.start_with?("That's not ") &&
        !location.start_with?("I beg your pardon")
    end

    # Clean up excessive whitespace but preserve paragraph structure
    def self.cleanup(text)
      # Remove excess ending whitespace from all lines
      text = text.lines.map(&:rstrip).join("\n")
      # Remove more than 2 consecutive newlines (preserve paragraph breaks)
      text.gsub!(/\n{3,}/, "\n\n")
      # Clean up any trailing/leading whitespace on lines
      text.gsub!(/[ \t]+$/, "")
      # Remove leading and trailing whitespace
      text.strip
    end
  end
end
