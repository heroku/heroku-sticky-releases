require "heroku/command/base"

Heroku::Command.global_option :release, "--release RELEASE", "-r"


class Heroku::Command::Ps < Heroku::Command::Base

  def index
    validate_arguments!
    processes = api.get_ps(app).body

    processes_by_command = Hash.new {|hash,key| hash[key] = []}
    processes.each do |process|
      name    = process["process"].split(".").first
      elapsed = time_ago(Time.now - process['elapsed'])

      if name == "run"
        key  = "run: one-off processes"
        item = "%s: v%s %s %s: `%s`" % [ process["process"], process["release"], process["state"], elapsed, process["command"] ]
      else
        key  = "#{name}: `#{process["command"]}`"
        item = "%s: v%s %s %s" % [ process["process"], process["release"], process["state"], elapsed ]
      end

      processes_by_command[key] << item
    end

    processes_by_command.keys.each do |key|
      processes_by_command[key] = processes_by_command[key].sort do |x,y|
        x.match(/\.(\d+):/).captures.first.to_i <=> y.match(/\.(\d+):/).captures.first.to_i
      end
    end

    processes_by_command.keys.sort.each do |key|
      styled_header(key)
      styled_array(processes_by_command[key], :sort => false)
    end
  end

  def restart
    process = shift_argument
    validate_arguments!
    release = options[:release]

    message, options = case process
    when NilClass
      ["Restarting processes", { }]
    when /.+\..+/
      ps = args.first
      ["Restarting #{ps} process", { :ps => ps }]
    else
      type = args.first
      ["Restarting #{type} processes", { :type => type }]
    end

    action(message) do
      api.post_ps_restart(app, options.merge(:release => release))
    end
  end

  alias_command "deploy", "ps:restart"

  def scale
    release = options[:release]
    changes = {}
    args.each do |arg|
      if arg =~ /^([a-zA-Z0-9_]+)([=+-]\d+)$/
        changes[$1] = $2
      end
    end

    if changes.empty?
      error("Usage: heroku ps:scale PROCESS1=AMOUNT1 [PROCESS2=AMOUNT2 ...]\nMust specify PROCESS and AMOUNT to scale.")
    end

    changes.keys.sort.each do |process|
      amount = changes[process]
      action("Scaling #{process} processes") do
        amount.gsub!("=", "")
        new_qty = api.request(
          :expects    => 200,
          :method     => :post,
          :path       => "/apps/#{app}/ps/scale",
          :query      => {
            'type'    => process,
            'qty'     => amount,
            'release' => release
          }
        ).body
        status("now running #{new_qty}")
      end
    end
  end
end

class Heroku::Command::Run < Heroku::Command::Base

  def detached
    command = args.join(" ")
    error("Usage: heroku run COMMAND")if command.empty?
    opts = { :attach => false, :command => command }
    release = options[:release]
    process_data = action("Running `#{command}` detached", :success => "up") do
      process_data = api.post_ps(app, command, { :attach => false, :release => release }).body
      status(process_data['process'])
      process_data
    end
    display("Use `heroku logs -p #{process_data['process']}` to view the output.")
  end

protected
  def run_attached(command)
    release = options[:release]
    process_data = action("Running `#{command}` attached to terminal", :success => "up") do
      process_data = api.post_ps(app, command, { :attach => true, :ps_env => get_terminal_environment, :release => release }).body
      status(process_data["process"])
      process_data
    end
    rendezvous_session(process_data["rendezvous_url"])
  end
end
