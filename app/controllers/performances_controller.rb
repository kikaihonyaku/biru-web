# -*- encoding:utf-8 *-*
class PerformancesController < ApplicationController
  def index

    xAxis_categories = ['2013-11-09', '2013-11-10', '2013-11-11', '2013-11-12']
    tickInterval     = 2
    data             = [120, 80, 90, 150]
    @graph_data = LazyHighCharts::HighChart.new('graph') do |f|
      f.title(text: 'グラフのタイトル')
      f.xAxis(categories: xAxis_categories, tickInterval: tickInterval)
      f.series(name: 'データの名前', data: data, type: 'spline')
    end

  end
end
