To-Watch List
=============

This app is like the classic TODO list, but only for videos (therefore the name "to-watch"). It was mostly developed as an experiment to make a webapp in a more structured way, using Backbone.js and CoffeeScript. Sinatra is used in the backend just for simplicity (though a future migration to Rails is not discarded ;).

Working Demo
------------

See the app working at [here](http://to-watch.herokuapp.com/).

Development
-----------

* `git clone` this repo (or fork it).
* Run `bundle install` at the root of the project to install all necessary gems (you may also need to install some packages for mysql depending on your system).
* Run `ruby app.rb` or `rackup` and you are ready to go :)

TODO
----

The app still needs some major work to be something decent:

* Edit to-watch links.
* Detect video links (YouTube and maybe direct links to files) and play videos locally.
* Reorder to-watch items.
* User authentication! Now the list is shared between everyone. A simple authentication solution, like [OmniAuth](https://github.com/intridea/omniauth) could be used to associate users to to-watch lists (one list per user, private lists).
* A little refactoring would be welcomed (especially in the .coffee, which is quite messy ATM).

Pull requests and feature requests are more than welcome :)
