module Almanack
  class Configuration
    class ThemeNotFound < StandardError; end

    DEFAULT_THEME = "legacy"
    DEFAULT_DAYS_LOOKAHEAD = 30
    DEFAULT_FEED_LOOKAHEAD = 365

    attr_reader :event_sources
    attr_accessor :title,
                  :theme,
                  :theme_paths,
                  :theme_root,
                  :days_lookahead,
                  :feed_lookahead

    def initialize
      reset!
    end

    def connection
      @connection ||= Faraday.new
    end

    def reset!
      @theme = DEFAULT_THEME
      @days_lookahead = DEFAULT_DAYS_LOOKAHEAD
      @feed_lookahead = DEFAULT_FEED_LOOKAHEAD
      @event_sources = []

      @theme_paths = [
        Pathname.pwd.join('themes'),
        Pathname(__dir__).join('themes')
      ]
    end

    def theme_root
      paths = theme_paths.map { |path| path.join(theme) }
      root = paths.find { |path| path.exist? }
      root || raise(ThemeNotFound, "Could not find theme #{theme} in #{paths}")
    end

    def add_event_source(source)
      @event_sources << source
    end

    def add_ical_feed(url)
      add_event_source EventSource::IcalFeed.new(url, connection: connection)
    end

    def add_events(events)
      add_event_source EventSource::Static.new(events)
    end

    def add_meetup_group(options)
      add_event_source EventSource::MeetupGroup.new(options.merge(connection: connection))
    end
  end
end
