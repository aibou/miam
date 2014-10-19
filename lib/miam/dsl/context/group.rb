class Miam::DSL::Context::Group
  def initialize(name, &block)
    @group_name = name
    @result = {:policies => {}}
    instance_eval(&block)
  end

  attr_reader :result

  private

  def policy(name)
    name = name.to_s

    if @result[:policies][name]
      raise "Group `#{@group_name}` > Policy `#{name}`: already defined"
    end

    policy_document = yield

    unless policy_document.kind_of?(Hash)
      raise "Group `#{@group_name}` > Policy `#{name}`: wrong argument type #{policy_document.class} (expected Hash)"
    end

    @result[:policies][name] = policy_document
  end
end
