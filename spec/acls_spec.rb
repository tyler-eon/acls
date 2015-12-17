require 'spec_helper'
require 'acls'

RSpec.describe ACLS::Loader do
  context '#auto' do
    def works?(modules)
      modules.each do |name|
        expect { Object.const_get(name) }.not_to raise_error
        expect(Object.const_get(name).works?).to be_truthy
      end
    end

    def lib_modules
      %w(One Two Sub::Three Sub::Four FIVE Six SevenEight Sub::CamelCase::NineTen)
    end

    def lib_root_modules
      %w(Root::One Root::Two Root::Sub::Three Root::Sub::Four Root::Sub::Five Root::Sub::Six)
    end

    def lib_foo_modules
      %w(Bar::One Bar::Two Bar::Sub::Three Bar::Sub::Four Bar::Sub::Five Bar::Sub::Six)
    end

    def spec_path(dir)
      "#{Dir.pwd}/spec/#{dir}"
    end

    context 'without a root namespace' do
      it do
        ACLS::Loader.auto(spec_path("lib"))
        works?(lib_modules)
      end
    end

    context 'with an implicit root namespace' do
      it do
        ACLS::Loader.auto(spec_path("lib/root"), root_ns: true)
        works?(lib_root_modules)
      end
    end

    context 'with a custom root namespace' do
      it do
        ACLS::Loader.auto(spec_path("lib/foo"), root_ns: "Bar")
        works?(lib_foo_modules)
      end
    end
  end
end
