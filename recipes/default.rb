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
  git_url = r['git_url'] || node['erlang']['git_url']
  version = r['version'] || node['erlang']['version']
  prefix = r['install_dir'] || node['erlang']['install_dir']
  skip = r['skip_apps'].join(",") || node['erlang']['skip_apps']
  config_flags = r['config_flags'].join(" ") || node['erlang']['config_flags']
  rebar = r['rebar'] || node['erlang']['rebar']
  
  cache_path = Chef::Config['file_cache_path']

  git "erlang/otp" do
    repository git_url
    destination "#{cache_path}/otp"
  end
  
  bash "install #{version} to #{prefix}" do
    code <<-EOS
cp -r #{cache_path}/otp #{cache_path}/#{version}
cd #{cache_path}/#{version}
git checkout #{version}
./otp_build autoconf
./configure --prefix=#{prefix} #{config_flags}
touch lib/{#{skip}}/SKIP
make && make install
EOS
    not_if { FileTest.exists?("#{prefix}/bin/erl") }
  end
  
  if rebar
    git "rebar for #{prefix}" do
      repository "git://github.com/rebar/rebar.git"
      destination "#{cache_path}/rebar"
    end
    
    bash "install rebar to #{prefix}/bin" do
      code <<-EOH
cp -r #{cache_path}/rebar #{cache_path}/rebar-#{version}
cd #{cache_path}/rebar-#{version}
#{prefix}/bin/escript bootstrap
cp rebar #{prefix}/bin
EOH
      not_if { FileTest.exists?("#{prefix}/bin/rebar") }
    end
  end

end

prereqs.each do |pkg|
  package pkg do
    action :purge
  end
end