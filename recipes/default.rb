# The MIT License (MIT)

# Copyright (c) 2013 alisdair sullivan <alisdairsullivan@yahoo.ca>

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.


include_recipe "build-essential"
include_recipe "git"

prereqs = [
  "autoconf",
  "m4",
  "libncurses5-dev",
  "libssh-dev",
  "unixodbc-dev",
  "libgmp3-dev",
  "libwxgtk2.8-dev",
  "libglu1-mesa-dev",
  "fop",
  "xsltproc",
  "default-jdk"
]

prereqs.each do |pkg|
  package pkg
end

Array(node['erlang']['releases']).each do |r|
  prefix = r['prefix'] || node['erlang']['prefix']
  
  cache_path = Chef::Config['file_cache_path']

  erlang "#{prefix}" do
    git_url r['otp_git_url'] || node['erlang']['otp_git_url']
    ref r['otp_git_ref'] || node['erlang']['otp_git_ref']
    skip_apps (r['skip_apps'] || node['erlang']['skip_apps']).join(",")
    config_flags (r['config_flags'] || node['erlang']['config_flags']).join(" ")
  end
  
  if r['rebar'] || node['erlang']['rebar']
    rebar "#{prefix}" do
      git_url r['rebar_git_url'] || node['erlang']['rebar_git_url']
      ref r['rebar_git_ref'] || node['erlang']['rebar_git_ref']
    end  
  end
end

prereqs.each do |pkg|
  package pkg do
    action :purge
  end
end