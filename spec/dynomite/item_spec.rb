class Post < Dynomite::Item
  field :title, :desc
end
class Comment < Dynomite::Item
  partition_key :post_id # defaults to :id
  sort_key :timestamp
end
module Ns
  class Pet < Dynomite::Item; end
end

describe Dynomite::Item do
  describe "general" do
    it "loads attributes" do
      post = Post.new(title: "my title", desc: "my desc")
      expect(post.attrs).to eq("title" => "my title", "desc" => "my desc")

      post.title = "my title2"
      expect(post.attrs).to eq("title" => "my title2", "desc" => "my desc")
    end

    it "table_name" do
      expect(Post.table_name).to eq "dynomite_posts"
      expect(Comment.table_name).to eq "dynomite_comments"
      expect(Ns::Pet.table_name).to eq "dynomite_ns_pets"
    end

    it "partition_key" do
      expect(Post.partition_key).to eq :id
      expect(Comment.partition_key).to eq :post_id
    end

    it "sort_key" do
      expect(Post.sort_key).to be_nil
      expect(Comment.sort_key).to eq :timestamp
    end

    it "uses defined column" do
      post = Post.new
      expect(post.title).to be_nil
      expect(post.attrs).to_not include('title')

      post.title = 'abc'
      expect(post.title).to eq 'abc'
      expect(post.attrs).to include('title')
    end

    it "tries to use undefined column" do
      post = Post.new
      expect do
        post.undefined_column
      end.to raise_exception(NoMethodError)

      post.attrs = {'undefined_column' => 'value'}

      # should not allow access while column is undefined
      expect do
        post.undefined_column
      end.to raise_exception(NoMethodError)

      Post.add_field(:undefined_column)

      expect do
        post.undefined_column
      end.to_not raise_exception
    end
  end

  describe "CRUD-ish" do
    before(:each) { Post.db = db }
    let(:db) { double(:db) }

    let(:find_resp) do
      fake_attributes = {"id" => "myid", "title" => "my title"}
      resp = double(:resp)
      expect(resp).to receive(:item).and_return(fake_attributes)
      resp
    end
    it "find" do
      expect(Post.db).to receive(:get_item).and_return(find_resp)

      post = Post.find("myid")

      expect(post.attrs.to_h).to eq(ActiveSupport::HashWithIndifferentAccess.new("id" => "myid", "title" => "my title"))
    end

    it "find with hash" do
      expect(Post.db).to receive(:get_item).and_return(find_resp)

      post = Post.find(id: "myid")

      expect(post.attrs).to eq("id" => "myid", "title" => "my title")
    end

    it "replace" do
      # Not returning a resp with receive because it is not useful
      # Dynanmodb doesnt provide much useful info there.
      expect(Post.db).to receive(:put_item)

      post = Post.new(title: "my title")
      post.save
      attrs = post.attrs

      expect(attrs[:title]).to eq "my title"
      expect(attrs[:id].size).to eq 40 # generated unique id
    end

    it "replace with hash" do
      # Not returning a resp with receive because it is not useful
      # Dynamodb doesnt provide much useful info there.
      expect(Post.db).to receive(:put_item)

      post = Post.new(title: "my title")
      post.attributes = {title: "my title 2"}
      post.save
      attrs = post.attributes

      expect(attrs[:title]).to eq "my title 2"
      expect(attrs[:id].size).to eq 40 # generated unique id
    end

    it "delete" do
      allow(Post.db).to receive(:delete_item)

      Post.delete("myid")

      expect(Post.db).to have_received(:delete_item)
    end

    it "delete_attribute" do
      expect(Post.db).to receive(:put_item)

      post = Post.new(title: "my title", extras: "anything you want")
      post.save
      expect(post.attrs[:extras]).to eq "anything you want"
      post.delete_attribute(:extras)
      expect(post.attrs.keys).to_not include('extras')
    end

    let(:scan_resp) do
      fake_attributes = [{"id" => "myid", "title" => "my title"}]
      resp = double(:resp)
      expect(resp).to receive(:items).and_return(fake_attributes)
      resp
    end
    it "scan" do
      allow(Post.db).to receive(:scan).and_return(scan_resp)

      Post.scan

      expect(Post.db).to have_received(:scan)
    end

    it "count" do
      table = double(:table)
      allow(Post).to receive(:table).and_return(table)
      expect(table).to receive(:item_count).and_return(1)

      expect(Post.count).to eq 1
    end

    it "reload" do
      fake_attributes = {"id" => "myid", "title" => "my title"}
      post_resp = double(:resp)
      expect(post_resp).to receive(:item).and_return(fake_attributes).twice
      expect(Post.db).to receive(:get_item).and_return(post_resp).twice

      post = Post.find(id: "myid")
      post.reload

      expect(post.attrs).to eq("id" => "myid", "title" => "my title")
    end

    it "reload with sort key" do
      fake_attributes = {"post_id" => "myid", "title" => "my title", "timestamp" => 12345}
      comment_resp = double(:resp)
      expect(comment_resp).to receive(:item).and_return(fake_attributes).twice

      expect(Comment.db).to receive(:get_item).
        with(table_name: 'dynomite_comments', key: { post_id: "myid", timestamp: 12345 }).
        and_return(comment_resp).twice

      comment = Comment.find(post_id: "myid", timestamp: 12345)
      comment.reload

      expect(comment.attrs).to eq("post_id" => "myid", "title" => "my title", "timestamp" => 12345)
    end
  end

  describe "validations" do
    class ValidatedItem < Dynomite::Item
      column :first, :second
      validates :first, presence: true
    end

    before(:each) { ValidatedItem.db = db }
    let(:db) { double(:db) }

    it "validates first column" do
      post = ValidatedItem.new
      expect(post.valid?).to be false
      expect(post.errors.messages).to include(:first)
      expect(post.errors.messages[:first].size).to eq 1
      expect(post.errors.messages[:first][0]).to eq "can't be blank"

      post.first = 'content'
      expect(post.valid?).to be true
      expect(post.errors.messages).to be_empty
    end

    it "ignores second column" do
      post = ValidatedItem.new
      expect(post.respond_to?(:second)).to be true

      post.valid? # runs validations

      expect(post.errors.messages).to_not include(:second)
    end

    it "validates on save" do
      post = ValidatedItem.new
      expect(post.save).to be false
      expect(post.errors.messages).to include(:first)

      expect(ValidatedItem.db).to receive(:put_item)

      post.first = 'content'
      expect(post.save).to_not be false
      expect(post.errors.messages.size).to eq 0
    end

    it "validates on save!" do
      post = ValidatedItem.new
      expect { post.save! }.to raise_error(Dynomite::Error::Validation)
      expect(post.errors.messages).to include(:first)

      expect(ValidatedItem.db).to receive(:put_item)

      post.first = 'content'
      expect{ post.save! }.to_not raise_error
      expect(post.errors.messages.size).to eq 0
    end
  end
end
