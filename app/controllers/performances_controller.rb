# -*- encoding:utf-8 *-*
require 'date'
class PerformancesController < ApplicationController
  def index

    #################
    # パラメータチェック
    #################
    if (params[:yyyymm] == nil) or (params[:item] == nil) or (params[:dept] == nil)
      # パラメータが指定されていない
      render 'index_def'
      return
    end

    #################
    # 年度指定
    #################
    yyyy = params[:yyyymm].to_i
    yyyymm_s = yyyy.to_s + "04"
    yyyymm_e = (yyyy+1).to_s + "03"

    #################
    # 項目指定
    #################
    item = Item.find_by_code(params[:item])

    #################
    # 部署判定
    #################
    busyo = params[:dept].to_i

    dept_arr = []
    dept_group = DeptGroup.find_by_busyo_id(busyo)
    if dept_group
      # グループ部署の時
      dept_name = dept_group.name
      dept_group.dept_group_details.each do |detail|
        dept_arr.push(detail.dept_id)
      end
    else
      # 通常部署の時
      dept = Dept.find_by_busyo_id(busyo)  # ビル管理事業部
      dept_name = dept.name
      dept_arr.push(dept)
    end


    #################
    # スコープ定義
    #################
    monthly = MonthlyStatement.scoped
    monthly = monthly.where(["dept_id In (?)", dept_arr])
    monthly = monthly.where("item_id = " + item.id.to_s)

    # 今年度の計画実績
    this_year_monthly = monthly.where("yyyymm>=" + yyyymm_s)
    this_year_monthly = this_year_monthly.where("yyyymm<=" + yyyymm_e)
    this_year_monthly = this_year_monthly.group("yyyymm").select("SUM(plan_value) as plan_value, SUM(result_value) as result_value, yyyymm")

    ##################################
    # 今年度の計画／実績と、昨年の実績を取得
    ##################################
    categories = []
    this_year_plans = []
    this_year_results = []
    prev_year_results = []

    this_year_monthly.each do |rec|

      # 今年度の計画／実績
      #categories.push(rec.yyyymm.slice(4..5).to_i.to_s + "月")
      categories.push(rec.yyyymm)
      this_year_plans.push(rec.plan_value.to_f)
      this_year_results.push(rec.result_value.to_f)

      # 前年実績
      prev_year = rec.yyyymm.slice(0..3).to_i - 1
      prev_year_monthly = monthly.where("yyyymm = " + prev_year.to_s + rec.yyyymm.slice(4..5))
      prev_year_monthly = prev_year_monthly.group("yyyymm").select("SUM(plan_value) as plan_value, SUM(result_value) as result_value, yyyymm")

      reg_flg = false
      prev_year_monthly.each do |rec2|
        prev_year_results.push(rec2.result_value.to_f)
        reg_flg = true
      end

      unless reg_flg
        prev_year_results.push(0)
      end

    end

    ##################################
    # 計画／実績の棒グラフを作成(前年対比も含める)
    ##################################
    @plan_result = LazyHighCharts::HighChart.new('graph') do |f|
#      f.chart(:type => "spline")
#      f.chart(:type => "column")
      f.title(text: dept_name + 'の' + item.name + '(' + yyyy.to_s + '年度)')
      f.xAxis(categories: categories.collect do |ym| ym.slice(4..5).to_i.to_s + "月" end, tickInterval: 1) # 1とかは列の間隔の指定
      f.series(name: (yyyy -1).to_s + '年度実績', data: prev_year_results, type: "column", color: '#8cc63f')
      f.series(name: '計画', data: this_year_plans, type: "column", color: '#3276b1')
      f.series(name: '実績', data: this_year_results, type: "column", color: '#d9534f')
    end

    ##################################
    # 実績の前年対比
    ##################################
#    @year_on_year = LazyHighCharts::HighChart.new('graph') do |f|
#      f.title(text: dept_name + 'の' + item.name + '(昨年対比)')
#      f.xAxis(categories: categories.collect do |ym| ym.slice(4..5).to_i.to_s + "月" end, tickInterval: 1) # 1とかは列の間隔の指定
#      f.series(name: (yyyy -1).to_s + '年度実績', data: prev_year_results, type: "column", color: '#8cc63f')
#      f.series(name: yyyy.to_s + '年度実績', data: this_year_results, type: "column", color: '#d9534f')
#    end


    ##################################
    # 年計グラフを作成
    ##################################
    # 指定した月で最小の月-12ヶ月を取得する。
    min_month = ""
    year_sum = monthly.select("MIN(yyyymm) as yyyymm")
    year_sum.each do |rec|
      min_month = rec.yyyymm
    end

    dt = Date.parse(min_month + '01').strftime("%y/%m/%d")

    ##############################################
    # グループ部署の時、子部署の実績を線グラフで表示する。
    ##############################################
    if dept_group
      @group_result = LazyHighCharts::HighChart.new('graph') do |f|
        f.title(text: dept_name + 'の' + item.name + 'の実績一覧')
        f.xAxis(categories: categories.collect do |ym| ym.slice(4..5).to_i.to_s + "月" end, tickInterval: 1) # 1とかは列の間隔の指定
        #f.series(name: '実績', data: this_year_results, type: "spline")

        f.legend(
            layout: 'vertical',
            backgroundColor: '#FFFFFF',
            floating: true,
            align: 'left',
            x: 100,
            verticalAlign: 'top',
            y: 20
        )

        dept_arr.each do |dept_id|
          group_result = []
          dept = Dept.find(dept_id)
          p dept.name

          categories.each do |yymm|
            monthly_result = MonthlyStatement.scoped
            monthly_result = monthly_result.where("item_id = " + item.id.to_s)
            monthly_result = monthly_result.where("yyyymm=" + yymm)
            monthly_result = monthly_result.where("dept_id = " +  dept.id.to_s)
            #monthly_result = monthly_result.group("yyyymm").select("SUM(plan) as plan, SUM(result) as result, yyyymm")

            monthly_result.each do |rec|
              group_result.push(rec.result_value.to_f)
            end
          end

#          f.series(name: dept.to_s , data: group_result.dup, type: "spline")
          f.series(name: dept.name , data: group_result.dup, type: "line")
        end
      end
    end # if



  end

end
