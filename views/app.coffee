class Video extends Backbone.Model
  defaults:
    comment: ''
  toggle:->
    @set 'watched': !@get 'watched'

class window.VideoList extends Backbone.Collection
  model: Video,
  url:'/videos'

class VideoView extends Backbone.View
  className: 'video',
  events:
    'click :checkbox': 'toggleWatched'
    'blur .title, .comment': 'updateContent'
    'click .delete': 'delete'

  initialize:->
    @model.bind 'change', @render
    @model.bind 'destroy', @remove, @ # remove is a method of Backbone.View.

  render:=>
    watched = @model.get 'watched'
    $(@el).html """
      <input type="checkbox" #{if watched then 'checked' else ''}
             title="Mark as #{if watched then 'unwatched' else 'watched'}"/>
      <h2 class="title" contenteditable>#{@model.get 'title'}</h2>
      <p class="comment" contenteditable>#{@model.get 'comment'}</p>
      <div class="delete" title="Delete">✖</div>
      """
    @

  toggleWatched:->
    @model.toggle()
    @model.save()

  updateContent:->
    @model.set
      title: @$('.title').text()
      comment: @$('.comment').text()
    @model.save()

  delete:->
    @model.destroy()

class VideoListView extends Backbone.View

  initialize:->
    @collection.each @addVideo

  addVideo: (video) =>
    videoView = new VideoView model: video
    videoView.render()
    $(@el).append videoView.el

class window.AppView extends Backbone.View

  initialize:->
    @render()
    @videoList = new VideoList(@options.videos || [])
    new VideoListView collection: @videoList, el: @$('.video-list')

  render:->
    $(@el).html """
      <div class="container">
        <h1>To-Watch</h1>
        <div class="video-list"></div>
      </div>"""