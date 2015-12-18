# automatic code loading system (acls)

[![Build Status](https://semaphoreci.com/api/v1/projects/80ef69fb-3dd1-499f-9e1c-acfa08d0a7d4/638892/badge.svg)](https://semaphoreci.com/kolorahl/acls)

## What is it?

The Automatic Code Loading System (ACLS) is a Ruby library intended to help
speed up and simplify development time by allowing developers to define pathes
and patterns of files that should be autoloaded when their application runs.

## How does it work?

Rails does something like this. In a Rails application you would change your
autoloading paths as such:

```ruby
config.autoload_paths += ['lib', 'other/lib', 'etc'].map { |folder| "#{config.root}/#{folder}" }
```

Rails will then look for all Ruby files in those directory trees and load them
for immediate use into your application. However, Rails does this in a very
complex manner by taking over the flow for when a constant isn't found. ACLS
does **not** do that. I have chosen a more straight-forward solution, which
simply generates an `autoload` statement for all Ruby files in a set of paths.

As an example, assume the following directory structure:

```
- lib
| - one.rb
| - two.rb
| - sub
| | - three.rb
- other
| - four.rb
```

Pass in the desired directory paths into the ACLS module:

```ruby
ACLS::Loader.auto(['lib', 'other'])
```

That one line with ACLS is equivalent to hand-writing the following Ruby code:

```ruby
autoload :One, 'lib/one.rb'
autoload :Two, 'lib/two.rb'
module Sub
  autoload :Three, 'lib/sub/three.rb'
end
autoload :Four, 'other/four.rb'
```

## Using it

The simplest way is to use:

```ruby
ACLS::Loader.auto(['path', 'to/one/or/more', 'directories'])
```

ACLS will automatically generate new module constants if it needs to. This
method of autoloading, however, makes assumptions about the directory
structure. The top-level directory is assumed to carry no namespace but every
sub-directory under that *does* imply a namespace. To customize bits of the
behavior, an options hash can be passed in as a second argument:

```ruby
ACLS::Loader.auto('lib', {root_ns: true})
```

Options available:

- `root_ns`: When `true`, this will use the top-level directory name as the root
  namespace for all files and folders in the tree. When a string is supplied,
  this will use the string as the name of the root namespace. For all other
  values, the root directory is not a namespace and everything falls under the
  `Object` namespace.
- `exclude`: Must be a collection of strings and/or regexps. For each string in
  the collection, files are excluded from autoloading if they match the string
  exactly. For each regexp in the collection, files are excluded from
  autoloading if the path results in a successful match on the regexp.
- `immediate`: Must be a collection of strings and/or regexps. Follows the same
  conditional pattern as `exclude`, but on a match this will immediate load the
  file via `load` instead of deferring it using `autoload`.

## Feature List

### Core

- [X] Generate `autoload` statements based on a set of directory paths.

### Options/Configuration

- [X] Implement `root_ns`.
- [ ] Implement `exclude`.
- [ ] Implement `immediate`.
