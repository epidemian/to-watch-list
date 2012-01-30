(function() {
    window.Video = Backbone.Model.extend({
    });

    window.VideoList = Backbone.Collection.extend({
        url: '/videos'
    });

    window.VideoView = Backbone.View.extend({
        template:_.template('<div><h3><%= title %></h3><%= youtube_id %></div>'),
        initialize:function() {
            this.model.bind('change', this.render, this);
        },
        render:function() {
            $(this.el).html(this.template(this.model.attributes));
        }
    });

    window.AppView = Backbone.View.extend({

        initialize:function() {
            var videos = this.options.videos;
            if (!videos) throw 'Must receive videos';

            videos.forEach(this.addVideo, this);
        },

        addVideo:function(video) {
            var view = new VideoView({model:video});
            view.render();
            $(this.el).append(view.el);
        }
    });

})();