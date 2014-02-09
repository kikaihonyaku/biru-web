# -*- encoding:utf-8 *-*
require 'date'
class PerformancesController < ApplicationController
  def index

    #################
    # パラメータチェック
    #################
#    if (params[:yyyymm] == nil) or (params[:item] == nil) or (params[:dept] == nil)
#      # パラメータが指定されていない
#      render 'index_def'
#      return
#    end

  end

  # 月次情報
  def monthly
    #################
    # 年度指定
    #################
    yyyy = params[:yyyymm].to_i
    yyyymm_s = yyyy.to_s + "04"
    yyyymm_e = (yyyy+1).to_s + "03"

    #################
    # 項目指定
    #################
    #  項目CDの先頭には２文字、ID重複しないためのキーが入っているので、それを除いて使用
    item = Item.find_by_code(params[:item].slice(2, params[:item].length - 2))

    # 集計種別を取得 1:合計 2:平均 3:最大
    p "集計種別：" + params[:item_summary]
    case params[:item_summary].to_i
    when 1
      func_summary = "SUM"
    when 2
      func_summary = "AVG"
    when 3
      func_summary = "SUM" # だたしこの時は年計は出さない
    end

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
    this_year_monthly = this_year_monthly.group("yyyymm").select(func_summary + "(plan_value) as plan_value," + func_summary +" (result_value) as result_value, yyyymm")

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
      prev_year_monthly = prev_year_monthly.group("yyyymm").select(func_summary + "(plan_value) as plan_value, " + func_summary + "(result_value) as result_value, yyyymm")

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

    ############################################################################
    # 集計種別が「最大」でない時、年計グラフを作成（管理戸数の累計などだしても意味が無いから）
    ############################################################################
    # 指定した月で最小の月+12ヶ月を取得する。
    if params[:item_summary].to_i != 3
      min_month = nil
      max_month = nil
      year_sum = monthly.select("MIN(yyyymm) as yyyymm_min, MAX(yyyymm) as yyyymm_max").where("result_value > 0")
      year_sum.each do |rec|
        min_month = rec.yyyymm_min
        max_month = rec.yyyymm_max
      end

      if min_month
        dt_start = Date.parse(min_month + '01') # 最小月
        dt_end = dt_start >> 11 # ＋11ヶ月後
        dt_max = Date.parse(max_month + '01') # 最大月

        # データが12ヶ月以上ある場合、年計グラフを作成する
        if dt_end <= dt_max

          year_category = []
          year_result = []

          while dt_end <= dt_max

            #p dt_end.strftime("%Y%m")

            year_category.push(dt_end.strftime("%Y%m"))

            year_sum_v2 = monthly.where("yyyymm between ? and ?", dt_start.strftime("%Y%m"), dt_end.strftime("%Y%m") ).select(func_summary + "(result_value) as result_value")
            year_sum_v2.each do |rec|
              p rec.result_value
              year_result.push(rec.result_value.to_f)
            end

            # 1ヶ月進める
            dt_start = dt_start >> 1
            dt_end = dt_end >> 1


          end

          interval = ((year_category.length)/12).to_i + 1

          @year_result = LazyHighCharts::HighChart.new('graph') do |f|
            f.title(text: dept_name + 'の' + item.name + 'の年計')
            f.xAxis(categories: year_category, tickInterval: interval) # 1とかは列の間隔の指定
            f.series(name: '実績', data: year_result, type: "column")
          end

        end

      end

    end

    ##############################################
    # グループ部署の時、子部署の実績を線グラフで表示する。
    ##############################################
    if dept_group
      @group_result = LazyHighCharts::HighChart.new('graph') do |f|
        f.title(text: dept_name + 'の' + item.name + 'の実績一覧')
        f.xAxis(categories: categories.collect do |ym| ym.slice(4..5).to_i.to_s + "月" end, tickInterval: 1) # 1とかは列の間隔の指定
        #f.series(name: '実績', data: this_year_results, type: "spline")

        # 凡例
        f.legend(
            layout: 'vertical',
            backgroundColor: '#FFFFFF',
            floating: true,
            align: 'right',
            x: 0,
            verticalAlign: 'top',
            y: 0
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


  # 築年数
  def build_age

    # 対象の営業所IDを取得する
    shops = []
    Shop.find_all_by_code(params[:shop].split(',')).each do |shop|
      shops.push(shop.id)
    end

    # 対象の管理方式（B管理・D管理・業務君）を取得する
    manage_types = []
    ManageType.find_all_by_code([3,6,10]).each do |manage_type|
      manage_types.push(manage_type.id)
    end

    # 対象の建物を取得する。Baseの項目を取得する。
    base = Building.joins(:trusts => :manage_type).joins(:shop).joins(:build_type).scoped
    base = base.where("buildings.shop_id In (?)", shops)
    base = base.where("trusts.manage_type_id In (?)", manage_types)

    ###############################
    # 営業所別の築年数を出す(棟数別)
    ###############################
    # 築年数の最小と最大を取得(棟数別)
    min_age = nil
    max_age = nil
    base.select('MIN(biru_age) as min_age, MAX(biru_age) as max_age').where('biru_age < 100').each do |rec|
      min_age = rec.min_age
      max_age = rec.max_age
    end

    category_arr = []
    biru_age_apmn = [] # アパート・マンション
    biru_age_bmmn = [] # 分譲マンション
    biru_age_kodt = [] # 戸建て
    biru_age_etc = []  # その他

    while min_age <= max_age

      category_arr.push(min_age)

      apmn_cnt = 0
      bnmn_cnt = 0
      kodt_cnt = 0
      etc_cnt = 0

      base.select('count(buildings.code) as cnt, build_types.code as biru_type_cd').where('biru_age = ?', min_age ).group('build_types.code').each do |rec|

        case rec.biru_type_cd
        when '01010', '01020'
          # アパート・マンション
          apmn_cnt = apmn_cnt + rec.cnt
        when '01015'
          # 分譲マンション
          bnmn_cnt = bnmn_cnt + rec.cnt

        when '01025'
          # 戸建て
          kodt_cnt = kodt_cnt + rec.cnt

        else
          # それ以外のもの
          etc_cnt = etc_cnt + rec.cnt
        end
      end

      biru_age_apmn.push(apmn_cnt)
      biru_age_bmmn.push(bnmn_cnt)
      biru_age_kodt.push(kodt_cnt)
      biru_age_etc.push(etc_cnt)

      min_age = min_age + 1
    end

    # 棟数別
    @build_sum = LazyHighCharts::HighChart.new('graph') do |f|

      f.chart(
        renderTo: 'container',
        type: 'column'
      )

      # 凡例
      f.legend(
          layout: 'vertical',
          reversed: true,
          backgroundColor: '#FFFFFF',
          floating: true,
          align: 'right',
          x: -20,
          verticalAlign: 'top',
          y: 100
      )

      f.title(text: params[:shop_nm] + 'の築年数(棟数別)')
      f.xAxis(categories: category_arr, tickInterval: 2) # 1とかは列の間隔の指定
      f.series(name: 'その他', data: biru_age_etc, type: "column")
      f.series(name: '戸建て', data: biru_age_kodt, type: "column")
      f.series(name: '分譲Ｍ', data: biru_age_bmmn, type: "column")
      f.series(name: 'アパマン', data: biru_age_apmn, type: "column")
      f.plotOptions(
        column: {stacking: 'normal',
            dataLabels: {
              enabled: false,
              color: 'red'|| 'white' || 'blue'
            }
        }
      )
    end

    # 内訳一覧を表示する。
    @biru_detail = base.select('buildings.code, buildings.name, shops.name as shop_nm, build_types.name as build_type_nm, biru_age, manage_types.name as manage_type_name').where('biru_age < 100').order('biru_age').order('build_types.id')

    #####################################
    # 営業所別・物件種別ごとを出す(物件種別別)
    #####################################
    biru_type_ap = []  # アパート
    biru_type_ko = []  # 戸建て
    biru_type_bun = [] # 分譲M
    biru_type_etc = [] # その他
    
#    def_bm = Build_type.find_by_code().id  # 分譲M
    @biru_detail.each do |rec|

    end


    ###############################
    # 営業所別・築年数を出す(戸数別)
    ###############################
    
    # 戸数別



    # 戸数・間取り別

    # 戸数・部屋種別別
    #
    ###############################
    # 営業所別・間取り別の築年数を出す(戸数別)
    ###############################


   # @arr = manage_types
  end

  @active_biru_age = ""

end
