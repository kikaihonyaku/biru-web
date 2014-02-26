# -*- encoding:utf-8 *-*
require 'date'
class PerformancesController < ApplicationController

  before_filter :init
  
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

    # 戻り値のHashを格納する為の配列
    @result_arr = []
    @graph_name = params[:graph_name]

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
    @item = Item.find_by_code(params[:item].slice(2, params[:item].length - 2))

    # params[:item_summary]    ←集計種別  1:合計 2:平均 3:最大
    item_summary = params[:item_summary]
    @item_calc = params[:item_calc]


    #################
    # 部署判定
    #################
    @plan_exists = false
    @prev_result_exists = false
    params[:dept_list].split(",").each do |busyo|

      # ここで指定した条件で以下のkeyを持つ配列が返ってくるので、それを配列に格納
      # Hashのkey
      #
      # result['dept_name']　・・・　部署名
      # result['categories'] ・・・・　年月のカテゴリ配列
      #
      # result['this_year_plans'] 　・・・・　計画値の配列
      # result['this_year_results'] ・・・・　実績値の配列
      # result['prev_year_results'] ・・・・　前年実績値の配列
      #
      # result['cumulative_this_year_plans']　・・・計画値の累積
      # result['cumulative_this_year_results']　・・・実績値の累積
      # result['cumulative_prev_year_results']　・・・前年実績値の累積
      #
      # result['graph_plan'] ・・・・　計画／実績／前年実績の棒グラフ
      # result['graph_years'] ・・・・ 年計グラフ
      #
      # result['plan_exists']・・・・・・ 計画存在チェック
      # result['prev_result_exists']・ ・前年存在チェック
      result = get_monthly_graph(busyo.to_i, yyyymm_s, yyyymm_e, @item, item_summary, yyyy.to_s + '年度')
      @result_arr.push(result)

      # 1件でも計画がある場合、計画有りと判定する
      @plan_exists = true if result['plan_exists']
      @prev_result_exists = true if result['prev_result_exists']

    end


    ##############################################
    # 指定された部署を折れ線グラフで表示する。
    ##############################################
   @group_result = LazyHighCharts::HighChart.new('graph') do |f|
     f.title(text: @graph_name.to_s + 'の' + @item.name + 'の実績一覧')
     f.xAxis(categories: @result_arr[0]['categories'].collect do |ym| ym.slice(4..5).to_i.to_s + "月" end, tickInterval: 1) # 1とかは列の間隔の指定
     #f.series(name: '実績', data: this_year_results, type: "spline")

     # 凡例
     f.legend(
         layout: 'vertical',
         backgroundColor: '#FFFFFF',
         floating: true,
         align: 'right',
         x: -20,
         verticalAlign: 'top',
         y: 40
     )

     @result_arr.each_with_index do |result, i|
       f.series(name: result['dept_name'] , data: result['this_year_results'].dup, type: "line")
     end
   end
    
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

    #######################################################
    # 営業所別の築年数を出す(棟数別)(物件種別ごとの積み上げグラフ)
    #######################################################
    # 築年数の最小と最大を取得(棟数別)
    min_age = nil
    max_age = nil
    base.select('MIN(biru_age) as min_age, MAX(biru_age) as max_age').where('biru_age < 100').each do |rec|
      min_age = rec.min_age
      max_age = rec.max_age
    end

    @category_arr = []
    @biru_age_apmn = [] # アパート・マンション
    @biru_age_bmmn = [] # 分譲マンション
    @biru_age_kodt = [] # 戸建て
    @biru_age_etc = []  # その他

    while min_age <= max_age

      @category_arr.push(min_age)

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

      @biru_age_apmn.push(apmn_cnt)
      @biru_age_bmmn.push(bnmn_cnt)
      @biru_age_kodt.push(kodt_cnt)
      @biru_age_etc.push(etc_cnt)

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
      f.xAxis(categories: @category_arr, tickInterval: 2) # 1とかは列の間隔の指定
      f.series(name: 'その他', data: @biru_age_etc, type: "column")
      f.series(name: '戸建て', data: @biru_age_kodt, type: "column")
      f.series(name: '分譲Ｍ', data: @biru_age_bmmn, type: "column")
      f.series(name: 'アパマン', data: @biru_age_apmn, type: "column")
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

    #################################################
    # 営業所別・築年数を出す(戸数別)(間取りの積み上げグラフ)
    #################################################
    
    # 戸数別


    # 戸数・間取り別

    # 戸数・部屋種別別
    #
    ###############################
    # 営業所別・間取り別の築年数を出す(戸数別)
    ###############################


   # @arr = manage_types
    @active_biru_age = ""

  end

  # 空日数
  def vacant_day

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

    @vacant_yyyymm_current = params[:yyyymm_current].to_s
    @vacant_yyyymm_before = params[:yyyymm_before].to_s

    # カテゴリ定義
    @category_arr = ["〜30", "〜60", "〜90", "〜120", "〜150", "〜180", "〜210", "〜240", "〜270", "〜300", "〜330", "〜360", "〜390", "〜420", "〜450", "〜480", "〜510", "511〜" ]

    # 対象の建物を取得する。Baseの項目を取得する。
    base = VacantRoom.joins(:building).joins(:room).joins(:shop).joins(:room_layout).joins(:manage_type).scoped
    base = base.where("vacant_rooms.shop_id In (?)", shops)
    base = base.where("vacant_rooms.manage_type_id In (?)", manage_types)

    # 当月の情報を取得する
    current_vacant = base.where("yyyymm = ?", params[:yyyymm_current].gsub('/',''))
    @vacant_detail_current = current_vacant.select("vacant_cnt, manage_types.name as manage_type_nm, shops.name as shop_nm, buildings.code as building_cd, buildings.name as building_nm, rooms.name as room_nm, room_layouts.name as room_layout_nm").order("vacant_cnt, shops.code, room_layouts.code, buildings.code, rooms.code")
    @vacant_current_map = vacant_count(@category_arr, @vacant_detail_current)

    # 前月の情報を取得する
    before_vacant = base.where("yyyymm = ?", params[:yyyymm_before].gsub('/',''))
    @vacant_detail_before = before_vacant.select("vacant_cnt, manage_types.name as manage_type_nm, shops.name as shop_nm, buildings.code as building_cd, buildings.name as building_nm, rooms.name as room_nm, room_layouts.name as room_layout_nm").order("vacant_cnt, shops.code, room_layouts.code, buildings.code, rooms.code")
    @vacant_before_map = vacant_count(@category_arr, @vacant_detail_before)

    @vacant_sum = LazyHighCharts::HighChart.new('graph') do |f|

      f.chart(
        renderTo: 'container',
        type: 'column'
      )

      # 凡例
      f.legend(
          layout: 'vertical',
          reversed: false,
          backgroundColor: '#FFFFFF',
          floating: true,
          align: 'right',
          x: -20,
          verticalAlign: 'top',
          y: 100
      )

      f.title(text: params[:shop_nm] + 'の空日数')
      f.xAxis(categories: @category_arr, tickInterval: 1) # 1とかは列の間隔の指定
      f.series(name: params[:yyyymm_before], data: @vacant_before_map.to_a, type: "column")
      f.series(name: params[:yyyymm_current], data: @vacant_current_map.to_a, type: "column")

    end

  end


private

  def init
    @vacant_yyyymm_before = Date.today.prev_month.strftime("%Y/%m")
    @vacant_yyyymm_current = Date.today.strftime("%Y/%m")
  end

  # vacant_dataより空日数のカウントをし、その結果をvacant_resultに返します
  def vacant_count(category_arr, vacant_data )

    vacant_result = {}

    # カウントの初期化
    category_arr.each do |day|
      vacant_result[day] = 0
    end

    s_key = ""
    vacant_data.each do |rec|

      case rec.vacant_cnt
      when 0..30
          s_key = category_arr[0]
      when 0..60
          s_key = category_arr[1]
      when 0..90
          s_key = category_arr[2]
      when 0..120
          s_key = category_arr[3]
      when 0..150
          s_key = category_arr[4]
      when 0..180
          s_key = category_arr[5]
      when 0..210
          s_key = category_arr[6]
      when 0..240
          s_key = category_arr[7]
      when 0..270
          s_key = category_arr[8]
      when 0..300
          s_key = category_arr[9]
      when 0..330
          s_key = category_arr[10]
      when 0..360
          s_key = category_arr[11]
      when 0..390
          s_key = category_arr[12]
      when 0..420
          s_key = category_arr[13]
      when 0..450
          s_key = category_arr[14]
      when 0..480
          s_key = category_arr[15]
      when 0..510
          s_key = category_arr[16]
      else
          s_key = category_arr[17]
      end
      vacant_result[s_key] = vacant_result[s_key] + 1

    end

    return vacant_result

  end

  # 指定された部署／項目／年月のグラフを取得する
  def get_monthly_graph(dept_id, yyyymm_from, yyyymm_to, item, item_summary, graph_title)

    ##################
    # 部署の展開
    ##################
    dept_arr = []
    dept_group = DeptGroup.find_by_busyo_id(dept_id)
    if dept_group
      # グループ部署の時
      dept_name = dept_group.name
      dept_group.dept_group_details.each do |detail|
        dept_arr.push(detail.dept_id)
      end
    else
      # 通常部署の時
      dept = Dept.find_by_busyo_id(dept_id)
      dept_name = dept.name
      dept_arr.push(dept)
    end

    #################
    # スコープ定義
    #################
    monthly = MonthlyStatement.scoped
    monthly = monthly.where(["dept_id In (?)", dept_arr])
    monthly = monthly.where("item_id = " + item.id.to_s)

    case item_summary.to_i
    when 1
      func_summary = "SUM"
    when 2
      func_summary = "AVG"
    when 3
      func_summary = "SUM" # だたしこの時は年計は出さない
    end

    # 今年度の計画実績
    this_year_monthly = monthly.where("yyyymm>=" + yyyymm_from)
    this_year_monthly = this_year_monthly.where("yyyymm<=" + yyyymm_to)
    this_year_monthly = this_year_monthly.group("yyyymm").select(func_summary + "(plan_value) as plan_value," + func_summary +" (result_value) as result_value, yyyymm")

    ##################################
    # 今年度の計画／実績と、昨年の実績を取得
    ##################################
    result = {}
    result['dept_name'] = dept_name
    result['plan_exists'] = false
    result['prev_result_exists'] = false

    result['categories'] = []

    # 通常棒グラフ
    result['this_year_plans'] = []
    result['this_year_results'] = []
    result['prev_year_results'] = []

    # 積み上げ棒グラフ
    result['cumulative_this_year_plans'] = []
    result['cumulative_this_year_results'] = []
    result['cumulative_prev_year_results'] = []

    # 計画比／前年比
    result['comparison_plan'] = []
    result['comparison_result'] = []


    cummulative_this_plans = 0
    cumulative_this_year = 0
    cumulative_prev_year = 0

    this_year_monthly.each do |rec|

      # 今年度の計画／実績
      result['categories'].push(rec.yyyymm)
      result['this_year_plans'].push(rec.plan_value.to_f)
      result['this_year_results'].push(rec.result_value.to_f)
      result['comparison_plan'].push(BigDecimal("#{(rec.result_value.to_f) / (rec.plan_value.to_f) *100}").floor(1))



      # 積み上げ棒グラフ用
      cummulative_this_plans = cummulative_this_plans + rec.plan_value.to_f
      cumulative_this_year = cumulative_this_year + rec.result_value.to_f

      result['cumulative_this_year_plans'].push(cummulative_this_plans)
      result['cumulative_this_year_results'].push(cumulative_this_year)


      # 計画が一つでも登録されていれば、計画棒グラフを出す。
      result['plan_exists'] = true if rec.plan_value.to_f > 0

      # 前年実績
      prev_year = rec.yyyymm.slice(0..3).to_i - 1
      prev_year_monthly = monthly.where("yyyymm = " + prev_year.to_s + rec.yyyymm.slice(4..5))
      prev_year_monthly = prev_year_monthly.group("yyyymm").select(func_summary + "(plan_value) as plan_value, " + func_summary + "(result_value) as result_value, yyyymm")

      reg_flg = false
      prev_year_monthly.each do |rec2|
        result['prev_year_results'].push(rec2.result_value.to_f)
        result['comparison_result'].push(BigDecimal("#{((rec.result_value.to_f))/(rec2.result_value.to_f)*100}").floor(1))

        cumulative_prev_year = cumulative_prev_year + rec2.result_value.to_f
        result['cumulative_prev_year_results'].push(cumulative_prev_year)


        result['prev_result_exists'] = true # 1件でも前年が存在すれば、前年有りと判定
        
        reg_flg = true
      end

      unless reg_flg
        result['prev_year_results'].push(0)
        result['cumulative_prev_year_results'].push(cumulative_prev_year)
      end

    end

    #######################################
    # 計画／実績／前年の棒グラフを作成
    #######################################
    result['graph_plan'] = LazyHighCharts::HighChart.new('graph') do |f|
      f.title(text: dept_name + 'の' + item.name + '(' + graph_title + ')')
      f.xAxis(categories: result['categories'].collect do |ym| ym.slice(4..5).to_i.to_s + "月" end, tickInterval: 1) # 1とかは列の間隔の指定

      # 凡例
      f.legend(
          layout: 'vertical',
          reversed: true,
          backgroundColor: '#FFFFFF',
          floating: true,
          align: 'right',
          x: -20,
          verticalAlign: 'top',
          y: 250
      )

      f.series(name: '前年実績', data: result['cumulative_prev_year_results'], type: "line", color: '#8cc63f')

      if result['plan_exists']
        f.series(name: '計画', data: result['cumulative_this_year_plans'], type: "line", color: '#3276b1')
      end

      f.series(name: '実績', data: result['cumulative_this_year_results'], type: "line", color: '#d9534f')
    end

    #######################################
    # 計画／実績／前年の積算の折れ線グラフを作成
    #######################################
    result['graph_cumulative'] = LazyHighCharts::HighChart.new('graph') do |f|
      f.title(text: dept_name + 'の' + item.name + '(' + graph_title + ')')
      f.xAxis(categories: result['categories'].collect do |ym| ym.slice(4..5).to_i.to_s + "月" end, tickInterval: 1) # 1とかは列の間隔の指定

      # 凡例
      f.legend(
          layout: 'vertical',
          reversed: true,
          backgroundColor: '#FFFFFF',
          floating: true,
          align: 'right',
          x: -20,
          verticalAlign: 'top',
          y: 250
      )

      f.series(name: '前年実績', data: result['prev_year_results'], type: "column", color: '#8cc63f')

      if result['plan_exists']
        f.series(name: '計画', data: result['this_year_plans'], type: "column", color: '#3276b1')
      end

      f.series(name: '実績', data: result['this_year_results'], type: "column", color: '#d9534f')
    end


    ############################################################################
    # 集計種別が「最大」でない時、年計グラフを作成（管理戸数の累計などだしても意味が無いから）
    ############################################################################
    # 指定した月で最小の月+12ヶ月を取得する。
    if item_summary.to_i != 3
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
              year_result.push(rec.result_value.to_f)
            end

            # 1ヶ月進める
            dt_start = dt_start >> 1
            dt_end = dt_end >> 1

          end

          interval = ((year_category.length)/12).to_i + 1

          result['graph_years'] = LazyHighCharts::HighChart.new('graph') do |f|
            f.title(text: dept_name + 'の' + item.name + 'の年計')
            f.xAxis(categories: year_category, tickInterval: interval) # 1とかは列の間隔の指定
            f.series(name: '実績', data: year_result, type: "column")
          end

        end

      end
    end

    return result

  end

end

