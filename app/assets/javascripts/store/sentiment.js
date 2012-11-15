// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
function load_sentiment_pie (sentiment) {
    $('#accordion').removeClass('hide');
    if(typeof Highcharts != "undefined") {
        RenderPieChart('container',  sentiment[0] );
    }
    $( "#accordion" ).accordion({
        header: "h3"
    });
}

function RenderPieChart(elementId, dataList){
    Highcharts.getOptions().colors = $.map(Highcharts.getOptions().colors, function(color) {
        return {
            radialGradient: { cx: 0.5, cy: 0.3, r: 0.7 },
    stops: [
        [0, color],
    [1, Highcharts.Color(color).brighten(-0.25).get('rgb')] // darken
        ]
        };
    });
    chart = new Highcharts.Chart({
        chart: {
            renderTo: 'brand_sentiment',
          plotBackgroundColor: null,
          plotBorderWidth: null,
          plotShadow: false
        },
          title: {
              text: 'Brand Sentiment'
          },
          tooltip: {
              pointFormat: ' <b>{point.percentage}%</b>',
          percentageDecimals: 1
          },
          plotOptions: {
              pie: {
                  allowPointSelect: true,
          cursor: 'pointer',
          size:100,
          dataLabels: {
              enabled: false
          },
          point: {
              events: {
                  legendItemClick: function () {
                      return false; // <== returning false will cancel the default action
                  }
              }
          },
          showInLegend: true
              }
          },
          credits: {
              enabled: false
          },
          exporting:{
              enabled: false
          },
          series: [{
              type: 'pie',
              data: dataList
          }]
    });
}

function RenderTagCloud(sentiment_tags){
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
