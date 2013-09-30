module Conformista
  describe FormObject do
    it_should_behave_like 'ActiveModel'

    it { should respond_to(:save) }
    it { should have(0).presented_models }

    context 'when presenting a single model' do
      let(:example_form_object_class) do
        Class.new(described_class) do
          presents Post, :title
          validates :title, length: { minimum: 2, allow_blank: true }
        end
      end

      before do
        stub_const('Example', example_form_object_class)
      end

      subject { example_form_object_class.new }

      it { should have(1).presented_models }
      its(:presented_models) { should include(Post) }
      its(:post) { should be_instance_of(Post) }
      it { should_not be_persisted }

      it 'is persisted after saving' do
        subject.title = 'foo'
        subject.save
        expect(subject).to be_persisted
      end

      it 'can be created using an existing record' do
        post = Post.new
        example = example_form_object_class.new(post: post)
        expect(example.post).to be(post)
      end

      it 'can customize the build strategy' do
        example = example_form_object_class.new
        def example.build_post; 'foo'; end
        expect(example.post).to eql('foo')
      end

      it 'delegates listed attributes to the model before validating' do
        subject.title = 'foo'
        subject.valid?
        expect(subject.post.title).to eql('foo')
      end

      it 'reads attributes from models when initializing' do
        post = Post.new
        post.title = 'foo'
        example = example_form_object_class.new(post: post)
        expect(example.title).to eql('foo')
      end

      it 'validates the model when validating the form object' do
        expect(subject.post).to receive(:valid?)
        subject.valid?
      end

      it 'copies validation errors to the form object' do
        subject.valid?
        expect(subject).to have(1).errors
      end

      it 'saves the post when valid' do
        subject.title = 'foo'
        expect(subject).to be_valid
        expect { subject.save }.to change { Post.count }.by(1)
      end

      it 'does not save the post when invalid' do
        expect(subject.post).not_to receive(:save)
        expect { subject.save }.not_to change { Post.count }
      end

      it 'sets and saves attributes with update_attributes' do
        subject.title = 'foo'
        subject.save
        expect {
          subject.update_attributes title: 'bla'
        }.to change { subject.post.title }.from('foo').to('bla')
      end

      it 'uses own validations to generate errors' do
        subject.title = 'x'
        expect(subject).not_to be_valid
        expect(subject.errors[:title]).to include('is too short (minimum is 2 characters)')
      end
    end

    context 'when presenting two models' do
      let(:example_form_object_class) do
        Class.new(described_class) do
          presents Post, :title
          presents Comment, :body
        end
      end

      before { stub_const('Example', example_form_object_class) }
      subject { example_form_object_class.new }
      it { should have(2).presented_models }
      its(:presented_models) { should include(Comment) }
      its(:comment) { should be_instance_of(Comment) }
      it { should_not be_persisted }

      it 'is persisted after saving' do
        subject.title = 'foo'
        subject.body = 'bar'
        subject.save
        expect(subject).to be_persisted
      end

      it 'does not save one model when the other fails' do
        subject.title = 'foo'
        subject.body = 'bar'
        expect(subject.post).to receive(:save).and_return(false)
        expect {
          subject.save
        }.not_to change { Comment.count }
      end
    end
  end
end
