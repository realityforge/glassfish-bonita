task "ci:package" => %w(clean bonita:package xcmis:package)
