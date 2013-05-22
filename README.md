# chef-erlang (v0.1) #

a chef recipe for erlenv

## usage ##

### installing erlang ###

include `recipe[erlang]` in your `run_list` and add releases to the `releases`
attribute list. for example:

```ruby
node.default['erlang']['releases'] = [
	{ 
		'release' => 'r16b'
	},
  {
    'release' => 'r15b03-1'
  }
]
```

this will install `r16b` and `r15b03-1` in the default location

the following attributes are also available to override:

* `installdir`
  the dir to install `erlang` to. this just sets `--prefix` in the
  configure script
* `git_url`
  the url of the git repository to clone the release from
* `version`
  a git reference to install
* `skip`
  a list of applications to skip during compilation
* `config`
  a list of flags to pass to the configure script


## license ##

The MIT License (MIT)

Copyright (c) 2013 alisdair sullivan <alisdairsullivan@yahoo.ca>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.