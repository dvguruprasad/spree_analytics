// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.


    function RenderTagCloud(sentiment_tags){
        //$.ajax({
            //url: '/ws/score/puma',
            //type:'GET',
            //dataType: 'json',
            //async: false,
            //success: function(data){  //alert(data.tags);
                $("<ul class='cf'>").attr("id", "tagList").appendTo("#tagcloud");
                $.each(sentiment_tags, function(i, val) {     //alert(val.name);
                    var li = $("<li>");
                    //create link
                    $("<a>").text(val.name).attr({title:"See all tweets tagged with " + val.name, href:"#" + val.name + ".html"}).appendTo(li);
                    li.children().addClass((val.count < 0.4) ? "tag3": (val.count  < 0.7) ? "tag2" : "tag1");
                    //add to list
                    li.appendTo("#tagList");
                });
            }
        //});


