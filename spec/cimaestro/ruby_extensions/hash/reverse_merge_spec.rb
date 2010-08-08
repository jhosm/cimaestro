module CIMaestro
  module RubyExtensions
    module Hash
      describe ReverseMerge do
        it "should add hash values only if they don't exist" do
          actual = {:chave1 => "ola"}.reverse_merge({:chave1=>"valor1", :chave2 => "valor2"})
          actual.should have_key(:chave1)
          actual[:chave1].should == "ola"
          actual.should have_key(:chave2)
          actual[:chave2].should == "valor2"

          actual =  {:chave1 => "ola"}
          actual.reverse_merge!({:chave1=>"valor1", :chave2 => "valor2"})
          actual.should have_key(:chave1)
          actual[:chave1].should == "ola"
          actual.should have_key(:chave2)
          actual[:chave2].should == "valor2"
        end
      end
    end
  end
end