class window.ToWatch extends Backbone.Model
  defaults:
    comment: ''
  toggle:->
    @set 'watched': !@get 'watched'

class window.ToWatchList extends Backbone.Collection
  model: ToWatch
  url:'/towatch'

class ToWatchView extends Backbone.View
  className: 'to-watch-item',
  events:
    'click :checkbox':        'toggleWatched'
    'blur .comment':          'updateComment'
    'keydown .comment':       'updateCommentOnEnter'
    'click .delete':          'delete'

  initialize:->
    @model.bind 'change', @render
    @model.bind 'destroy', @remove
    @render()

  render:=>
    watched = @model.get 'watched'
    if $(@el).text() == ''
      $(@el).html """
        <input type="checkbox" />
        <a class="title"></a>
        <p class="comment" contenteditable />
        <div class="delete" title="Delete">&#10006;</div>
        """ # TODO The entity &#10006; is "heavy multiplication x", but for some encoding problem I could not use it directly here :(
    @$(':checkbox').prop
      'checked': watched
      'title': "Mark as #{if watched then 'unwatched' else 'watched'}"
    @$('.title').text @model.get('title') || @model.get('link')
    @$('.title').prop 'href', @model.get('link')
    @$('.comment').text @model.get 'comment'
    @

  toggleWatched:->
    @model.toggle()
    @model.save()

  updateComment:->
    @model.set comment: @$('.comment').text()
    @model.save()

  updateCommentOnEnter:(event)->
    if event.keyCode == 13
      @updateComment()
      @$('.comment').blur()

  delete:->
    @model.destroy()

  # Override Backbone's remove.
  remove:=>
    $el = $(@el)
    $el.hide 'fast', => $el.remove()

  fadeIn:->
    $(@el).fadeIn 'fast'

  focusComment:->
    @$('.comment').focus()

class ToWatchListView extends Backbone.View

  initialize:->
    @collection.each @addToWatch
    @collection.bind 'add', @addNewToWatch

  addNewToWatch: (toWatch) =>
    twView = @addToWatch toWatch
    twView.fadeIn()
    twView.focusComment()

  addToWatch:(toWatch) =>
    twView = new ToWatchView model:toWatch
    $(@el).prepend twView.el
    twView

class CreateToWatchView extends Backbone.View
  events:
    'click .add':     'addToWatch'
    'keypress input': 'addToWatchOnEnter'
  initialize:->
    @render()

  render:->
    $(@el).html """
      <input type="text" placeholder="Paste video link to watch later"/>
      <span class="add">Add</span>"""

  addToWatch:->
    link = @$('input').val()
    return unless link
    toWatch = new ToWatch link: link
    @collection.add toWatch
    toWatch.save()
    @$('input').val ''

  addToWatchOnEnter:(event)->
    if event.keyCode == 13
      @addToWatch()


class window.AppView extends Backbone.View

  initialize:->
    @render()
    @toWatchList = new ToWatchList(@options.toWatch || [])
    new CreateToWatchView collection: @toWatchList, el: @$('.new')
    new ToWatchListView   collection: @toWatchList, el: @$('.to-watch-list')

  render:->
    $(@el).html """
      <div class="container">
        <h1>To-Watch</h1>
        <div class="new"></div>
        <div class="to-watch-list"></div>
      </div>
      <div class="credits">
        Created by <a href="https://github.com/epidemian">Demian Ferreiro</a> @ <a href="https://github.com/FDVSolutions">FDV Solutions</a>
      </div>
      <div class="ribbon">
        <a href="https://github.com/epidemian/to-watch-list">Fork me on GitHub</a>
      </div>"""
