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
    'focus .comment':         'removeCommentPlaceholder'
    'click .delete':          'delete'

  initialize:->
    @model.on 'change', @render
    @model.on 'destroy', @remove
    @render()

  render:=>
    # Renders the template only once. Prevents from re-creating a field when the
    # user is typing in it.
    unless @$el.text()
      # TODO The entity &#10006; is "heavy multiplication x", but for some
      # encoding problem I could not use it directly here :(
      @$el.html """
        <input type="checkbox" />
        <a class="title" target="_blank"></a>
        <p class="comment" contenteditable />
        <div class="delete" title="Delete">&#10006;</div>
      """
    watched = @model.get 'watched'
    @$(':checkbox').prop
      'checked': watched
      'title': "Mark as #{if watched then 'unwatched' else 'watched'}"
    @$('.title').text @model.get('title') || @model.get('link')
    @$('.title').prop 'href', @model.get('link')
    @$('.comment').text @model.get 'comment'
    @$('.comment').addClass 'empty-comment' unless @model.get 'comment'
    @

  toggleWatched:->
    @model.toggle()
    @model.save()

  updateComment:->
    @model.set comment: @$('.comment').text()
    @model.save()
    @$('.comment').addClass 'empty-comment' unless @$('.comment').text()

  updateCommentOnEnter:(event)->
    @$(event.target).removeClass 'empty-comment'
    if event.keyCode == 13
      @$('.comment').blur()

  removeCommentPlaceholder:->
    @$('.comment').removeClass 'empty-comment' if @$('.comment').text()

  delete:->
    @model.destroy()

  # Override Backbone's remove.
  remove:=>
    @$el.hide 'fast', => @$el.remove()

  fadeIn:->
    @$el.fadeIn 'fast'

  focusComment:->
    @$('.comment').focus()

class ToWatchListView extends Backbone.View

  initialize:->
    @collection.each @addToWatch
    @collection.on 'add', @addNewToWatch

  addNewToWatch: (toWatch) =>
    twView = @addToWatch toWatch
    twView.fadeIn()
    twView.focusComment()

  addToWatch:(toWatch) =>
    twView = new ToWatchView model:toWatch
    @$el.prepend twView.el
    twView

class CreateToWatchView extends Backbone.View
  events:
    'click .add':     'addToWatch'
    'keypress input': 'addToWatchOnEnter'
  initialize:->
    @render()

  render:->
    @$el.html """
      <input type="text" placeholder="Paste video link to watch later"/>
      <span class="add">Add</span>
    """

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
    @$el.html """
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
      </div>
    """
