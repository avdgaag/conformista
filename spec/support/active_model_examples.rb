shared_examples_for 'ActiveModel' do
  it '#to_key' do
    expect(model).to respond_to(:to_key)
    def model.persisted?() false end
    expect(model.to_key).to be_nil
  end

  it '#to_param' do
    expect(model).to respond_to(:to_param)
    def model.to_key() [1] end
    def model.persisted?() false end
    expect(model.to_param).to be_nil
  end

  it '#to_partial_path' do
    expect(model).to respond_to(:to_partial_path)
    expect(model.to_partial_path).to be_kind_of(String)
  end

  it '#persisted?' do
    expect(model).to respond_to(:persisted?)
    expect { model.persisted? == true || model.persisted? == false }
  end

  it 'model naming' do
    expect(model.class).to respond_to(:model_name)
    model_name = model.class.model_name
    expect(model_name).to respond_to(:to_str)
    expect(model_name.human).to respond_to(:to_str)
    expect(model_name.singular).to respond_to(:to_str)
    expect(model_name.plural).to respond_to(:to_str)
  end

  it 'errors aref' do
    expect(model).to respond_to(:errors)
    expect(model.errors[:hello]).to be_a(Array)
  end

  private

  def model
    subject
  end
end
