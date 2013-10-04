# Conformista [![Build Status](https://secure.travis-ci.org/avdgaag/conformista.png?branch=master)](http://travis-ci.org/avdgaag/conformista) [![Code Climate](https://d3s6mut3hikguw.cloudfront.net/github/avdgaag/conformista.png)](https://codeclimate.com/github/avdgaag/conformista)

## Introduction

Conformista is a library to make building presenters -- and form objects in
particular -- easier. It provides an ActiveModel-compliant base class that your
own form objects can inherit from, along with standard behaviour for creating,
loading, validating and persisting business objects (usually ActiveRecord
models).

## Installation

Conformista is distributed as a Ruby gem, which should be installed on most Macs and
Linux systems. Once you have ensured you have a working installation of Ruby
and Ruby gems, install the gem as follows from the command line:

    $ gem install conformista

To use it with Bundler, add it to your `Gemfile`:

    gem 'conformista'

Then install it by running `bundle install`.

## Usage

The canonical example of a form object is a sign up form. Let's say we want to
let a visitor to our Rails application sign up for an account. That will include
creating an `Account`, `User` and `Profile`.

```ruby
class Account < ActiveRecord::Base
  validates :name, presence: true
end

class User < ActiveRecord::Base
  validates :email, :password, presence: true
  has_secure_password
end

class Profile < ActiveRecord::Base
end
```

Instead of using `accepts_nested_attributes_for`, or cramming all the data in
the `User` model, or using a lot of controller logic, we use a form object to
present these three entities as a single object to the view:

```ruby
class SignupController < ApplicationController
  def new
    @signup = Signup.new
  end

  def create
    @signup = Signup.new(params[:signup])
    if @signup.save
      redirect_to root_url, notice: 'Thanks for signing up!'
    else
      render 'new'
    end
  end
end
```

The single object we use is a form object that inherits from
`Conformista::FormObject`:

```ruby
class Signup < Conformista::FormObject
  presents User    => %i[email password],
           Account => %i[name],
           Profile => %i[bio twitter github]

  attr_accessor :password_confirmation,
                :terms_and_conditions

  validates :password, confirmation: true
  validates :terms_and_conditions, acceptance: true

  after_save :deliver_welcome_email

  private

  def deliver_welcome_email
    Notifications.welcome_email(user).deliver
  end
end
```

We can now generate a form for our form object:

```erb
<%= form_for @signup, url: signup_path do |f| %>
  <p>
    <%= f.label :name %><br>
    <%= f.text_field :name %>
  </p>
  <p>
    <%= f.label :email %><br>
    <%= f.text_field :email %>
  </p>
  <p>
    <%= f.label :password %>
    <%= f.password_field :password %>
  </p>
  <p>
    <%= f.label :password_confirmation %><br>
    <%= f.password_field :password_confirmation %>
  </p>
  <p>
    <%= f.label :bio %><br>
    <%= f.text_area :bio %><br>
  </p>
  <p>
    <%= f.label :twitter %><br>
    <%= f.text_field :twitter %><br>
  </p>
  <p>
    <%= f.label :github %><br>
    <%= f.text_field :github %><br>
  </p>
  <p>
    <%= f.check_box :terms_and_conditions %>
    I have read and agree to the terms and conditions
  </p>
  <p>
    <%= f.submit %>
  </p>
<% end %>
```

Note how the logic specifically tied to the form, like the acceptance and
confirmation validations, and the email delivery, have been moved out of the
model layer into the presenter layer. However, the single presenter object
will re-use the data-specific validations defined in the model.

### Documentation

See the inline [API
docs](http://rubydoc.info/github/avdgaag/conformista/master/frames) for more
information.

## Other

### Note on Patches/Pull Requests

1. Fork the project.
2. Make your feature addition or bug fix.
3. Add tests for it. This is important so I don't break it in a future version
   unintentionally.
4. Commit, do not mess with rakefile, version, or history. (if you want to have
   your own version, that is fine but bump version in a commit by itself I can
   ignore when I pull)
5. Send me a pull request. Bonus points for topic branches.

### Issues

Please report any issues, defects or suggestions in the [Github issue
tracker](https://github.com/avdgaag/conformista/issues).

### What has changed?

See the [HISTORY](https://github.com/avdgaag/conformista/blob/master/HISTORY.md) file
for a detailed changelog.

### Credits

Created by: Arjan van der Gaag  
URL: [http://arjanvandergaag.nl](http://arjanvandergaag.nl)  
Project homepage: [http://avdgaag.github.com/conformista](http://avdgaag.github.com/conformista)  
Date: september 2013  
License: [MIT-license](https://github.com/avdgaag/conformista/blob/master/LICENSE) (same as Ruby)
