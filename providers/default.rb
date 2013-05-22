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


def whyrun_supported?
  true
end

action :create do 
  install_dir = new_resource.install_dir || node['erlang']['install_dir']

  git_url = new_resource.git_url || node['erlang']['git_url']
  version = new_resource.version || node['erlang']['version']
  
  cache_path = Chef::Config['file_cache_path']
  
  if FileTest.exists? "#{install_dir}/bin"
    Chef::Log.info "#{new_resource} already exists"
  else
    converge_by("Create #{version} in #{install_dir}") do
      
      git "erlang otp" do
        repository git_url
        reference version
        destination "#{cache_path}/otp"
        action :sync
      end
      
      bash "install #{version} to #{install_dir}" do
        code <<-EOS
cp -r #{cache_path}/otp #{cache_path}/#{version}
cd #{cache_path}/#{version}
git checkout #{version}
./otp_build autoconf
./configure --prefix=#{install_dir} #{config_flags}
touch lib/{#{skip}}/SKIP
make && make install
EOS
      end
      
      if rebar
        git "rebar for #{install_dir}" do
          repository "git://github.com/rebar/rebar.git"
          destination "#{cache_path}/rebar"
        end
    
        bash "install rebar to #{install_dir}/bin" do
          code <<-EOH
cp -r #{cache_path}/rebar #{cache_path}/rebar-#{version}
cd #{cache_path}/rebar-#{version}
#{install_dir}/bin/escript bootstrap
cp rebar #{install_dir}/bin
EOH
        end
      end
      
    end
  end
end