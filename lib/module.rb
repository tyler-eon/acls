code = <<EOS
def submodule(name)
  const_get(name)
rescue NameError
  const_set(name, Module.new)
end
EOS

Module.module_eval(code)
