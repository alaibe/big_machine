# Big machine [![Build Status](https://secure.travis-ci.org/alaibe/big_machine.png)][travis] [![Dependency Status](https://gemnasium.com/alaibe/big_machine.png)][gemnasium] [![Code Climate](https://codeclimate.com/badge.png)][codeclimate]

[travis]: http://travis-ci.org/alaibe/big_machine
[gemnasium]: https://gemnasium.com/alaibe/big_machine
[codeclimate]: https://codeclimate.com/github/alaibe/big_machine

Big machine is a Gem which give state to your object

## Resources
Bugs

* http://github.com/alaibe/big_machine/issues

Development

* http://github.com/alaibe/big_machine

Testing

* http://travis-ci.org/alaibe/big_machine

Source

* git://github.com/alaibe/big_machine.git

## Install

Add this to your Gemfile
``` ruby
  gem 'big_machine'
```

## Usage

Create your first states
``` ruby
  class Draft < BigMachine::State
    def publish
      transition_to Online
    end
  end

  class Online < BigMachine::State
  end
```

Make your object stateful
``` ruby
  class Car
    include BigMachine

    big_machine initial_state: :draft
  end
```

Now it's possible to publish your car object:
``` ruby
  car = Car.new
  car.current_state # => Draft
  car.publish
  car.current_state # => Online
```

Of course your object can be an ActiveRecord::Base object. In this case, the object must have a state column. ( if not, see the next section )

## Big machine options

big_magine method can take several options:
* initial_state is the only one necessary option
* state_attribute is available only if the object is an active record object
* workflow if you want to change the normal worklow
It's possible to call workflow_is method in your different states

###example

``` ruby
  big_machine initial_state: :dradt, state_attribute: :big_state, workflow: small

  class Draft < BigMachine::State

    def publish
      return if workflow_is :small
      
      transition_to Online
    end

  end
```

## Lock module

A state can include lock module, it will lock the state of your object when your enter in it.
The unlock method should be call to unlock the module

``` ruby
  class Draft < BigMachine::State
    include BigMachine::Lock

    def publish
      transition_to Online
    end

  end

  class Article
    include BigMachine

    big_machine initial_state: :dradt
  end

  article = Article.new
  article.publish
  article.current_state # => Draft
  article.unlock
  article.publish
  article.current_state # => Online
```

## Contributors

*Anthony Laibe