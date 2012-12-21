require "heroku/command/base"
Heroku::Command.global_option :release, "--release RELEASE", "-r"

# deploy release into production
class Heroku::Command::Deploy < Heroku::Command::Base

  # deploy [PROCESS] [-r RELEASE]
  #
  # deploy release to process
  #
  # if PROCESS is not specified, RELEASE is deployed to all processes on the app
  # if RELEASE is not specified, latest release is used
  #
  #Examples:
  #
  # $ heroku deploy web
  # Deploying web processes... done
  #
  # $ heroku deploy web.1
  # Deploying web.1 process... done
  #
  #
  # $ heroku deploy web.1-3
  # Deploying web.1 process... done
  # Deploying web.2 process... done
  # Deploying web.3 process... done
  #
  #
  # $ heroku deploy -web
  # Deploying worker processes... done
  # Deploying urgentworker processes... done
  #
  def index
    process = shift_argument
    validate_arguments!
    release = options[:release]

    deploys = case process
    when NilClass
      [["Deploying processes", { }]]
    when /.+\..+/
      processes = args.first
      if processes =~ /(.*)\.(\d+\-\d+)/
        type = $1
        processes = $2.split("-").map{|p| "#{type}.#{p}" }
      else
        processes = [processes]
      end
      processes.map do |ps|
        ["Deploying #{ps} process", { :ps => ps }]
      end
    else
      type = args.first
      if type =~ /\A\-(.*)/
        types = api.get_ps(app).body.map{|ps| ps["process"].split(".")[0] }.uniq
        types.reject!{|type| type == $1 }
        types.map do |type|
          ["Deploying #{type} processes", { :type => type }]
        end
      else
        [["Deploying #{type} processes", { :type => type }]]
      end
    end
    deploys.each do |message, options|
      action(message) do
        api.post_ps_restart(app, options.merge(:release => release))
      end
    end
  end

end
