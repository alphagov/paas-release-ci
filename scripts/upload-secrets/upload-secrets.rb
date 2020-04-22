require "English"
require "yaml"
require "tempfile"

def upload_secrets(secrets)
  credentials = { "credentials" => secrets }

  Tempfile.create("credhub-secrets") do |f|

    f.write(credentials.to_yaml)
    f.flush

    pid = spawn(
      "credhub import -f '#{f.path}'",
      in: STDIN, out: STDOUT, err: STDERR,
    )

    Process.wait pid
    raise 'Child process did not exit successfully' unless $CHILD_STATUS.success?
  end
end
