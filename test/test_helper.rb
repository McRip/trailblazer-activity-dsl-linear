$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require "pp"
require "trailblazer-activity"
require "trailblazer/activity/dsl/linear"

require "minitest/autorun"

require "trailblazer/developer/render/circuit"


require "trailblazer/activity/testing"
T = Trailblazer::Activity::Testing

Minitest::Spec.class_eval do
  def Cct(activity)
    cct = Trailblazer::Developer::Render::Circuit.(activity)
  end

  def compile_process(sequence)
    process = Linear::Compiler.(sequence)
  end

  Linear = Trailblazer::Activity::DSL::Linear

  def assert_process(seq, *args)
    process = compile_process(seq)

    semantics, circuit = args[0..-2], args[-1]

    inspects = semantics.collect { |semantic| %{#<struct Trailblazer::Activity::Output signal=#<Trailblazer::Activity::End semantic=#{semantic.inspect}>, semantic=#{semantic.inspect}>} }

    process.to_h[:outputs].inspect.must_equal %{[#{inspects.join(", ")}]}

    cct = Cct(process: process)
    cct.must_equal %{#{circuit}}
  end

  Activity = Trailblazer::Activity

  let(:implementing) do
    implementing = Module.new do
      extend T.def_tasks(:a, :b, :c, :d, :f, :g)
    end
    implementing::Start = Activity::Start.new(semantic: :default)
    implementing::Failure = Activity::End(:failure)
    implementing::Success = Activity::End(:success)

    implementing
  end
end
