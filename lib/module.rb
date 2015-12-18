code = <<EOS
def submodule(name)
  const_get(name, false)
rescue NameError
  const_set(name, Module.new)
end
EOS

Module.module_eval(code)
