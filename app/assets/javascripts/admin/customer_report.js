var chart;

$.get('order_value.json', function(response) {
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
    chart.redraw();
}

chart = new Highcharts.Chart({
    chart: {
        renderTo: 'container',
      type: 'column'
    },
      title: {
          text: 'Range vise product distribution'
      },
      subtitle: {
          text: 'Click the columns to view Product names. Click again to view range.'
      },
      xAxis: {
          categories: categories
      },
      yAxis: {
          title: {
              text: 'Total percent of products sold'
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
                              alert('setting chart!')
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

