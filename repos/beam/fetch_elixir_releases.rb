# frozen_string_literal: true

require 'octokit'
require 'semantic'

def get_tarball_url(version)
  "https://github.com/elixir-lang/elixir/archive/v#{version}.tar.gz"
end

def get_version(r)
  r[:name].gsub('v', '')
end

def dir(version)
  major_minor = version.match(/(\d+\.\d+)/)[1]
  "pkgs/development/interpreters/elixir/#{major_minor}"
end

def nix_path(version)
  "#{dir(version)}/#{version}.nix"
end

def new_version?(version)
  !File.exist?(nix_path(version))
end

def not_rc_or_patch?(version)
  version.match(/\A\d+\.\d+\.\d+(?:\.0)?\Z/)
end

def version_in_range?(version)
  v = Semantic::Version.new(version)
  (v.major >= 2) || ((v.major == 1) && (v.minor >= 5) && v.pre.nil?)
end

def nix_prefetch_sha256(url)
  output = `nix-prefetch-url --unpack #{url}`
  output.strip
end

def template_path(version)
  "#{dir(version)}/template.nix"
end

def get_template(version)
  if File.exist?(template_path(version))
    File.read(template_path(version))
  else
    <<~EOF
      { mkDerivation }:

      mkDerivation {
        version = "<<VERSION>>";
        sha256 = "<<SHA256>>";
        minimumOTPVersion = "20";
      }
    EOF
  end
end

def write_nix(version, sha256)
  template = get_template(version)
  content = template.gsub('<<VERSION>>', version).gsub('<<SHA256>>', sha256)
  path = nix_path(version)
  FileUtils.mkdir_p(File.dirname(path))
  File.write(path, content)
end

def fetch_releases
  client = Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])
  client.auto_paginate = true
  client.tags 'elixir-lang/elixir'
end

def fetch_new_releases
  fetch_releases.filter do |r|
    v = get_version(r)
    new_version?(v) && not_rc_or_patch?(v) && version_in_range?(v)
  end
end

def write_version(version)
  url = get_tarball_url(version)
  sha256 = nix_prefetch_sha256(url)

  write_nix(version, sha256)
end

def write_new_releases
  fetch_new_releases.map { |r| write_version(get_version(r)) }
end

write_new_releases if ENV['GITHUB_ACTIONS']
