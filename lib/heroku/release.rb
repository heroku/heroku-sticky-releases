require "heroku/command/base"

Heroku::Command.global_option :release, "--release RELEASE", "-r"

class Heroku::Command::Process < Heroku::Command::Base

  def index
    ps = api? ? ap.get_ps(app).body : heroku.ps(app)
    puts ps.inspect
  end
end
