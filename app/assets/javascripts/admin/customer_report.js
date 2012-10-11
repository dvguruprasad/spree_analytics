
render_chart('monetary_customer_distribution.json', 'container_monetary', 'Monetary Customer Distribution', 'Click the columns to view Product names. Click again to view range.')
render_chart('recency_customer_distribution.json', 'container_recency', 'Recency Customer Distribution', 'Click the columns to view Product names. Click again to view range.')
render_chart('frequency_customer_distribution.json', 'container_frequency', 'Frequency Customer Distribution', 'Click the columns to view Product names. Click again to view range.')

function render_chart(url, container, title, subtitle){
    var chart;
    $.get(url, function(response) {
        var categories = response.categories,
        name = response.name,
        data = response.data;

    function setChart(name, categories, data, color) {
        chart.xAxis[0].setCategories(categories, false);
        chart.series[0].remove(false);
        chart.addSeries({
            name: name,
            data: data,
            color: color || 'white'
        }, false);
        chart.setTitle({text: 'Product Distribution'}, {text: ''})
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
                                  setChart(drilldown.name, drilldown.categories, drilldown.data, drilldown.color);
                              } else { // restore
                                  setChart(name, categories, data);
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

