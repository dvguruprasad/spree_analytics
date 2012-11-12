
render_chart('monetary_customer_distribution.json', 'container_monetary', 'Monetary Customer Distribution', 'Click the columns to view Product names. Click again to view range.')
render_chart('recency_customer_distribution.json', 'container_recency', 'Recency Customer Distribution', 'Click the columns to view Product names. Click again to view range.')
render_chart('frequency_customer_distribution.json', 'container_frequency', 'Frequency Customer Distribution', 'Click the columns to view Product names. Click again to view range.')
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
        }
    });
    $(".freq_bs a").click(function(){
        $(".freq_bs a").removeClass("bucket_selected");
        $(this).addClass("bucket_selected");
    })
    $(".price_bs a").click(function(){
        $(".price_bs a").removeClass("bucket_selected");
        $(this).addClass("bucket_selected");
    })
    $( "#rfm_from" ).datepicker({
        defaultDate: "+1w",
        changeMonth: true,
        onClose: function( selectedDate ) {
            $( "#to" ).datepicker( "option", "minDate", selectedDate );
        }
    });
    $( "#rfm_to" ).datepicker({
        defaultDate: "+1w",
        changeMonth: true,
        onClose: function( selectedDate ) {
            $( "#from" ).datepicker( "option", "maxDate", selectedDate );
        }
    });

}
//$(document).ready(function(){alert('inside');})
function render_chart(url, container, title, subtitle){
    var chart;
    $.get(url, function(response) {
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

