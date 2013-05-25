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
  prefix = new_resource.prefix || node['erlang']['prefix']

  git_url = new_resource.git_url || node['erlang']['otp_git_url']
  ref = new_resource.ref || node['erlang']['otp_git_ref']
  skip_apps = new_resource.skip_apps || node['erlang']['skip_apps']
  config_flags = new_resource.config_flags || node['erlang']['config_flags']
  user = new_resource.user
  group = new_resource.group
  
  cache_path = Chef::Config['file_cache_path']
  
  if FileTest.exists? "#{prefix}/bin/erl"
    Chef::Log.info "#{prefix}/bin/erl already exists"
  else
    converge_by("Create #{ref} in #{prefix}") do
      
      git "erlang otp" do
        user user
        group group
        repository git_url
        destination "#{cache_path}/otp"
        action :sync
      end
      
      bash "install #{ref} to #{prefix}" do
        user user
        group group
        code <<-EOS
cp -r #{cache_path}/otp #{cache_path}/#{ref}
cd #{cache_path}/#{ref}
git checkout #{ref}
./otp_build autoconf
./configure --prefix=#{prefix} #{config_flags}
if [ -n #{skip_apps} ]; then
  touch lib/{#{skip_apps}}/SKIP
fi
make && make install
EOS
      end
    end
  end
end

action :delete do
  prefix = new_resource.prefix || node['erlang']['prefix']
  
  if !FileTest.exists? "#{prefix}/bin/erl"
    Chef::Log.info "#{new_resource} not installed"
  else
    converge_by("Delete #{ref} from #{prefix}") do
      directory "#{prefix}" do
        recursive true
        action :delete
      end
    end
  end
end