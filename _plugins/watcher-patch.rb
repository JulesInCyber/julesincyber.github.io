require 'jekyll-watch'

module Jekyll
    module Watcher
        extended self

        alias_method :original_listen_ignore_paths, :listen_ignore_paths
        
        def listen_ignore_paths(options)
            original_listen_ignore_paths(options) + [%r!.*\.TMP!i]
        end
    end
end
