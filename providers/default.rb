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

  otp_url = new_resource.otp_url || node['erlang']['otp_url']
  release = new_resource.release || node['erlang']['release']
  skip_apps = new_resource.skip_apps || node['erlang']['skip_apps']
  config_flags = new_resource.config_flags || node['erlang']['config_flags']
  user = new_resource.user
  group = new_resource.group
  
  cache_path = Chef::Config['file_cache_path']
  
  if FileTest.exists? "#{install_dir}/bin"
    Chef::Log.info "#{new_resource.install_dir} already exists"
  else
    converge_by("Create #{release} in #{install_dir}") do
      
      git "erlang otp" do
        user user
        group group
        repository otp_url
        destination "#{cache_path}/otp"
        action :sync
      end
      
      bash "install #{release} to #{install_dir}" do
        user user
        group group
        code <<-EOS
cp -r #{cache_path}/otp #{cache_path}/#{release}
cd #{cache_path}/#{release}
git checkout #{release}
./otp_build autoconf
./configure --prefix=#{install_dir} #{config_flags}
touch lib/{#{skip_apps}}/SKIP
make && make install
EOS
      end
    end
  end
end

action :delete do
  install_dir = new_resource.install_dir || node['erlang']['install_dir']
  
  if !FileTest.exists? "#{install_dir}/bin/erl"
    Chef::Log.info "#{new_resource} not installed"
  else
    converge_by("Delete #{release} from #{install_dir}") do
      directory "#{install_dir}" do
        recursive true
        action :delete
      end
    end
  end
end