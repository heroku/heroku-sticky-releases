$:.unshift(File.expand_path(File.join(Dir.getwd, "lib")))

require "heroku/release"
require "heroku/deploy"
