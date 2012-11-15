
window.onload= function(){
  $("#rfm_tabs").tabs();
  $( "#slider-range-freq" ).slider({
    range: true,
    min: 0,
    max: 10000,
    values: [ 1, 10000 ],
    slide: function( event, ui ) {
      if(ui.values[ 0 ] == ui.values[1]){return false;}
      else{
        $( "#freq_r" ).val( ui.values[ 0 ] + " - " + ui.values[ 1 ] );
      }
    },
    create: function( event, ui ) {
      $( "#freq_r" ).val(0 + " - " + 10000 );
    }
  });
  $( "#slider-range-price" ).slider({
    range: true,
    min: 0,
    max: 10000,
    values: [ 1, 10000 ],
    slide: function( event, ui ) {
      if(ui.values[ 0 ] == ui.values[1]){return false;}
      else{
        $( "#price_r" ).val( ui.values[ 0 ] + " - " + ui.values[ 1 ] );
      }
    },
    create: function( event, ui ) {
      $( "#price_r" ).val(0 + " - " + 10000 );
    }
  });

  //Bucket size selection Buttons
  $( "#time_bs" ).buttonset();
  $( "#freq_bs" ).buttonset();
  $( "#price_bs" ).buttonset();

  $('#weekly').click(function(){
    $('.buckets').hide();
    $('#weekly_buckets').show();

  });
  $('#monthly').click(function(){
    $('.buckets').hide();
    $('#monthly_buckets').show();
  });
  $('#quarterly').click(function(){
    $('.buckets').hide();
    $('#quarterly_buckets').show();
   });
  $('#half_yearly').click(function(){
    $('.buckets').hide();
    $('#half_yearly_buckets').show();
  });




  $("#monetary_submit").click(function(){
    render_chart('monetary_customer_distribution.json', 'container_monetary', 'Monetary Customer Distribution', 'Click the columns to view Product names. Click again to view range.')
  });
  $("#recency_submit").click(function(){
    render_chart('recency_customer_distribution.json', 'container_recency', 'Recency Customer Distribution', 'Click the columns to view Product names. Click again to view range.')
  });
  $("#frequency_submit").click(function(){
    render_chart('frequency_customer_distribution.json', 'container_frequency', 'Frequency Customer Distribution', 'Click the columns to view Product names. Click again to view range.')
  });

  $('.buckets').buttonset();
  render_chart('monetary_customer_distribution.json', 'container_monetary', 'Monetary Customer Distribution', 'Click the columns to view Product names. Click again to view range.')
  render_chart('recency_customer_distribution.json', 'container_recency', 'Recency Customer Distribution', 'Click the columns to view Product names. Click again to view range.')
  render_chart('frequency_customer_distribution.json', 'container_frequency', 'Frequency Customer Distribution', 'Click the columns to view Product names. Click again to view range.')
}



function render_chart(url, container, title, subtitle){
  var bucket_name = $("input[name=time_bs]:checked").val()
  var container_options  = {
    "container_monetary": {
      'price_range':$("#slider-range-price").slider("option","values"),
      'bucket_size':$("input[name=price_bs]:checked").val()
    },
    "container_frequency": {
      'order_range':$("#slider-range-freq").slider("option","values"),
      'bucket_size':$("input[name=freq_bs]:checked").val()
    },
    "container_recency": {
      'bucket_type':$("input[name=time_bs]:checked").val(),
      'number_of_buckets': $("input[name=" + bucket_name +  "_number_of_buckets]:checked").val()
    }
  };

  var chart;
  $.get(url,container_options[container], function(response) {
    var categories = response.categories,
    name = response.name,
    data = response.data;

    function setChart(name, categories, data, color, title, subtitle) {
      chart.xAxis[0].setCategories(categories, false);
      chart.series[0].remove(false);
      chart.addSeries({
        name: name,
        data: data,
        color: color || 'white'
      }, false);
      chart.setTitle({text: title}, {text: subtitle})
      chart.redraw();
    }

    chart = new Highcharts.Chart({
      chart: {
        renderTo: container,
        type: 'column'
      },
      title: {
        text: title
      },
      subtitle: {
        text: subtitle
      },
      xAxis: {
        categories: categories
      },
      yAxis: {
        title: {
          text: 'Total percent of customers'
        }
      },
      plotOptions: {
        column: {
          cursor: 'pointer',
          point: {
            events: {
              click: function() {
                var drilldown = this.drilldown;
                if (drilldown) { // drill down
                  setChart(drilldown.name, drilldown.categories, drilldown.data, drilldown.color, 'Product Distribution', '');
                } else { // restore
                  setChart(name, categories, data, null, title, subtitle);
                }
              }
            }
          },
          dataLabels: {
            enabled: true,
            color: response.color,
            style: {
              fontWeight: 'bold'
            },
            formatter: function() {
              return this.y +'%';
            }
          }
        }
      },
      series: [{
        name: name,
        data: data,
        color: 'white'
      }],
      exporting: {
        enabled: false
      }
    });
  });

}

