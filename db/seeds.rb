# -*- coding:utf-8 -*-

require 'csv'
require 'kconv'
require 'date'
#require "moji"
require 'digest/md5'

require 'open-uri' # open関数でurlを読み込む為に必要
require 'rexml/document'


# 文字列を日付に変換
def custom_parse(str)
  date = nil
  if str && !str.empty? #railsなら、if str.present? を使う
    begin
      date = DateTime.parse(str)
    # parseで処理しきれない場合
    rescue ArgumentError
    end
  end
  return date
end



#------------------------------
# 路線マスタ／駅マスタを登録します。
#------------------------------
def init_station

  # 路線マスタの登録
  line_arr = []
  line_arr.push(:code=>'13', :name=>'営団千代田線')
  line_arr.push(:code=>'24', :name=>'京成本線')
  line_arr.push(:code=>'12', :name=>'営団日比谷線')
  line_arr.push(:code=>'1', :name=>'東武伊勢崎線')
  line_arr.push(:code=>'16', :name=>'都営新宿線')
  line_arr.push(:code=>'14', :name=>'営団東西線')
  line_arr.push(:code=>'20', :name=>'京浜東北線（南）')
  line_arr.push(:code=>'15', :name=>'東武東上線')
  line_arr.push(:code=>'6', :name=>'埼京線')
  line_arr.push(:code=>'5', :name=>'京浜東北線（北）')
  line_arr.push(:code=>'17', :name=>'川越線')
  line_arr.push(:code=>'10', :name=>'宇都宮線')
  line_arr.push(:code=>'2', :name=>'武蔵野線')
  line_arr.push(:code=>'4', :name=>'東武野田線')
  line_arr.push(:code=>'7', :name=>'新京成線')
  line_arr.push(:code=>'9', :name=>'北総公団線')
  line_arr.push(:code=>'8', :name=>'総武流山電鉄線')
  line_arr.push(:code=>'19', :name=>'高崎線')
  line_arr.push(:code=>'18', :name=>'ニューシャトル')
  line_arr.push(:code=>'11', :name=>'東武大師線')
  line_arr.push(:code=>'21', :name=>'東武日光線')
  line_arr.push(:code=>'22', :name=>'埼玉高速鉄道線')
  line_arr.push(:code=>'3', :name=>'常磐線')
  line_arr.push(:code=>'25', :name=>'都営三田線')
  line_arr.push(:code=>'26', :name=>'総武線')
  line_arr.push(:code=>'27', :name=>'営団銀座線')
  line_arr.push(:code=>'28', :name=>'ＪＲ山手線')
  line_arr.push(:code=>'29', :name=>'京成押上線')
  line_arr.push(:code=>'30', :name=>'つくばｴｸｽﾌﾟﾚｽ')
  line_arr.push(:code=>'31', :name=>'都営大江戸線')
  line_arr.push(:code=>'32', :name=>'東急東横線')
  line_arr.push(:code=>'33', :name=>'日暮里･舎人ﾗｲﾅｰ')
  line_arr.push(:code=>'34', :name=>'東京ﾒﾄﾛ南北線')
  line_arr.push(:code=>'35', :name=>'都営浅草線')
  line_arr.push(:code=>'36', :name=>'半蔵門線')
  line_arr.push(:code=>'37', :name=>'ＪＲ成田線')
  line_arr.push(:code=>'38', :name=>'JR京葉線')
  line_arr.push(:code=>'41', :name=>'JR総武本線')
  line_arr.push(:code=>'39', :name=>'中央線')
  line_arr.push(:code=>'40', :name=>'千葉ﾓﾉﾚｰﾙ')
  line_arr.push(:code=>'42', :name=>'東京ﾒﾄﾛ有楽町線')
  line_arr.push(:code=>'43', :name=>'東京ﾒﾄﾛ副都心線')
  line_arr.push(:code=>'44', :name=>'京成金町線')
  line_arr.push(:code=>'45', :name=>'西武新宿線')

  line_arr.each do |obj|
    line = Line.find_or_create_by_code(obj[:code])
    line.code = obj[:code]
    line.name = obj[:name]
    line.save!
    p line.name
  end

  # 駅の登録
  station_arr = []
  station_arr.push(:code=>'3', :name=>'曳船', :line_code=>'1', :address=>'墨田区東向島２丁目', :longitude=>139.816634, :latitude=>35.718418, :gmaps=>true);
  station_arr.push(:code=>'4', :name=>'東向島', :line_code=>'1', :address=>'墨田区東向島４丁目', :longitude=>139.819306, :latitude=>35.724324, :gmaps=>true);
  station_arr.push(:code=>'5', :name=>'鐘ヶ淵', :line_code=>'1', :address=>'東京都墨田区墨田5丁目', :longitude=>139.820344, :latitude=>35.733712, :gmaps=>true);
  station_arr.push(:code=>'6', :name=>'堀切', :line_code=>'1', :address=>'足立区千住曙町', :longitude=>139.817727, :latitude=>35.742977, :gmaps=>true);
  station_arr.push(:code=>'7', :name=>'牛田', :line_code=>'1', :address=>'足立区千住曙町', :longitude=>139.811816, :latitude=>35.744555, :gmaps=>true);
  station_arr.push(:code=>'8', :name=>'北千住', :line_code=>'1', :address=>'足立区千住旭町', :longitude=>139.805564, :latitude=>35.749891, :gmaps=>true);
  station_arr.push(:code=>'9', :name=>'小菅', :line_code=>'1', :address=>'足立区足立２丁目', :longitude=>139.812935, :latitude=>35.759039, :gmaps=>true);
  station_arr.push(:code=>'10', :name=>'五反野', :line_code=>'1', :address=>'足立区足立３丁目', :longitude=>139.809643, :latitude=>35.765852, :gmaps=>true);
  station_arr.push(:code=>'11', :name=>'梅島', :line_code=>'1', :address=>'足立区梅田７丁目', :longitude=>139.797916, :latitude=>35.772437, :gmaps=>true);
  station_arr.push(:code=>'12', :name=>'西新井', :line_code=>'1', :address=>'足立区西新井栄町２丁目', :longitude=>139.790372, :latitude=>35.777323, :gmaps=>true);
  station_arr.push(:code=>'13', :name=>'竹の塚', :line_code=>'1', :address=>'足立区竹の塚６丁目', :longitude=>139.790788, :latitude=>35.794368, :gmaps=>true);
  station_arr.push(:code=>'14', :name=>'谷塚', :line_code=>'1', :address=>'草加市谷塚町', :longitude=>139.801483, :latitude=>35.814926, :gmaps=>true);
  station_arr.push(:code=>'15', :name=>'草加', :line_code=>'1', :address=>'草加市高砂２丁目', :longitude=>139.803397, :latitude=>35.828476, :gmaps=>true);
  station_arr.push(:code=>'16', :name=>'松原団地', :line_code=>'1', :address=>'草加市松原１丁目', :longitude=>139.800622, :latitude=>35.84333, :gmaps=>true);
  station_arr.push(:code=>'17', :name=>'新田', :line_code=>'1', :address=>'草加市金明町', :longitude=>139.795391, :latitude=>35.854086, :gmaps=>true);
  station_arr.push(:code=>'18', :name=>'蒲生', :line_code=>'1', :address=>'越谷市蒲生寿町', :longitude=>139.791686, :latitude=>35.866851, :gmaps=>true);
  station_arr.push(:code=>'19', :name=>'新越谷', :line_code=>'1', :address=>'越谷市南越谷１丁目', :longitude=>139.789905, :latitude=>35.875186, :gmaps=>true);
  station_arr.push(:code=>'20', :name=>'越谷', :line_code=>'1', :address=>'越谷市弥生町', :longitude=>139.786213, :latitude=>35.887529, :gmaps=>true);
  station_arr.push(:code=>'21', :name=>'北越谷', :line_code=>'1', :address=>'越谷市大澤３丁目', :longitude=>139.780008, :latitude=>35.901724, :gmaps=>true);
  station_arr.push(:code=>'22', :name=>'大袋', :line_code=>'1', :address=>'越谷市大字袋山', :longitude=>139.777868, :latitude=>35.92437, :gmaps=>true);
  station_arr.push(:code=>'23', :name=>'せんげん台', :line_code=>'1', :address=>'越谷市千間台東町', :longitude=>139.774478, :latitude=>35.935832, :gmaps=>true);
  station_arr.push(:code=>'24', :name=>'武里', :line_code=>'1', :address=>'春日部市大字大場', :longitude=>139.770675, :latitude=>35.949102, :gmaps=>true);
  station_arr.push(:code=>'25', :name=>'一ノ割', :line_code=>'1', :address=>'春日部市一ノ割１丁目', :longitude=>139.766219, :latitude=>35.96412, :gmaps=>true);
  station_arr.push(:code=>'26', :name=>'春日部', :line_code=>'1', :address=>'春日部市粕壁１丁目', :longitude=>139.752345, :latitude=>35.980095, :gmaps=>true);
  station_arr.push(:code=>'27', :name=>'北春日部', :line_code=>'1', :address=>'春日部市大字梅田字堤際', :longitude=>139.744012, :latitude=>35.990655, :gmaps=>true);
  station_arr.push(:code=>'28', :name=>'姫宮', :line_code=>'1', :address=>'南埼玉郡宮代町川端１丁目', :longitude=>139.738674, :latitude=>36.004384, :gmaps=>true);
  station_arr.push(:code=>'29', :name=>'東武動物公園', :line_code=>'1', :address=>'南埼玉郡宮代町大字百間２丁目', :longitude=>139.726901, :latitude=>36.024604, :gmaps=>true);
  station_arr.push(:code=>'30', :name=>'和戸', :line_code=>'1', :address=>'南埼玉郡宮代町和戸１丁目', :longitude=>139.701156, :latitude=>36.039562, :gmaps=>true);
  station_arr.push(:code=>'31', :name=>'鷲宮', :line_code=>'1', :address=>'北葛飾郡鷲宮町中央１丁目', :longitude=>139.656945, :latitude=>36.09626, :gmaps=>true);
  station_arr.push(:code=>'32', :name=>'久喜', :line_code=>'1', :address=>'久喜市中央２丁目', :longitude=>139.67727, :latitude=>36.065684, :gmaps=>true);
  station_arr.push(:code=>'33', :name=>'花崎', :line_code=>'1', :address=>'加須市花崎', :longitude=>139.633522, :latitude=>36.109891, :gmaps=>true);
  station_arr.push(:code=>'34', :name=>'加須', :line_code=>'1', :address=>'加須市中央１丁目', :longitude=>139.595584, :latitude=>36.122992, :gmaps=>true);
  station_arr.push(:code=>'35', :name=>'南羽生', :line_code=>'1', :address=>'羽生市大字神戸', :longitude=>139.55696, :latitude=>36.14959, :gmaps=>true);
  station_arr.push(:code=>'36', :name=>'羽生', :line_code=>'1', :address=>'羽生市南１', :longitude=>139.533949, :latitude=>36.170345, :gmaps=>true);
  station_arr.push(:code=>'37', :name=>'川俣', :line_code=>'1', :address=>'邑楽郡明和町大字中谷３２８-３', :longitude=>139.52652, :latitude=>36.208778, :gmaps=>true);
  station_arr.push(:code=>'1', :name=>'府中本町', :line_code=>'2', :address=>'府中市本町１丁目', :longitude=>139.477142, :latitude=>35.665766, :gmaps=>true);
  station_arr.push(:code=>'2', :name=>'北府中', :line_code=>'2', :address=>'府中市晴見町２丁目', :longitude=>139.471792, :latitude=>35.68088, :gmaps=>true);
  station_arr.push(:code=>'3', :name=>'西国分寺', :line_code=>'2', :address=>'国分寺市西恋ケ窪２丁目', :longitude=>139.465994, :latitude=>35.699744, :gmaps=>true);
  station_arr.push(:code=>'4', :name=>'新小平', :line_code=>'2', :address=>'小平市小川町２丁目', :longitude=>139.470745, :latitude=>35.73128, :gmaps=>true);
  station_arr.push(:code=>'5', :name=>'新秋津', :line_code=>'2', :address=>'東村山市秋津町５丁目', :longitude=>139.493592, :latitude=>35.778331, :gmaps=>true);
  station_arr.push(:code=>'6', :name=>'東所沢', :line_code=>'2', :address=>'所沢市本郷１丁目', :longitude=>139.513878, :latitude=>35.79461, :gmaps=>true);
  station_arr.push(:code=>'7', :name=>'新座', :line_code=>'2', :address=>'新座市野火止５丁目', :longitude=>139.556328, :latitude=>35.80381, :gmaps=>true);
  station_arr.push(:code=>'8', :name=>'北朝霞', :line_code=>'2', :address=>'朝霞市浜崎１丁目', :longitude=>139.587322, :latitude=>35.815475, :gmaps=>true);
  station_arr.push(:code=>'9', :name=>'西浦和', :line_code=>'2', :address=>'さいたま市桜区田島５丁目', :longitude=>139.627707, :latitude=>35.844139, :gmaps=>true);
  station_arr.push(:code=>'10', :name=>'武蔵浦和', :line_code=>'2', :address=>'さいたま市南区別所七丁目12-1', :longitude=>139.647974, :latitude=>35.846047, :gmaps=>true);
  station_arr.push(:code=>'11', :name=>'南浦和', :line_code=>'2', :address=>'さいたま市南区南浦和２丁目', :longitude=>139.669125, :latitude=>35.847648, :gmaps=>true);
  station_arr.push(:code=>'12', :name=>'東浦和', :line_code=>'2', :address=>'さいたま市緑区大牧', :longitude=>139.704627, :latitude=>35.864079, :gmaps=>true);
  station_arr.push(:code=>'13', :name=>'東川口', :line_code=>'2', :address=>'川口市戸塚１丁目', :longitude=>139.744087, :latitude=>35.875246, :gmaps=>true);
  station_arr.push(:code=>'14', :name=>'南越谷', :line_code=>'2', :address=>'越谷市南越谷１丁目', :longitude=>139.790499, :latitude=>35.876106, :gmaps=>true);
  station_arr.push(:code=>'15', :name=>'吉川', :line_code=>'2', :address=>'吉川市木売１-６-１', :longitude=>139.843162, :latitude=>35.87662, :gmaps=>true);
  station_arr.push(:code=>'16', :name=>'新三郷', :line_code=>'2', :address=>'三郷市半田', :longitude=>139.869341, :latitude=>35.858667, :gmaps=>true);
  station_arr.push(:code=>'17', :name=>'三郷', :line_code=>'2', :address=>'三郷市三郷', :longitude=>139.886341, :latitude=>35.845004, :gmaps=>true);
  station_arr.push(:code=>'18', :name=>'南流山', :line_code=>'2', :address=>'流山市大字鰭ケ崎', :longitude=>139.903865, :latitude=>35.838035, :gmaps=>true);
  station_arr.push(:code=>'19', :name=>'新松戸', :line_code=>'2', :address=>'松戸市幸谷', :longitude=>139.921076, :latitude=>35.825467, :gmaps=>true);
  station_arr.push(:code=>'20', :name=>'新八柱', :line_code=>'2', :address=>'松戸市日暮', :longitude=>139.938393, :latitude=>35.792013, :gmaps=>true);
  station_arr.push(:code=>'21', :name=>'市川大野', :line_code=>'2', :address=>'市川市大野町３丁目', :longitude=>139.951227, :latitude=>35.755432, :gmaps=>true);
  station_arr.push(:code=>'22', :name=>'船橋法典', :line_code=>'2', :address=>'船橋市藤原１丁目', :longitude=>139.966771, :latitude=>35.730435, :gmaps=>true);
  station_arr.push(:code=>'23', :name=>'西船橋', :line_code=>'2', :address=>'船橋市西船４丁目', :longitude=>139.959536, :latitude=>35.707283, :gmaps=>true);
  station_arr.push(:code=>'25', :name=>'越谷レイクタウン', :line_code=>'2', :address=>'越谷市大成町５丁目', :longitude=>139.820219, :latitude=>35.87622, :gmaps=>true);
  station_arr.push(:code=>'26', :name=>'東松戸', :line_code=>'2', :address=>'千葉県松戸市紙敷', :longitude=>139.943848, :latitude=>35.770611, :gmaps=>true);
  station_arr.push(:code=>'27', :name=>'吉川美南', :line_code=>'2', :address=>'埼玉県吉川市', :longitude=>139.858167, :latitude=>35.868056, :gmaps=>true);
  station_arr.push(:code=>'1', :name=>'三河島', :line_code=>'3', :address=>'荒川区西日暮里１丁目', :longitude=>139.777131, :latitude=>35.733383, :gmaps=>true);
  station_arr.push(:code=>'2', :name=>'南千住', :line_code=>'3', :address=>'荒川区南千住４丁目', :longitude=>139.7994, :latitude=>35.734033, :gmaps=>true);
  station_arr.push(:code=>'3', :name=>'北千住', :line_code=>'3', :address=>'足立区千住旭町', :longitude=>139.804872, :latitude=>35.749677, :gmaps=>true);
  station_arr.push(:code=>'4', :name=>'綾瀬', :line_code=>'3', :address=>'足立区綾瀬３丁目', :longitude=>139.825019, :latitude=>35.762222, :gmaps=>true);
  station_arr.push(:code=>'5', :name=>'亀有', :line_code=>'3', :address=>'葛飾区亀有３', :longitude=>139.847573, :latitude=>35.766527, :gmaps=>true);
  station_arr.push(:code=>'6', :name=>'金町', :line_code=>'3', :address=>'葛飾区金町６丁目', :longitude=>139.870482, :latitude=>35.769582, :gmaps=>true);
  station_arr.push(:code=>'7', :name=>'松戸', :line_code=>'3', :address=>'松戸市松戸', :longitude=>139.900779, :latitude=>35.784472, :gmaps=>true);
  station_arr.push(:code=>'8', :name=>'北松戸', :line_code=>'3', :address=>'松戸市上本郷', :longitude=>139.911528, :latitude=>35.800459, :gmaps=>true);
  station_arr.push(:code=>'9', :name=>'馬橋', :line_code=>'3', :address=>'松戸市馬橋', :longitude=>139.917305, :latitude=>35.811682, :gmaps=>true);
  station_arr.push(:code=>'10', :name=>'新松戸', :line_code=>'3', :address=>'松戸市幸谷', :longitude=>139.921076, :latitude=>35.825467, :gmaps=>true);
  station_arr.push(:code=>'11', :name=>'北小金', :line_code=>'3', :address=>'松戸市小金', :longitude=>139.931303, :latitude=>35.833436, :gmaps=>true);
  station_arr.push(:code=>'12', :name=>'南柏', :line_code=>'3', :address=>'柏市南柏１', :longitude=>139.954111, :latitude=>35.844655, :gmaps=>true);
  station_arr.push(:code=>'13', :name=>'柏', :line_code=>'3', :address=>'柏市柏１', :longitude=>139.971148, :latitude=>35.862316, :gmaps=>true);
  station_arr.push(:code=>'14', :name=>'北柏', :line_code=>'3', :address=>'柏市大字根戸', :longitude=>139.988035, :latitude=>35.875623, :gmaps=>true);
  station_arr.push(:code=>'15', :name=>'我孫子', :line_code=>'3', :address=>'我孫子市本町２丁目', :longitude=>140.010466, :latitude=>35.87279, :gmaps=>true);
  station_arr.push(:code=>'16', :name=>'天王台', :line_code=>'3', :address=>'我孫子市柴崎台１', :longitude=>140.04121, :latitude=>35.872558, :gmaps=>true);
  station_arr.push(:code=>'17', :name=>'取手', :line_code=>'3', :address=>'取手市中央町', :longitude=>140.063004, :latitude=>35.89553, :gmaps=>true);
  station_arr.push(:code=>'18', :name=>'藤代', :line_code=>'3', :address=>'取手市宮和田', :longitude=>140.118251, :latitude=>35.920565, :gmaps=>true);
  station_arr.push(:code=>'19', :name=>'佐貫', :line_code=>'3', :address=>'龍ケ崎市佐貫町', :longitude=>140.138217, :latitude=>35.930066, :gmaps=>true);
  station_arr.push(:code=>'20', :name=>'牛久', :line_code=>'3', :address=>'牛久市牛久町', :longitude=>140.141039, :latitude=>35.975314, :gmaps=>true);
  station_arr.push(:code=>'21', :name=>'荒川沖', :line_code=>'3', :address=>'土浦市大字荒川沖東２', :longitude=>140.16592, :latitude=>36.030552, :gmaps=>true);
  station_arr.push(:code=>'22', :name=>'土浦', :line_code=>'3', :address=>'土浦市有明町', :longitude=>140.206238, :latitude=>36.078644, :gmaps=>true);
  station_arr.push(:code=>'1', :name=>'大宮', :line_code=>'4', :address=>'さいたま市大宮区錦町', :longitude=>139.624458, :latitude=>35.907599, :gmaps=>true);
  station_arr.push(:code=>'2', :name=>'北大宮', :line_code=>'4', :address=>'さいたま市大宮区土手町３-２８５', :longitude=>139.624726, :latitude=>35.91716, :gmaps=>true);
  station_arr.push(:code=>'3', :name=>'大宮公園', :line_code=>'4', :address=>'さいたま市大宮区寿能町１-１７２', :longitude=>139.632903, :latitude=>35.92374, :gmaps=>true);
  station_arr.push(:code=>'4', :name=>'大和田', :line_code=>'4', :address=>'さいたま市見沼区大和田町２-１７７４', :longitude=>139.65051, :latitude=>35.929359, :gmaps=>true);
  station_arr.push(:code=>'5', :name=>'七里', :line_code=>'4', :address=>'さいたま市見沼区風渡野６０３', :longitude=>139.665948, :latitude=>35.936464, :gmaps=>true);
  station_arr.push(:code=>'6', :name=>'岩槻', :line_code=>'4', :address=>'さいたま市岩槻区本町', :longitude=>139.693197, :latitude=>35.950239, :gmaps=>true);
  station_arr.push(:code=>'7', :name=>'東岩槻', :line_code=>'4', :address=>'さいたま市岩槻区東岩槻１-１２-１', :longitude=>139.712192, :latitude=>35.963273, :gmaps=>true);
  station_arr.push(:code=>'8', :name=>'豊春', :line_code=>'4', :address=>'春日部市大字上蛭田１３６-１', :longitude=>139.72601, :latitude=>35.968014, :gmaps=>true);
  station_arr.push(:code=>'9', :name=>'八木崎', :line_code=>'4', :address=>'春日部市大字粕壁６９４６', :longitude=>139.741785, :latitude=>35.978376, :gmaps=>true);
  station_arr.push(:code=>'10', :name=>'春日部', :line_code=>'4', :address=>'春日部市粕壁１丁目', :longitude=>139.752345, :latitude=>35.980095, :gmaps=>true);
  station_arr.push(:code=>'11', :name=>'藤の牛島', :line_code=>'4', :address=>'春日部市大字牛島１５７６', :longitude=>139.778038, :latitude=>35.98026, :gmaps=>true);
  station_arr.push(:code=>'12', :name=>'南桜井', :line_code=>'4', :address=>'春日部市米島１１８５', :longitude=>139.807988, :latitude=>35.980441, :gmaps=>true);
  station_arr.push(:code=>'13', :name=>'川間', :line_code=>'4', :address=>'野田市尾崎８３２', :longitude=>139.83385, :latitude=>35.979172, :gmaps=>true);
  station_arr.push(:code=>'14', :name=>'七光台', :line_code=>'4', :address=>'野田市吉春９３１-５', :longitude=>139.852906, :latitude=>35.970884, :gmaps=>true);
  station_arr.push(:code=>'15', :name=>'清水公園', :line_code=>'4', :address=>'野田市清水３７５', :longitude=>139.85967, :latitude=>35.959364, :gmaps=>true);
  station_arr.push(:code=>'16', :name=>'愛宕', :line_code=>'4', :address=>'野田市中野台１２１７', :longitude=>139.864817, :latitude=>35.950154, :gmaps=>true);
  station_arr.push(:code=>'17', :name=>'野田市', :line_code=>'4', :address=>'野田市野田１２８', :longitude=>139.870728, :latitude=>35.943652, :gmaps=>true);
  station_arr.push(:code=>'18', :name=>'梅郷', :line_code=>'4', :address=>'野田市山崎１８９２', :longitude=>139.891086, :latitude=>35.931575, :gmaps=>true);
  station_arr.push(:code=>'19', :name=>'運河', :line_code=>'4', :address=>'流山市東深井４０５', :longitude=>139.906063, :latitude=>35.914392, :gmaps=>true);
  station_arr.push(:code=>'20', :name=>'江戸川台', :line_code=>'4', :address=>'流山市江戸川台東１-３', :longitude=>139.91045, :latitude=>35.897344, :gmaps=>true);
  station_arr.push(:code=>'21', :name=>'初石', :line_code=>'4', :address=>'流山市西初石３-１００', :longitude=>139.917861, :latitude=>35.883783, :gmaps=>true);
  station_arr.push(:code=>'22', :name=>'豊四季', :line_code=>'4', :address=>'柏市豊四季１５９', :longitude=>139.93929, :latitude=>35.86657, :gmaps=>true);
  station_arr.push(:code=>'23', :name=>'柏', :line_code=>'4', :address=>'柏市柏１', :longitude=>139.971148, :latitude=>35.862316, :gmaps=>true);
  station_arr.push(:code=>'24', :name=>'新柏', :line_code=>'4', :address=>'柏市新柏１-１５１０', :longitude=>139.966994, :latitude=>35.838128, :gmaps=>true);
  station_arr.push(:code=>'25', :name=>'増尾', :line_code=>'4', :address=>'柏市増尾１-１-１', :longitude=>139.976604, :latitude=>35.829704, :gmaps=>true);
  station_arr.push(:code=>'26', :name=>'逆井', :line_code=>'4', :address=>'柏市逆井８４８', :longitude=>139.983812, :latitude=>35.823336, :gmaps=>true);
  station_arr.push(:code=>'27', :name=>'高柳', :line_code=>'4', :address=>'柏市高柳１４８９', :longitude=>139.998936, :latitude=>35.808211, :gmaps=>true);
  station_arr.push(:code=>'28', :name=>'六実', :line_code=>'4', :address=>'松戸市六実４-６-１', :longitude=>139.999195, :latitude=>35.793715, :gmaps=>true);
  station_arr.push(:code=>'29', :name=>'鎌ヶ谷', :line_code=>'4', :address=>'千葉県鎌ケ谷市道野辺中央2-1-10', :longitude=>139.997266, :latitude=>35.763765, :gmaps=>true);
  station_arr.push(:code=>'30', :name=>'馬込沢', :line_code=>'4', :address=>'船橋市藤原７-２-１', :longitude=>139.992199, :latitude=>35.741586, :gmaps=>true);
  station_arr.push(:code=>'31', :name=>'塚田', :line_code=>'4', :address=>'船橋市前貝塚町５６４', :longitude=>139.982859, :latitude=>35.722102, :gmaps=>true);
  station_arr.push(:code=>'32', :name=>'新船橋', :line_code=>'4', :address=>'船橋市山手１-３-１', :longitude=>139.979765, :latitude=>35.710993, :gmaps=>true);
  station_arr.push(:code=>'33', :name=>'船橋', :line_code=>'4', :address=>'船橋市本町７丁目', :longitude=>139.98436, :latitude=>35.7021, :gmaps=>true);
  station_arr.push(:code=>'34', :name=>'流山おおたかの森', :line_code=>'4', :address=>'流山市西初石六丁目', :longitude=>139.925898, :latitude=>35.872051, :gmaps=>true);
  station_arr.push(:code=>'1', :name=>'上中里', :line_code=>'5', :address=>'北区上中里１丁目', :longitude=>139.745769, :latitude=>35.74728, :gmaps=>true);
  station_arr.push(:code=>'2', :name=>'王子', :line_code=>'5', :address=>'北区王子１丁目', :longitude=>139.73809, :latitude=>35.752538, :gmaps=>true);
  station_arr.push(:code=>'3', :name=>'東十条', :line_code=>'5', :address=>'北区東十条３丁目', :longitude=>139.726858, :latitude=>35.763803, :gmaps=>true);
  station_arr.push(:code=>'4', :name=>'赤羽', :line_code=>'5', :address=>'北区赤羽１丁目', :longitude=>139.720928, :latitude=>35.778026, :gmaps=>true);
  station_arr.push(:code=>'5', :name=>'川口', :line_code=>'5', :address=>'川口市栄町３丁目', :longitude=>139.717472, :latitude=>35.801869, :gmaps=>true);
  station_arr.push(:code=>'6', :name=>'西川口', :line_code=>'5', :address=>'川口市並木町２丁目', :longitude=>139.704312, :latitude=>35.815514, :gmaps=>true);
  station_arr.push(:code=>'7', :name=>'蕨', :line_code=>'5', :address=>'蕨市中央１丁目', :longitude=>139.690357, :latitude=>35.827959, :gmaps=>true);
  station_arr.push(:code=>'8', :name=>'南浦和', :line_code=>'5', :address=>'さいたま市南区南浦和２丁目', :longitude=>139.669125, :latitude=>35.847648, :gmaps=>true);
  station_arr.push(:code=>'9', :name=>'浦和', :line_code=>'5', :address=>'さいたま市浦和区高砂１丁目', :longitude=>139.657109, :latitude=>35.858496, :gmaps=>true);
  station_arr.push(:code=>'10', :name=>'北浦和', :line_code=>'5', :address=>'さいたま市浦和区北浦和３丁目', :longitude=>139.645951, :latitude=>35.872053, :gmaps=>true);
  station_arr.push(:code=>'11', :name=>'与野', :line_code=>'5', :address=>'さいたま市浦和区上木崎１丁目', :longitude=>139.639085, :latitude=>35.884393, :gmaps=>true);
  station_arr.push(:code=>'12', :name=>'大宮', :line_code=>'5', :address=>'さいたま市大宮区錦町', :longitude=>139.62405, :latitude=>35.906439, :gmaps=>true);
  station_arr.push(:code=>'13', :name=>'さいたま新都心', :line_code=>'5', :address=>'さいたま市大宮区吉敷町４丁目５７番地３', :longitude=>139.633587, :latitude=>35.893867, :gmaps=>true);
  station_arr.push(:code=>'1', :name=>'板橋', :line_code=>'6', :address=>'板橋区板橋１丁目', :longitude=>139.719507, :latitude=>35.745435, :gmaps=>true);
  station_arr.push(:code=>'2', :name=>'十条', :line_code=>'6', :address=>'北区上十条１丁目', :longitude=>139.722233, :latitude=>35.760321, :gmaps=>true);
  station_arr.push(:code=>'3', :name=>'赤羽', :line_code=>'6', :address=>'北区赤羽１丁目', :longitude=>139.720928, :latitude=>35.778026, :gmaps=>true);
  station_arr.push(:code=>'4', :name=>'北赤羽', :line_code=>'6', :address=>'北区赤羽北２丁目', :longitude=>139.70569, :latitude=>35.787007, :gmaps=>true);
  station_arr.push(:code=>'5', :name=>'浮間舟渡', :line_code=>'6', :address=>'北区浮間４丁目', :longitude=>139.691341, :latitude=>35.791209, :gmaps=>true);
  station_arr.push(:code=>'6', :name=>'戸田公園', :line_code=>'6', :address=>'戸田市本町４丁目', :longitude=>139.678203, :latitude=>35.807906, :gmaps=>true);
  station_arr.push(:code=>'7', :name=>'戸田', :line_code=>'6', :address=>'戸田市新曽字柳原', :longitude=>139.669548, :latitude=>35.817665, :gmaps=>true);
  station_arr.push(:code=>'8', :name=>'北戸田', :line_code=>'6', :address=>'戸田市新曽字芦原', :longitude=>139.661201, :latitude=>35.826883, :gmaps=>true);
  station_arr.push(:code=>'9', :name=>'武蔵浦和', :line_code=>'6', :address=>'さいたま市南区別所七丁目12-1', :longitude=>139.646809, :latitude=>35.845422, :gmaps=>true);
  station_arr.push(:code=>'10', :name=>'中浦和', :line_code=>'6', :address=>'さいたま市南区鹿手袋１丁目', :longitude=>139.6375, :latitude=>35.853769, :gmaps=>true);
  station_arr.push(:code=>'11', :name=>'南与野', :line_code=>'6', :address=>'さいたま市中央区鈴谷２丁目', :longitude=>139.631117, :latitude=>35.867456, :gmaps=>true);
  station_arr.push(:code=>'12', :name=>'与野本町', :line_code=>'6', :address=>'さいたま市中央区本町東２丁目', :longitude=>139.626075, :latitude=>35.880968, :gmaps=>true);
  station_arr.push(:code=>'13', :name=>'北与野', :line_code=>'6', :address=>'さいたま市中央区上落合', :longitude=>139.628521, :latitude=>35.890678, :gmaps=>true);
  station_arr.push(:code=>'14', :name=>'大宮', :line_code=>'6', :address=>'さいたま市大宮区錦町', :longitude=>139.62405, :latitude=>35.906439, :gmaps=>true);
  station_arr.push(:code=>'15', :name=>'日進', :line_code=>'6', :address=>'さいたま市北区日進町２丁目', :longitude=>139.606111, :latitude=>35.931555, :gmaps=>true);

  # 駅マスタの登録
  station_arr.each do |obj|

    station = Station.find_or_create_by_code_and_line_code(obj[:code], obj[:line_code])
    station.code = obj[:code]
    station.name = obj[:name]
    station.line_code = obj[:line_code]

    line = Line.find_by_code(obj[:line_code])
    if line
      station.line_id = line.id
    end

    station.address = obj[:address]
    station.latitude = obj[:latitude]
    station.longitude = obj[:longitude]
    station.gmaps = true
    station.save!
    p station.name
  end


end

#--------------------------
# 営業所マスタを登録します。
#--------------------------
def init_shop

  show_arr = []

  # 東武支店
  show_arr.push({:code=>3, :name=>'草加営業所', :address=>'埼玉県草加市氷川町2131番地3', :area_id=>1, :group_id=>1, :tel=>'0120-278-342', :tel2=>'048-927-8311', :holiday=>'水曜'})
  show_arr.push({:code=>11, :name=>'草加新田営業所', :address=>'埼玉県草加市金明町276', :area_id=>1, :group_id=>1, :tel=>'0120-702-728', :tel2=>'048-930-2300', :holiday=>'火曜'})
  show_arr.push({:code=>16, :name=>'北千住営業所', :address=>'東京都足立区千住2-22 マスミビル1F', :area_id=>1, :group_id=>1, :tel=>'0120-956-776', :tel2=>'03-5813-1741', :holiday=>'水曜'})
  show_arr.push({:code=>1, :name=>'南越谷営業所', :address=>'埼玉県越谷市南越谷1-20-17　中央ビル管理本社ビル内1F', :area_id=>2, :group_id=>1, :tel=>'0120-754-215', :tel2=>'048-988-8800', :holiday=>'無休'})
  show_arr.push({:code=>18, :name=>'越谷営業所', :address=>'埼玉県越谷市赤山本町2-14', :area_id=>2, :group_id=>1, :tel=>'0120-948-909', :tel2=>'048-969-0111', :holiday=>'水曜'})
  show_arr.push({:code=>8, :name=>'北越谷営業所', :address=>'埼玉県越谷市大沢3-19-17', :area_id=>3, :group_id=>1, :tel=>'0120-304-137', :tel2=>'048-979-4455', :holiday=>'水曜'})
  show_arr.push({:code=>7, :name=>'春日部営業所', :address=>'埼玉県春日部市中央1-2-5', :area_id=>3, :group_id=>1, :tel=>'0120-675-488', :tel2=>'048-793-5488', :holiday=>'火曜'})
  show_arr.push({:code=>21, :name=>'せんげん台営業所', :address=>'埼玉県越谷市千間台東1-8-1', :area_id=>3, :group_id=>1, :tel=>'0120-929-979', :tel2=>'048-973-3530', :holiday=>'火・水曜'})

  # さいたま支店
  show_arr.push({:code=>22, :name=>'戸田公園営業所', :address=>'戸田市本町4-16-17 熊木ビル3F', :area_id=>11, :group_id=>2, :tel=>'0120-925-009', :tel2=>'048-234-0056', :holiday=>'水曜'})
  show_arr.push({:code=>2, :name=>'戸田営業所', :address=>'埼玉県戸田市大字新曽353-6', :area_id=>11, :group_id=>2, :tel=>'0120-654-021', :tel2=>'048-441-4021', :holiday=>'火曜'})
  show_arr.push({:code=>5, :name=>'武蔵浦和営業所', :address=>'埼玉県さいたま市南区別所7-9-5', :area_id=>12, :group_id=>2, :tel=>'0120-634-315', :tel2=>'048-838-8822', :holiday=>'水曜'})
  show_arr.push({:code=>15, :name=>'川口営業所', :address=>'埼玉県川口市川口1-1-1 キュポ・ラ専門店1F', :area_id=>13, :group_id=>2, :tel=>'0120-163-366', :tel2=>'048-227-3366', :holiday=>'水曜'})
  show_arr.push({:code=>17, :name=>'浦和営業所', :address=>'埼玉県さいたま市浦和区東仲町11-23 3F', :area_id=>14, :group_id=>2, :tel=>'0120-953-833', :tel2=>'048-871-2161', :holiday=>'水曜'})
  show_arr.push({:code=>13, :name=>'与野営業所', :address=>'埼玉県さいたま市浦和区上木崎1丁目8-10', :area_id=>15, :group_id=>2, :tel=>'0120-234-495', :tel2=>'048-823-4388', :holiday=>'水曜'})
  show_arr.push({:code=>10, :name=>'東浦和営業所', :address=>'埼玉県さいたま市緑区東浦和1-14-7', :area_id=>16, :group_id=>2, :tel=>'0120-817-455', :tel2=>'048-876-1611', :holiday=>'水曜'})
  show_arr.push({:code=>6, :name=>'東川口営業所', :address=>'埼玉県川口市東川口2丁目3-35 サクセスＩＭ1F', :area_id=>17, :group_id=>2, :tel=>'0120-643-552', :tel2=>'048-297-3552', :holiday=>'火曜'})
  show_arr.push({:code=>14, :name=>'戸塚安行営業所', :address=>'埼玉県川口市長蔵1-16-19 クレアーレ1F', :area_id=>18, :group_id=>2, :tel=>'0120-577-933', :tel2=>'048-291-0011', :holiday=>'火曜'})

  # 千葉支店
  show_arr.push({:code=>19, :name=>'松戸営業所', :address=>'千葉県松戸市本町18-6 壱番館ビル3Ｆ', :area_id=>21, :group_id=>3, :tel=>'0120-981-703', :tel2=>'047-703-5300', :holiday=>'火・水曜'})
  show_arr.push({:code=>4, :name=>'北松戸営業所', :address=>'千葉県松戸市上本郷900－2 中央第10北松戸ビル1Ｆ', :area_id=>22, :group_id=>3, :tel=>'0120-518-655', :tel2=>'047-364-8655', :holiday=>'火・水曜'})
  show_arr.push({:code=>12, :name=>'南流山営業所', :address=>'千葉県流山市南流山1-1-14', :area_id=>23, :group_id=>3, :tel=>'0120-477-512', :tel2=>'04-7178-8288', :holiday=>'火曜'})
  show_arr.push({:code=>9, :name=>'柏営業所', :address=>'千葉県柏市あけぼの1-1-2', :area_id=>24, :group_id=>3, :tel=>'0120-708-251', :tel2=>'04-7142-8866', :holiday=>'火・水曜'})

  # 法人課
  show_arr.push({:code=>91, :name=>'法人課', :address=>'埼玉県越谷市南越谷４丁目９−６', :area_id=>30, :group_id=>4, :tel=>'0120-922-597', :tel2=>'048-989-0705', :holiday=>'無休'})

  # ダミー　支店など用
  #show_arr.push({:code=>99, :name=>'ダミー', :address=>'', :area_id=>90, :group_id=>9})

  show_arr.each do |obj|
    p obj[:name]
    shop =  Shop.find_or_create_by_code(obj[:code])
    shop.code = obj[:code]
    shop.name = obj[:name]
    shop.address = obj[:address]
    shop.area_id = obj[:area_id]
    shop.group_id = obj[:group_id]
    shop.tel = obj[:tel]
    shop.tel2 = obj[:tel2]
    shop.holiday = obj[:holiday]

    # 支店別にアイコンを指定する
    case shop.group_id
      when 1
        shop.icon = 'http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=%e5%96%b6|00FF00|000000'
      when 2
        shop.icon = 'http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=%e5%96%b6|0033FF|FFFFFF'
      when 3
        shop.icon = 'http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=%e5%96%b6|FFFF00|000000'
      when 4
        shop.icon = 'http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=%e5%96%b6|8A2BE2|FFFFFF'
      else
    end

    # ジオコーディング
    unless shop.code == 99
      biru_geocode(shop, true)
    else
      # スキップする
      shop.gmaps = true
    end

    shop.save!
  end

end

#-------------
# 物件種別の登録
#-------------
def init_biru_type(prefix)
  type_arr = []

  type_arr.push({:name=>'マンション', :code=>'01010', :icon=> prefix + '/assets/marker_yellow.png'})
  type_arr.push({:name=>'分譲マンション', :code=>'01015', :icon=> prefix + '/assets/marker_purple.png'})
  type_arr.push({:name=>'アパート', :code=>'01020', :icon=> prefix + '/assets/marker_blue.png'})
  type_arr.push({:name=>'一戸建貸家', :code=>'01025', :icon=> prefix + '/assets/marker_red.png'})
  type_arr.push({:name=>'テラスハウス', :code=>'01030', :icon=> prefix + '/assets/marker_orange.png'})
  type_arr.push({:name=>'メゾネット', :code=>'01035', :icon=> prefix + '/assets/marker_green.png'})
  type_arr.push({:name=>'店舗', :code=>'01040', :icon=> prefix + '/assets/marker_gray.png'})
  type_arr.push({:name=>'店舗付住宅', :code=>'01045', :icon=> prefix + '/assets/marker_gray.png'})
  type_arr.push({:name=>'事務所', :code=>'01050', :icon=> prefix + '/assets/marker_gray.png'})
  type_arr.push({:name=>'工場', :code=>'01055', :icon=> prefix + '/assets/marker_gray.png'})
  type_arr.push({:name=>'倉庫', :code=>'01060', :icon=> prefix + '/assets/marker_gray.png'})
  type_arr.push({:name=>'倉庫事務所', :code=>'01065', :icon=> prefix + '/assets/marker_gray.png'})
  type_arr.push({:name=>'工場倉庫', :code=>'01070', :icon=> prefix + '/assets/marker_gray.png'})
  type_arr.push({:name=>'定期借地権', :code=>'01085', :icon=> prefix + '/assets/marker_gray.png'})
  type_arr.push({:name=>'その他', :code=>'01998', :icon=> prefix + '/assets/marker_white.png'})

  type_arr.each do |obj|
    biru_type = BuildType.find_or_create_by_code(obj[:code])
    biru_type.code = obj[:code]
    biru_type.name = obj[:name]
    biru_type.icon = obj[:icon]
    biru_type.save!
    p biru_type
  end
end

# 管理方式の登録
def init_manage_type(prefix)

  manage_arr = []

  manage_arr.push(:name=>'一般', :code=>'1', :icon=> prefix + '/assets/marker_yellow.png', :line_color=>'yellow')
  manage_arr.push(:name=>'A管理', :code=>'2', :icon=> prefix + '/assets/marker_red.png', :line_color=>'red')
  manage_arr.push(:name=>'B管理', :code=>'3', :icon=> prefix + '/assets/marker_blue.png', :line_color=>'darkblue')
  manage_arr.push(:name=>'C管理', :code=>'4', :icon=> prefix + '/assets/marker_gray.png', :line_color=>'gray')
  manage_arr.push(:name=>'D管理', :code=>'6', :icon=> prefix + '/assets/marker_purple.png', :line_color=>'purple')
  manage_arr.push(:name=>'総務君', :code=>'7', :icon=> prefix + '/assets/marker_green.png', :line_color=>'green')
  manage_arr.push(:name=>'特優賃', :code=>'8', :icon=> prefix + '/assets/marker_gray.png', :line_color=>'gray')
  manage_arr.push(:name=>'定期借地', :code=>'9', :icon=> prefix + '/assets/marker_gray.png', :line_color=>'gray')
  manage_arr.push(:name=>'業務君', :code=>'10', :icon=> prefix + '/assets/marker_orange.png', :line_color=>'orange')
  manage_arr.push(:name=>'管理外', :code=>'99', :icon=> prefix + '/assets/marker_white.png', :line_color=>'black')

  manage_arr.each do |obj|
    manage_type = ManageType.find_or_create_by_code(obj[:code])
    manage_type.code = obj[:code]
    manage_type.name = obj[:name]
    manage_type.icon = obj[:icon]
    manage_type.line_color = obj[:line_color]
    manage_type.save!
    p manage_type
  end

end

# 部屋種別の登録
def init_room_type
    type_arr = []

    type_arr.push({:name=>'マンション', :code=>'17010'})
    type_arr.push({:name=>'分譲賃貸マンション', :code=>'17015'})
    type_arr.push({:name=>'アパート', :code=>'17020'})
    type_arr.push({:name=>'一戸建貸家', :code=>'17025'})
    type_arr.push({:name=>'テラスハウス', :code=>'17030'})
    type_arr.push({:name=>'メゾネット', :code=>'17035'})
    type_arr.push({:name=>'店舗', :code=>'17040'})
    type_arr.push({:name=>'店舗付住宅', :code=>'17045'})
    type_arr.push({:name=>'事務所', :code=>'17050'})
    type_arr.push({:name=>'工場', :code=>'17055'})
    type_arr.push({:name=>'倉庫', :code=>'17060'})
    type_arr.push({:name=>'工場倉庫', :code=>'17065'})

    type_arr.each do |obj|
      room_type = RoomType.find_or_create_by_code(obj[:code])
      room_type.code = obj[:code]
      room_type.name = obj[:name]
      room_type.save!
      p room_type
    end
end

# 間取りの登録
def init_room_layout
  layout_arr = []
  layout_arr.push({:name=>'１Ｒ', :code=>'18100'})
  layout_arr.push({:name=>'１Ｋ', :code=>'18105'})
  layout_arr.push({:name=>'１ＤＫ', :code=>'18110'})
  layout_arr.push({:name=>'１ＬＤＫ', :code=>'18120'})
  layout_arr.push({:name=>'１ＳＬＤＫ', :code=>'18125'})
  layout_arr.push({:name=>'２Ｋ', :code=>'18200'})
  layout_arr.push({:name=>'２ＤＫ', :code=>'18205'})
  layout_arr.push({:name=>'２ＳＤＫ', :code=>'18210'})
  layout_arr.push({:name=>'２ＬＤＫ', :code=>'18215'})
  layout_arr.push({:name=>'２ＳＬＤＫ', :code=>'18220'})
  layout_arr.push({:name=>'３Ｋ', :code=>'18300'})
  layout_arr.push({:name=>'３ＤＫ', :code=>'18305'})
  layout_arr.push({:name=>'３ＳＤＫ', :code=>'18310'})
  layout_arr.push({:name=>'３ＳＫ', :code=>'18311'})
  layout_arr.push({:name=>'３ＬＤＫ', :code=>'18315'})
  layout_arr.push({:name=>'３ＳＬＤＫ', :code=>'18320'})
  layout_arr.push({:name=>'４Ｋ', :code=>'18400'})
  layout_arr.push({:name=>'４ＤＫ', :code=>'18405'})
  layout_arr.push({:name=>'４ＳＤＫ', :code=>'18410'})
  layout_arr.push({:name=>'４ＬＤＫ', :code=>'18415'})
  layout_arr.push({:name=>'４ＳＬＤＫ', :code=>'18420'})
  layout_arr.push({:name=>'５Ｋ', :code=>'18500'})
  layout_arr.push({:name=>'５ＤＫ', :code=>'18505'})
  layout_arr.push({:name=>'５ＳＤＫ', :code=>'18510'})
  layout_arr.push({:name=>'５ＳＫ', :code=>'18511'})
  layout_arr.push({:name=>'５ＬＤＫ', :code=>'18515'})
  layout_arr.push({:name=>'５ＳＬＤＫ', :code=>'18520'})
  layout_arr.push({:name=>'６Ｋ', :code=>'18600'})
  layout_arr.push({:name=>'６ＤＫ', :code=>'18605'})
  layout_arr.push({:name=>'６ＳＤＫ', :code=>'18610'})
  layout_arr.push({:name=>'６ＬＤＫ', :code=>'18615'})
  layout_arr.push({:name=>'６ＳＬＤＫ', :code=>'18620'})
  layout_arr.push({:name=>'７ＤＫ', :code=>'18705'})
  layout_arr.push({:name=>'その他', :code=>'18998'})

  layout_arr.each do |obj|
    room_layout = RoomLayout.find_or_create_by_code(obj[:code])
    room_layout.code = obj[:code]
    room_layout.name = obj[:name]
    room_layout.save!
    p room_layout
  end
end


# アプローチ種別を登録
def init_approach_kind
  arr = []
  arr.push({:name=>'訪問(留守)', :code=>'0010'} )
  arr.push({:name=>'訪問(在宅)', :code=>'0020'} )
  arr.push({:name=>'ＤＭ(発送)', :code=>'0030'} )
  arr.push({:name=>'ＤＭ(反響)', :code=>'0035'} )
  arr.push({:name=>'電話(留守)', :code=>'0040'} )
  arr.push({:name=>'電話(会話)', :code=>'0045'} )
  arr.push({:name=>'メモ(通常)', :code=>'0050'} )
  arr.push({:name=>'メモ(移行)', :code=>'0055'} )
  
  arr.each do |obj|
    app =  ApproachKind.find_or_create_by_code(obj[:code])
    app.name = obj[:name]
    app.code = obj[:code]
    app.save!
    p app
  end
end


# アタックステータス
def init_attack_state
  arr = []
  arr.push({:code=>'S', :name=>'S:契約日決定',:disp_order=>'1', :icon=>'http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=S|FFFF00|000000'})
  arr.push({:code=>'A', :name=>'A:契約予定で提案中',:disp_order=>'2', :icon=>'http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=A|00FF00|000000'})
  arr.push({:code=>'B', :name=>'B:提案書は提出可',:disp_order=>'3', :icon=>'http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=B|00FFFF|000000'})
  arr.push({:code=>'C', :name=>'C:権者に物件ヒアリング',:disp_order=>'4', :icon=>'http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=C|00FF00|000000'})
  arr.push({:code=>'D', :name=>'D:見込みとして追客対象',:disp_order=>'5', :icon=>'http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=D|00FF00|000000'})
  arr.push({:code=>'X', :name=>'X:未設定',:disp_order=>'6', :icon=>'http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=X|00FF00|000000'})
  arr.push({:code=>'Y', :name=>'Y:不成立',:disp_order=>'7', :icon=>'http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=Y|00FF00|000000'})
  arr.push({:code=>'Z', :name=>'Z:成約済',:disp_order=>'8', :icon=>'http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=Z|00FF00|000000'})

  arr.each do |obj|
    attack_state = AttackState.find_or_create_by_code(obj[:code])
    attack_state.code = obj[:code]
    attack_state.name = obj[:name]
    attack_state.disp_order = obj[:disp_order]
    attack_state.icon = obj[:icon]
    attack_state.save!
    p attack_state
  end

end

# データアップデート日時管理テーブル
def init_data_update

  arr = []
  arr.push({:code=>'110', :name=>'自社物件'})
  arr.push({:code=>'115', :name=>'入居・空室状態'})
  arr.push({:code=>'120', :name=>'受託アタックリスト'})
  arr.push({:code=>'210', :name=>'月次データ（売上日報・経営数値）'})
  arr.push({:code=>'220', :name=>'月次データ（来店客数）'})
  arr.push({:code=>'230', :name=>'空き日数'})
  arr.push({:code=>'310', :name=>'レンターズ'})
  arr.push({:code=>'320', :name=>'スーモ'})

  arr.each do |obj|
    rec = DataUpdateTime.find_or_create_by_code(obj[:code])
    rec.code = obj[:code]
    rec.name = obj[:name]
    rec.save!
    p rec
  end
  
end

# 社員マスタ登録
def init_biru_user
	arr = []
arr.push({:uid=>'161', :code=>'999999', :name=>'スーパーバイザー', :pass=>'9'})
arr.push({:uid=>'102', :code=>'662', :name=>'野村 崇志', :pass=>'0662'})
arr.push({:uid=>'103', :code=>'1098', :name=>'玉井 道明', :pass=>'1098'})
arr.push({:uid=>'109', :code=>'1701', :name=>'渡邊 長', :pass=>'1701'})
arr.push({:uid=>'112', :code=>'1893', :name=>'小野田 教志', :pass=>'1893'})
arr.push({:uid=>'127', :code=>'2952', :name=>'日橋 満匡', :pass=>'2952'})
arr.push({:uid=>'128', :code=>'2980', :name=>'保村 大輔', :pass=>'2980'})
arr.push({:uid=>'129', :code=>'3003', :name=>'内田 裕子', :pass=>'3003'})
arr.push({:uid=>'136', :code=>'9048', :name=>'穴沢 一美', :pass=>'9048'})
arr.push({:uid=>'106', :code=>'1385', :name=>'関口 光伸', :pass=>'1385'})
arr.push({:uid=>'108', :code=>'1692', :name=>'内田 栄二', :pass=>'1692'})
arr.push({:uid=>'131', :code=>'3028', :name=>'田中 亜佳子', :pass=>'3028'})
arr.push({:uid=>'134', :code=>'8933', :name=>'高橋 則子', :pass=>'8933'})
arr.push({:uid=>'198', :code=>'2958', :name=>'野村 真也', :pass=>'2958'})
arr.push({:uid=>'202', :code=>'1856', :name=>'仁科 浩', :pass=>'1856'})
arr.push({:uid=>'206', :code=>'838', :name=>'小澤 聡', :pass=>'0838'})
arr.push({:uid=>'209', :code=>'2941', :name=>'長島 広和', :pass=>'2941'})
arr.push({:uid=>'210', :code=>'2992', :name=>'渡辺 英明', :pass=>'9229'})
arr.push({:uid=>'217', :code=>'8916', :name=>'堀江 洋子', :pass=>'8916'})
arr.push({:uid=>'219', :code=>'1419', :name=>'尾花 弘明', :pass=>'1419'})
arr.push({:uid=>'233', :code=>'3423', :name=>'藤田 かおり', :pass=>'0126'})
arr.push({:uid=>'270', :code=>'3280', :name=>'塩野 淳', :pass=>'3280'})
arr.push({:uid=>'302', :code=>'11131', :name=>'﨓 和子', :pass=>'11131'})
arr.push({:uid=>'313', :code=>'2973', :name=>'水澤 浩', :pass=>'2973'})
arr.push({:uid=>'530', :code=>'1737', :name=>'吉田 一志', :pass=>'1737'})
arr.push({:uid=>'618', :code=>'2937', :name=>'長澤 勝人', :pass=>'2937'})
arr.push({:uid=>'747', :code=>'3705', :name=>'奥 哲也', :pass=>'3705'})
arr.push({:uid=>'749', :code=>'3575', :name=>'川島 茂男', :pass=>'3575'})
arr.push({:uid=>'750', :code=>'3589', :name=>'古賀 淳也', :pass=>'8413'})
arr.push({:uid=>'758', :code=>'3289', :name=>'関 毅雄', :pass=>'3289'})
arr.push({:uid=>'778', :code=>'3674', :name=>'善如寺 昭代', :pass=>'3674'})
arr.push({:uid=>'846', :code=>'3783', :name=>'後藤 智明', :pass=>'3783'})
arr.push({:uid=>'848', :code=>'3832', :name=>'杉浦 佳代', :pass=>'3832'})
arr.push({:uid=>'869', :code=>'9850', :name=>'北原 弓子', :pass=>'9850'})
arr.push({:uid=>'888', :code=>'9825', :name=>'青嶋 詠子', :pass=>'9825'})
arr.push({:uid=>'904', :code=>'3903', :name=>'野村 知正', :pass=>'3903'})
arr.push({:uid=>'906', :code=>'3905', :name=>'石原 浩平', :pass=>'3905'})
arr.push({:uid=>'959', :code=>'3999', :name=>'中里 由有紀', :pass=>'3999'})
arr.push({:uid=>'960', :code=>'4004', :name=>'山本 聡子', :pass=>'4004'})
arr.push({:uid=>'981', :code=>'3657', :name=>'岡本 久子', :pass=>'3657'})
arr.push({:uid=>'1012', :code=>'4339', :name=>'伊藤 智子', :pass=>'4339'})
arr.push({:uid=>'1044', :code=>'4252', :name=>'矢吹 美紀', :pass=>'4252'})
arr.push({:uid=>'1061', :code=>'3932', :name=>'河西 祥宜', :pass=>'3932'})
arr.push({:uid=>'1068', :code=>'4304', :name=>'高浦 永伍', :pass=>'4304'})
arr.push({:uid=>'1075', :code=>'10327', :name=>'野村 三千恵', :pass=>'10327'})
arr.push({:uid=>'1090', :code=>'10526', :name=>'阿部 千代子', :pass=>'10526'})
arr.push({:uid=>'1096', :code=>'10546', :name=>'宮本 えり子', :pass=>'10546'})
arr.push({:uid=>'1104', :code=>'561', :name=>'大林 充', :pass=>'561'})
arr.push({:uid=>'1134', :code=>'3336', :name=>'三浦 正寛', :pass=>'3336'})
arr.push({:uid=>'1137', :code=>'4158', :name=>'奥田 慎', :pass=>'4158'})
arr.push({:uid=>'1138', :code=>'10609', :name=>'人見 克吉', :pass=>'10609'})
arr.push({:uid=>'1148', :code=>'10653', :name=>'杉田 鶴夫', :pass=>'10653'})
arr.push({:uid=>'1149', :code=>'10657', :name=>'白倉 弘', :pass=>'10657'})
arr.push({:uid=>'1150', :code=>'10656', :name=>'成島 守', :pass=>'10656'})
arr.push({:uid=>'1168', :code=>'4366', :name=>'木本 真也', :pass=>'4366'})
arr.push({:uid=>'1177', :code=>'4387', :name=>'原 桂太', :pass=>'4387'})
arr.push({:uid=>'1212', :code=>'4505', :name=>'渡辺 勇治', :pass=>'4505'})
arr.push({:uid=>'1226', :code=>'4513', :name=>'岡田 祐子', :pass=>'4513'})
arr.push({:uid=>'1231', :code=>'10952', :name=>'猪俣 利昭', :pass=>'10952'})
arr.push({:uid=>'1259', :code=>'4665', :name=>'森 正孝', :pass=>'4665'})
arr.push({:uid=>'1260', :code=>'4668', :name=>'小島 正義', :pass=>'4668'})
arr.push({:uid=>'1295', :code=>'4616', :name=>'飛弾 佐知子', :pass=>'4616'})
arr.push({:uid=>'1296', :code=>'4567', :name=>'武松 学', :pass=>'4567'})
arr.push({:uid=>'1305', :code=>'11056', :name=>'須賀 京子', :pass=>'11056'})
arr.push({:uid=>'1315', :code=>'11071', :name=>'高橋 勲', :pass=>'11071'})
arr.push({:uid=>'1325', :code=>'11086', :name=>'藤森 美香', :pass=>'11086'})
arr.push({:uid=>'1331', :code=>'4711', :name=>'関根 江美', :pass=>'4711'})
arr.push({:uid=>'1339', :code=>'9950', :name=>'千葉 淳子', :pass=>'9950'})
arr.push({:uid=>'1355', :code=>'11201', :name=>'竹内　順子', :pass=>'11201'})
arr.push({:uid=>'1389', :code=>'4794', :name=>'野見山　葉子', :pass=>'4794'})
arr.push({:uid=>'1412', :code=>'4743', :name=>'葛貫　隆広', :pass=>'4743'})
arr.push({:uid=>'1420', :code=>'10006', :name=>'正野　晶治', :pass=>'10006'})
arr.push({:uid=>'1428', :code=>'11343', :name=>'佐藤　文江', :pass=>'11343'})
arr.push({:uid=>'1432', :code=>'4869', :name=>'高橋 文和', :pass=>'04869'})
arr.push({:uid=>'1456', :code=>'10386', :name=>'中澤　一弘', :pass=>'gfgdf'})
arr.push({:uid=>'1462', :code=>'10787', :name=>'秋田　稔', :pass=>'fjsfgs'})
arr.push({:uid=>'1475', :code=>'11406', :name=>'須藤　静子', :pass=>'11406'})
arr.push({:uid=>'1495', :code=>'4770', :name=>'山崎 雅洋', :pass=>'4770'})
arr.push({:uid=>'1509', :code=>'11495', :name=>'羽賀　由香里', :pass=>'5726'})
arr.push({:uid=>'1526', :code=>'4923', :name=>'山口　さとみ', :pass=>'4923'})
arr.push({:uid=>'1527', :code=>'4917', :name=>'市橋　弘如', :pass=>'4917'})
arr.push({:uid=>'1585', :code=>'5030', :name=>'齋藤　紘子', :pass=>'5030'})
arr.push({:uid=>'1586', :code=>'5038', :name=>'村田　沙織', :pass=>'5038'})
arr.push({:uid=>'1587', :code=>'5045', :name=>'武井　佳菜', :pass=>'5045'})
arr.push({:uid=>'1588', :code=>'5064', :name=>'木下　幸一', :pass=>'5064'})
arr.push({:uid=>'1589', :code=>'5070', :name=>'佐々木　城光', :pass=>'5070'})
arr.push({:uid=>'1590', :code=>'5110', :name=>'若山　愛', :pass=>'5110'})
arr.push({:uid=>'1605', :code=>'5134', :name=>'井上　明裕', :pass=>'5134'})
arr.push({:uid=>'1610', :code=>'11667', :name=>'林　沙織', :pass=>'11667'})
arr.push({:uid=>'1632', :code=>'5171', :name=>'濱田　恵津子', :pass=>'05171'})
arr.push({:uid=>'1640', :code=>'11733', :name=>'吉原　不二雄', :pass=>'11733'})
arr.push({:uid=>'1641', :code=>'11734', :name=>'ニノ方　信春', :pass=>'11734'})
arr.push({:uid=>'215', :code=>'2361', :name=>'檜森 千里', :pass=>'2361'})
arr.push({:uid=>'225', :code=>'3225', :name=>'大貫 邦夫', :pass=>'3225'})
arr.push({:uid=>'861', :code=>'3584', :name=>'倉部 幸夫', :pass=>'3584'})
arr.push({:uid=>'1050', :code=>'4136', :name=>'布留川 高士', :pass=>'4136'})
arr.push({:uid=>'1230', :code=>'10951', :name=>'八鍬 明美', :pass=>'10951'})
arr.push({:uid=>'1293', :code=>'4612', :name=>'田中 千恵子', :pass=>'4612'})
arr.push({:uid=>'1297', :code=>'4671', :name=>'大橋 泰之', :pass=>'0325'})
arr.push({:uid=>'1506', :code=>'4904', :name=>'郷　隆史', :pass=>'04904'})
arr.push({:uid=>'1513', :code=>'11499', :name=>'及川　政子', :pass=>'11499'})
arr.push({:uid=>'1660', :code=>'28', :name=>'佐藤 公義', :pass=>'28'})
arr.push({:uid=>'1661', :code=>'735', :name=>'磯谷 長男', :pass=>'735'})
arr.push({:uid=>'1662', :code=>'892', :name=>'細野 隆', :pass=>'892'})
arr.push({:uid=>'1663', :code=>'1003', :name=>'弓田 兼二', :pass=>'1003'})
arr.push({:uid=>'1665', :code=>'1571', :name=>'鳥海 智', :pass=>'1571'})
arr.push({:uid=>'1666', :code=>'1572', :name=>'前原 英樹', :pass=>'1572'})
arr.push({:uid=>'1667', :code=>'1731', :name=>'篠 由美子', :pass=>'1731'})
arr.push({:uid=>'1668', :code=>'1962', :name=>'山本 博', :pass=>'1962'})
arr.push({:uid=>'1669', :code=>'3764', :name=>'飯村 隆志', :pass=>'3764'})
arr.push({:uid=>'1670', :code=>'3906', :name=>'小澤 浩明', :pass=>'3906'})
arr.push({:uid=>'1671', :code=>'8425', :name=>'蓼沼 志津子', :pass=>'8425'})
arr.push({:uid=>'1672', :code=>'8649', :name=>'隅田 和子', :pass=>'8649'})
arr.push({:uid=>'1673', :code=>'8834', :name=>'渡辺 保子', :pass=>'8834'})
arr.push({:uid=>'1674', :code=>'9194', :name=>'福原 京子', :pass=>'9194'})
arr.push({:uid=>'1675', :code=>'2140', :name=>'木下 義雄', :pass=>'2140'})
arr.push({:uid=>'1676', :code=>'8584', :name=>'柿沼 智子', :pass=>'8584'})
arr.push({:uid=>'126', :code=>'2850', :name=>'遠藤 一成', :pass=>'2850'})
arr.push({:uid=>'1680', :code=>'11777', :name=>'若山　貞之', :pass=>'11777'})
arr.push({:uid=>'1705', :code=>'5218', :name=>'澤頭　淳一', :pass=>'5218'})
arr.push({:uid=>'1711', :code=>'5219', :name=>'土橋　奈都恵', :pass=>'5219'})
arr.push({:uid=>'1719', :code=>'5466', :name=>'小野塚　亮', :pass=>'05466'})
arr.push({:uid=>'1721', :code=>'5225', :name=>'板坂　史子', :pass=>'5225'})
arr.push({:uid=>'1729', :code=>'5337', :name=>'亀山　景子', :pass=>'5337'})
arr.push({:uid=>'1758', :code=>'5313', :name=>'宮川　雄介', :pass=>'5313'})
arr.push({:uid=>'218', :code=>'9085', :name=>'當摩 勝代', :pass=>'9085'})
arr.push({:uid=>'1763', :code=>'11882', :name=>'熊谷　恵美子', :pass=>'11882'})
arr.push({:uid=>'1764', :code=>'11672', :name=>'森谷　紘子', :pass=>'11672'})
arr.push({:uid=>'1765', :code=>'5442', :name=>'谷澤　寿明', :pass=>'005442'})
arr.push({:uid=>'829', :code=>'3843', :name=>'水野 富美子', :pass=>'3843'})
arr.push({:uid=>'744', :code=>'3695', :name=>'浅井 荘平', :pass=>'3695'})
arr.push({:uid=>'946', :code=>'3943', :name=>'黒井 友徳', :pass=>'3943'})
arr.push({:uid=>'234', :code=>'3458', :name=>'伊藤 和也', :pass=>'3458'})
arr.push({:uid=>'1258', :code=>'4664', :name=>'柿沼 薫', :pass=>'4664'})
arr.push({:uid=>'199', :code=>'2844', :name=>'伊藤 智哉', :pass=>'2844'})
arr.push({:uid=>'1618', :code=>'4861', :name=>'石井　秀治', :pass=>'4861'})
arr.push({:uid=>'1045', :code=>'4160', :name=>'小田原 裕', :pass=>'4160'})
arr.push({:uid=>'751', :code=>'3739', :name=>'堀井 芳美', :pass=>'3739'})
arr.push({:uid=>'768', :code=>'3747', :name=>'鈴木 博之', :pass=>'6772'})
arr.push({:uid=>'1774', :code=>'11968', :name=>'臼井　香織', :pass=>'11968'})
arr.push({:uid=>'1781', :code=>'5452', :name=>'梅沢 佑介', :pass=>'5452'})
arr.push({:uid=>'1814', :code=>'5473', :name=>'小泉 真二', :pass=>'5473'})
arr.push({:uid=>'1824', :code=>'5477', :name=>'五十嵐　一也', :pass=>'5477'})
arr.push({:uid=>'1841', :code=>'5489', :name=>'熊谷　隆之', :pass=>'5489'})
arr.push({:uid=>'1848', :code=>'12117', :name=>'金澤　辰典', :pass=>'12117'})
arr.push({:uid=>'1849', :code=>'5497', :name=>'村井　弘明', :pass=>'5497'})
arr.push({:uid=>'1858', :code=>'5508', :name=>'藤田　哲広', :pass=>'5508'})
arr.push({:uid=>'1861', :code=>'5684', :name=>'帰山　孝夫', :pass=>'5684'})
arr.push({:uid=>'1865', :code=>'5648', :name=>'茂田　司※', :pass=>'hgkjl'})
arr.push({:uid=>'1886', :code=>'5615', :name=>'須田　涼子', :pass=>'5615'})
arr.push({:uid=>'1900', :code=>'5603', :name=>'有坂　由紀', :pass=>'5603'})
arr.push({:uid=>'1901', :code=>'5608', :name=>'小野　めぐみ', :pass=>'5608'})
arr.push({:uid=>'1902', :code=>'5611', :name=>'近藤　沙樹', :pass=>'5611'})
arr.push({:uid=>'1906', :code=>'5638', :name=>'緒方　翔太郎', :pass=>'5638'})
arr.push({:uid=>'1909', :code=>'5656', :name=>'高頭　健太', :pass=>'5656'})
arr.push({:uid=>'213', :code=>'1742', :name=>'富塚 裕', :pass=>'1742'})
arr.push({:uid=>'1921', :code=>'12219', :name=>'中村　奈美子', :pass=>'12219'})
arr.push({:uid=>'1923', :code=>'12101', :name=>'佐渡　俊子', :pass=>'12101'})
arr.push({:uid=>'1946', :code=>'5726', :name=>'押田　健一', :pass=>'5726'})
arr.push({:uid=>'1948', :code=>'5728', :name=>'鈴木　靖人', :pass=>'5728'})
arr.push({:uid=>'1949', :code=>'5729', :name=>'松原　一男', :pass=>'5729'})
arr.push({:uid=>'1958', :code=>'12256', :name=>'小泉　千鶴', :pass=>'12256'})
arr.push({:uid=>'1959', :code=>'12310', :name=>'髙武　理奈', :pass=>'12310'})
arr.push({:uid=>'1960', :code=>'12319', :name=>'髙橋　はるみ', :pass=>'12319'})
arr.push({:uid=>'1961', :code=>'5732', :name=>'高見澤　哲', :pass=>'5732'})
arr.push({:uid=>'1969', :code=>'5737', :name=>'堀切　広美', :pass=>'1357'})
arr.push({:uid=>'1971', :code=>'12331', :name=>'岩田　万里子', :pass=>'12331'})
arr.push({:uid=>'1978', :code=>'5870', :name=>'松岡　和孝', :pass=>'5870'})
arr.push({:uid=>'1992', :code=>'5858', :name=>'岩元　彩夏', :pass=>'0000'})
arr.push({:uid=>'1994', :code=>'5866', :name=>'本田　彩', :pass=>'5866'})
arr.push({:uid=>'2006', :code=>'5807', :name=>'吉満　直紀', :pass=>'5807'})
arr.push({:uid=>'2011', :code=>'5848', :name=>'東野　大', :pass=>'5848'})
arr.push({:uid=>'2012', :code=>'5817', :name=>'戸枝　麻衣', :pass=>'5817'})
arr.push({:uid=>'2014', :code=>'5769', :name=>'島田　康弘', :pass=>'5769'})
arr.push({:uid=>'2015', :code=>'5841', :name=>'下地　優樹', :pass=>'5841'})
arr.push({:uid=>'2016', :code=>'5767', :name=>'佐藤　輝', :pass=>'5767'})
arr.push({:uid=>'2018', :code=>'5825', :name=>'吉岡　麻美', :pass=>'5825'})
arr.push({:uid=>'2020', :code=>'5813', :name=>'小池　優莉香', :pass=>'5813'})
arr.push({:uid=>'2023', :code=>'12385', :name=>'奥山　孝三', :pass=>'12385'})
arr.push({:uid=>'2025', :code=>'12309', :name=>'片山　三郎', :pass=>'12309'})
arr.push({:uid=>'2034', :code=>'12420', :name=>'渡辺　洋子', :pass=>'12420'})
arr.push({:uid=>'2037', :code=>'12434', :name=>'國廣　真貴', :pass=>'12434'})
arr.push({:uid=>'1386', :code=>'11241', :name=>'戸田　冨喜子', :pass=>'11241'})
arr.push({:uid=>'2045', :code=>'12452', :name=>'坂巻 サチ子', :pass=>'12452'})
arr.push({:uid=>'2046', :code=>'12448', :name=>'山﨑　勝紀', :pass=>'12448'})
arr.push({:uid=>'2048', :code=>'12447', :name=>'利根川　清己', :pass=>'12447'})
arr.push({:uid=>'2050', :code=>'5891', :name=>'角田　和則', :pass=>'5891'})
arr.push({:uid=>'2061', :code=>'5901', :name=>'小村　秀明', :pass=>'5901'})
arr.push({:uid=>'2066', :code=>'5518', :name=>'齋藤　慎吾', :pass=>'5518'})
arr.push({:uid=>'2068', :code=>'12156', :name=>'佐久間　美和', :pass=>'12156'})
arr.push({:uid=>'2085', :code=>'5915', :name=>'山屋　典亮', :pass=>'5915'})
arr.push({:uid=>'2098', :code=>'12210', :name=>'清野　和泉', :pass=>'12210'})
arr.push({:uid=>'2099', :code=>'11664', :name=>'山本　静雄', :pass=>'11664'})
arr.push({:uid=>'2103', :code=>'12136', :name=>'若生　真美', :pass=>'12136'})
arr.push({:uid=>'2133', :code=>'12570', :name=>'小川　綾子', :pass=>'12570'})
arr.push({:uid=>'1445', :code=>'9639', :name=>'阿部　利枝', :pass=>'cgfngh'})
arr.push({:uid=>'1449', :code=>'9801', :name=>'近藤　静代', :pass=>'sdggsd'})
arr.push({:uid=>'1448', :code=>'10678', :name=>'西尾　淳一', :pass=>'fjfdfh'})
arr.push({:uid=>'2134', :code=>'6025', :name=>'赤嶺 達己', :pass=>'6025'})
arr.push({:uid=>'2135', :code=>'6103', :name=>'伊藤 晃基', :pass=>'6103'})
arr.push({:uid=>'2136', :code=>'6089', :name=>'渡辺 将洋', :pass=>'6089'})
arr.push({:uid=>'2139', :code=>'6111', :name=>'菊川 翔太※', :pass=>'58333'})
arr.push({:uid=>'2140', :code=>'6095', :name=>'栗田 直美', :pass=>'6095'})
arr.push({:uid=>'2141', :code=>'6130', :name=>'藤本 一樹', :pass=>'6130'})
arr.push({:uid=>'2143', :code=>'6136', :name=>'吉原 優作', :pass=>'6136'})
arr.push({:uid=>'2144', :code=>'5929', :name=>'品川 知仁', :pass=>'5929'})
arr.push({:uid=>'2145', :code=>'6102', :name=>'山﨑 祥美', :pass=>'6102'})
arr.push({:uid=>'2146', :code=>'12579', :name=>'菅原　裕子', :pass=>'12579'})
arr.push({:uid=>'2149', :code=>'5928', :name=>'柴田 貴史', :pass=>'1696'})
arr.push({:uid=>'2153', :code=>'12593', :name=>'及川　知美', :pass=>'12593'})
arr.push({:uid=>'2157', :code=>'5470', :name=>'中村　裕美', :pass=>'5470'})
arr.push({:uid=>'2158', :code=>'13946', :name=>'石井　博行', :pass=>'13946'})
arr.push({:uid=>'2159', :code=>'2036', :name=>'宮澤　武史', :pass=>'2036'})
arr.push({:uid=>'2163', :code=>'12624', :name=>'石﨑　順子', :pass=>'12624'})
arr.push({:uid=>'2169', :code=>'12629', :name=>'吉冨　眞木丸', :pass=>'12629'})
arr.push({:uid=>'2171', :code=>'12631', :name=>'田村　治夫', :pass=>'12631'})
arr.push({:uid=>'2172', :code=>'12642', :name=>'森本　洋子', :pass=>'12642'})
arr.push({:uid=>'2173', :code=>'12647', :name=>'片柳　豊太郎', :pass=>'12647'})
arr.push({:uid=>'2179', :code=>'5952', :name=>'山口 英一', :pass=>'5952'})
arr.push({:uid=>'2181', :code=>'12689', :name=>'古味　広朗', :pass=>'12689'})
arr.push({:uid=>'2191', :code=>'12710', :name=>'石塚　亮太', :pass=>'12710'})
arr.push({:uid=>'2210', :code=>'12836', :name=>'大城戸　義彦', :pass=>'12836'})
arr.push({:uid=>'2211', :code=>'12837', :name=>'野澤　由香', :pass=>'12837'})
arr.push({:uid=>'2241', :code=>'12863', :name=>'福徳　貴子', :pass=>'12863'})
arr.push({:uid=>'2242', :code=>'12873', :name=>'佐藤　栄子', :pass=>'12873'})
arr.push({:uid=>'809', :code=>'9637', :name=>'宮林 美由紀', :pass=>'5324'})
arr.push({:uid=>'2261', :code=>'5896', :name=>'宮下　直寿', :pass=>'5896'})
arr.push({:uid=>'2262', :code=>'5999', :name=>'笠原　高史', :pass=>'5999'})
arr.push({:uid=>'2266', :code=>'12928', :name=>'百瀬　結希', :pass=>'12928'})
arr.push({:uid=>'2268', :code=>'6324', :name=>'濱島　千鶴', :pass=>'6324'})
arr.push({:uid=>'2274', :code=>'12930', :name=>'池田　真紀子', :pass=>'12930'})
arr.push({:uid=>'2276', :code=>'12955', :name=>'中村　真利子', :pass=>'12955'})
arr.push({:uid=>'2280', :code=>'12956', :name=>'奈良　美香', :pass=>'12956'})
arr.push({:uid=>'2283', :code=>'12984', :name=>'石津　奈美', :pass=>'012984'})
arr.push({:uid=>'2285', :code=>'12987', :name=>'吉村　美香', :pass=>'12987'})
arr.push({:uid=>'2291', :code=>'13003', :name=>'飯田　佳織', :pass=>'13003'})
arr.push({:uid=>'2294', :code=>'13019', :name=>'添田　亜美', :pass=>'13019'})
arr.push({:uid=>'2297', :code=>'13024', :name=>'杉浦　久美', :pass=>'13024'})
arr.push({:uid=>'2300', :code=>'13037', :name=>'田島　久平', :pass=>'hjhhj'})
arr.push({:uid=>'2302', :code=>'91085', :name=>'久慈　智子', :pass=>'91085'})
arr.push({:uid=>'2306', :code=>'91098', :name=>'小内　智恵', :pass=>'91098'})
arr.push({:uid=>'2307', :code=>'6338', :name=>'鈴木　周介', :pass=>'6338'})
arr.push({:uid=>'2327', :code=>'13085', :name=>'高橋　茂', :pass=>'13085'})
arr.push({:uid=>'2330', :code=>'13118', :name=>'外山　幸子', :pass=>'13118'})
arr.push({:uid=>'2331', :code=>'13117', :name=>'吉井　功', :pass=>'13117'})
arr.push({:uid=>'2332', :code=>'99999', :name=>'管理者', :pass=>'99999'})
arr.push({:uid=>'2336', :code=>'6346', :name=>'照屋　秀一郎', :pass=>'6346'})
arr.push({:uid=>'2337', :code=>'2808', :name=>'田村　裕一', :pass=>'10102'})
arr.push({:uid=>'2340', :code=>'6356', :name=>'三ヶ原 隆史', :pass=>'6356'})
arr.push({:uid=>'2373', :code=>'6825', :name=>'秋元　清流', :pass=>'6825'})
arr.push({:uid=>'2378', :code=>'6365', :name=>'松本 貴之', :pass=>'6365'})
arr.push({:uid=>'2387', :code=>'13225', :name=>'和田　泉', :pass=>'13225'})
arr.push({:uid=>'2390', :code=>'6370', :name=>'村岡 佑亮', :pass=>'6370'})
arr.push({:uid=>'2392', :code=>'6371', :name=>'羽成 隆之', :pass=>'6371'})
arr.push({:uid=>'2393', :code=>'13255', :name=>'関口　幸子', :pass=>'13255'})
arr.push({:uid=>'2394', :code=>'6375', :name=>'菅原 信弘', :pass=>'6375'})
arr.push({:uid=>'2395', :code=>'13263', :name=>'井桁 朋子', :pass=>'13263'})
arr.push({:uid=>'2396', :code=>'6376', :name=>'杉山　直樹', :pass=>'6376'})
arr.push({:uid=>'2399', :code=>'13326', :name=>'中野　彩香 ※', :pass=>'13326'})
arr.push({:uid=>'2400', :code=>'13327', :name=>'大﨑　三蔵', :pass=>'13327'})
arr.push({:uid=>'2406', :code=>'13339', :name=>'中井　礼子', :pass=>'13339'})
arr.push({:uid=>'2409', :code=>'13352', :name=>'田野辺　実', :pass=>'13352'})
arr.push({:uid=>'2411', :code=>'6386', :name=>'宮川　幸子', :pass=>'6386'})
arr.push({:uid=>'2417', :code=>'6380', :name=>'今村　聰', :pass=>'6380'})
arr.push({:uid=>'2425', :code=>'13385', :name=>'早田　由美子', :pass=>'13385'})
arr.push({:uid=>'2426', :code=>'6395', :name=>'長濱 鋼志', :pass=>'6395'})
arr.push({:uid=>'2427', :code=>'6407', :name=>'小柳 裕之', :pass=>'6407'})
arr.push({:uid=>'2428', :code=>'6406', :name=>'末吉　将之', :pass=>'6406'})
arr.push({:uid=>'2436', :code=>'13428', :name=>'小林　新二', :pass=>'13428'})
arr.push({:uid=>'2438', :code=>'13436', :name=>'長谷川　由美子', :pass=>'013436'})
arr.push({:uid=>'2439', :code=>'6412', :name=>'菱沼 涼子', :pass=>'6412'})
arr.push({:uid=>'2444', :code=>'13444', :name=>'宮内　千恵', :pass=>'13444'})
arr.push({:uid=>'2445', :code=>'13445', :name=>'河上　昌司', :pass=>'13445'})
arr.push({:uid=>'2453', :code=>'6418', :name=>'松倉　弘道', :pass=>'6418'})
arr.push({:uid=>'2454', :code=>'13458', :name=>'松本 裕美', :pass=>'13458'})
arr.push({:uid=>'2472', :code=>'6426', :name=>'吉川　正春', :pass=>'06426'})
arr.push({:uid=>'2473', :code=>'6425', :name=>'赤坂　裕貴', :pass=>'06425'})
arr.push({:uid=>'2481', :code=>'13514', :name=>'羽石　容子', :pass=>'13514'})
arr.push({:uid=>'2482', :code=>'13515', :name=>'服部　眞砂子', :pass=>'13515'})
arr.push({:uid=>'2484', :code=>'6436', :name=>'松沢 恭子', :pass=>'6436'})
arr.push({:uid=>'2485', :code=>'6452', :name=>'木下 想子', :pass=>'6452'})
arr.push({:uid=>'2486', :code=>'6453', :name=>'伊藤 淳貴', :pass=>'6453'})
arr.push({:uid=>'2513', :code=>'7811', :name=>'池ノ谷　宙', :pass=>'7811'})
arr.push({:uid=>'2514', :code=>'7815', :name=>'上田　琢', :pass=>'7815'})
arr.push({:uid=>'2515', :code=>'7844', :name=>'辻　正弘', :pass=>'7844'})
arr.push({:uid=>'2516', :code=>'7883', :name=>'井上　正大', :pass=>'7883'})
arr.push({:uid=>'2517', :code=>'7885', :name=>'金子　尚', :pass=>'7885'})
arr.push({:uid=>'2518', :code=>'7893', :name=>'坂元　透威', :pass=>'7893'})
arr.push({:uid=>'2519', :code=>'7897', :name=>'鈴木　駿太', :pass=>'7897'})
arr.push({:uid=>'2520', :code=>'7904', :name=>'橋本　拓也', :pass=>'7904'})
arr.push({:uid=>'2523', :code=>'13583', :name=>'中越　由美子', :pass=>'13583'})
arr.push({:uid=>'2524', :code=>'13584', :name=>'藤原 亜希子', :pass=>'13584'})
arr.push({:uid=>'2531', :code=>'6461', :name=>'中野 雄一', :pass=>'6461'})
arr.push({:uid=>'2533', :code=>'6464', :name=>'猪原 勇太', :pass=>'6464'})
arr.push({:uid=>'2534', :code=>'6469', :name=>'中野　彩香', :pass=>'6469'})
arr.push({:uid=>'2539', :code=>'13654', :name=>'藤本　有香', :pass=>'13654'})
arr.push({:uid=>'2542', :code=>'13664', :name=>'酒井　美和', :pass=>'13664'})
arr.push({:uid=>'2543', :code=>'13679', :name=>'田中 真理子', :pass=>'13679'})
arr.push({:uid=>'2544', :code=>'13684', :name=>'蓮実 菊江', :pass=>'13684'})
arr.push({:uid=>'2547', :code=>'6487', :name=>'氏家 雄輔', :pass=>'6487'})
arr.push({:uid=>'2548', :code=>'6488', :name=>'大浦 光', :pass=>'6488'})
arr.push({:uid=>'2559', :code=>'13750', :name=>'草野　なお子', :pass=>'13750'})
arr.push({:uid=>'2560', :code=>'13751', :name=>'高橋　清子', :pass=>'13751'})
arr.push({:uid=>'2564', :code=>'13763', :name=>'木村　美樹', :pass=>'7522'})
arr.push({:uid=>'2566', :code=>'13783', :name=>'林　身江子', :pass=>'13783'})
arr.push({:uid=>'2573', :code=>'6893', :name=>'鎌田　千子', :pass=>'6893'})
arr.push({:uid=>'2574', :code=>'2440', :name=>'加藤　美和', :pass=>'031000'})
arr.push({:uid=>'2575', :code=>'91632', :name=>'池原 千代', :pass=>'91632'})
arr.push({:uid=>'2582', :code=>'7507', :name=>'山口 茂', :pass=>'7507'})
arr.push({:uid=>'2583', :code=>'13823', :name=>'香山　美恵', :pass=>'13823'})
arr.push({:uid=>'2584', :code=>'6900', :name=>'山﨑　香穂里', :pass=>'6900'})
arr.push({:uid=>'2585', :code=>'6905', :name=>'石田　耕平', :pass=>'6905'})
arr.push({:uid=>'2586', :code=>'6907', :name=>'成嶋　文隆', :pass=>'6907'})
arr.push({:uid=>'2587', :code=>'6906', :name=>'杉沢　修一', :pass=>'6906'})
arr.push({:uid=>'2588', :code=>'6901', :name=>'河上　昌司', :pass=>'6901'})
arr.push({:uid=>'2590', :code=>'13822', :name=>'荒川　康子', :pass=>'13822'})
arr.push({:uid=>'2591', :code=>'13842', :name=>'織戸 博美', :pass=>'13842'})
arr.push({:uid=>'2592', :code=>'13840', :name=>'若倉　明日香', :pass=>'13840'})
arr.push({:uid=>'2593', :code=>'5355', :name=>'松本 千晶', :pass=>'5355'})
arr.push({:uid=>'2594', :code=>'1644', :name=>'安藤 真由美', :pass=>'940226'})
arr.push({:uid=>'2596', :code=>'91680', :name=>'阿部　直樹', :pass=>'91680'})
arr.push({:uid=>'2597', :code=>'905817', :name=>'家村　麻衣', :pass=>'15878'})
arr.push({:uid=>'2598', :code=>'6915', :name=>'岩田　圭司', :pass=>'6915'})
arr.push({:uid=>'2614', :code=>'13884', :name=>'渡辺　理江', :pass=>'13884'})
arr.push({:uid=>'2615', :code=>'13894', :name=>'佐藤　淑恵', :pass=>'13894'})
arr.push({:uid=>'2616', :code=>'6920', :name=>'黒畑　尚希', :pass=>'6920'})
arr.push({:uid=>'2617', :code=>'6921', :name=>'種村 香世', :pass=>'6921'})
arr.push({:uid=>'2623', :code=>'6925', :name=>'金子　健二', :pass=>'6925'})
arr.push({:uid=>'2624', :code=>'91743', :name=>'須藤　まゆの', :pass=>'38071'})
arr.push({:uid=>'2626', :code=>'13933', :name=>'大橋　輝美', :pass=>'013933'})
arr.push({:uid=>'2627', :code=>'13934', :name=>'近藤　信義', :pass=>'13934'})
arr.push({:uid=>'2631', :code=>'20163', :name=>'針谷 真衣', :pass=>'20163'})
arr.push({:uid=>'2632', :code=>'20166', :name=>'日下部 麻尋', :pass=>'20166'})
arr.push({:uid=>'2633', :code=>'13971', :name=>'槐　時男', :pass=>'13971'})
arr.push({:uid=>'2636', :code=>'20018', :name=>'小野 正也', :pass=>'020018'})
arr.push({:uid=>'2677', :code=>'20174', :name=>'矢作　歩美', :pass=>'20174'})
arr.push({:uid=>'2663', :code=>'20015', :name=>'小川　恭平', :pass=>'20015'})
arr.push({:uid=>'2665', :code=>'20054', :name=>'堀金　嗣', :pass=>'20054'})
arr.push({:uid=>'2667', :code=>'20069', :name=>'渡辺　達郎', :pass=>'20069'})
arr.push({:uid=>'2668', :code=>'20075', :name=>'小見　郁未', :pass=>'20075'})
arr.push({:uid=>'2669', :code=>'20076', :name=>'金児　真菜未', :pass=>'20076'})
arr.push({:uid=>'2670', :code=>'20087', :name=>'榎本　良介', :pass=>'20087'})
arr.push({:uid=>'2671', :code=>'20091', :name=>'小笠原　寿満', :pass=>'20091'})
arr.push({:uid=>'2672', :code=>'20100', :name=>'岸川　真希', :pass=>'20100'})
arr.push({:uid=>'2673', :code=>'20115', :name=>'花岡　優', :pass=>'20115'})
arr.push({:uid=>'2674', :code=>'20125', :name=>'三塚　和樹', :pass=>'20125'})
arr.push({:uid=>'2676', :code=>'13984', :name=>'中川　芳雄', :pass=>'13984'})
arr.push({:uid=>'2679', :code=>'13992', :name=>'坂巻　久仁子', :pass=>'13992'})
arr.push({:uid=>'2680', :code=>'13994', :name=>'近藤 加奈子', :pass=>'13994'})
arr.push({:uid=>'2685', :code=>'20188', :name=>'遠藤　沙代', :pass=>'20188'})
arr.push({:uid=>'2686', :code=>'14030', :name=>'風間　恭子', :pass=>'14030'})
arr.push({:uid=>'2687', :code=>'14037', :name=>'小山　かおり', :pass=>'14037'})
arr.push({:uid=>'2688', :code=>'20190', :name=>'和田　洋子', :pass=>'20190'})
arr.push({:uid=>'2695', :code=>'20197', :name=>'毛利　勇介', :pass=>'20197'})
arr.push({:uid=>'2697', :code=>'14090', :name=>'松﨑 七実', :pass=>'14090'})
arr.push({:uid=>'2698', :code=>'14119', :name=>'千葉 由美', :pass=>'14119'})
arr.push({:uid=>'2699', :code=>'20203', :name=>'北条 純子', :pass=>'20203'})
arr.push({:uid=>'2700', :code=>'20210', :name=>'小関　直人', :pass=>'20210'})
arr.push({:uid=>'2701', :code=>'14131', :name=>'石井　光江', :pass=>'14131'})
arr.push({:uid=>'2702', :code=>'14132', :name=>'加藤 佐和子', :pass=>'14132'})
arr.push({:uid=>'2703', :code=>'14138', :name=>'渡辺 春美', :pass=>'14138'})
arr.push({:uid=>'2704', :code=>'14139', :name=>'田中 美代子', :pass=>'14139'})
arr.push({:uid=>'2706', :code=>'14157', :name=>'髙林 郁子', :pass=>'14157'})
arr.push({:uid=>'2707', :code=>'14158', :name=>'芦沢　しのぶ', :pass=>'14158'})
arr.push({:uid=>'2708', :code=>'20216', :name=>'松島　朱里', :pass=>'20216'})
arr.push({:uid=>'2709', :code=>'20217', :name=>'南　智博', :pass=>'20217'})
arr.push({:uid=>'2710', :code=>'20218', :name=>'石田　憲康', :pass=>'20218'})
arr.push({:uid=>'2717', :code=>'20223', :name=>'間下　裕子', :pass=>'20223'})
arr.push({:uid=>'2718', :code=>'14172', :name=>'長江　哲也', :pass=>'75239'})

  arr.each do |obj|
    biru_user = BiruUser.find_or_create_by_code(obj[:code])
    biru_user.code = obj[:code]
    biru_user.name = obj[:name]
    biru_user.password = obj[:pass]
    biru_user.syain_id = obj[:uid]
    biru_user.save!
    p biru_user.name
  end

end


# 物件種別
def convert_biru_type(num)
  build_type = BuildType.find_by_code(num)
  if build_type
    return build_type.id
  else
    return nil
  end
end

# 店タイプ
def convert_shop(num)
  shop = Shop.find_by_code(num)
  if shop
    return shop.id
  else
    nil
  end

end

# geocoding
# force:強制的にgeocodingを行う。
def biru_geocode(biru, force)
	msg = ""
  begin
  	
    # 住所が空白のみだったらそもそもgeocodeを行わない
    if biru.address.gsub(" ", "").gsub("　", "").length == 0
      msg = "住所が空白のみなのでスキップ "
      raise # 例外発生させrescueへ飛ばす
    end

    skip_flg = biru.gmaps
    skip_flg = false if force

    unless skip_flg
      gmaps_ret = Gmaps4rails.geocode(biru.address)
      biru.latitude = gmaps_ret[0][:lat]
      biru.longitude = gmaps_ret[0][:lng]
      biru.gmaps = true

#      if biru.code
#        p format("%05d",biru.code) + ':' + biru.name + ':' + biru.address
#      else
#        p format("%05d",biru.attack_code) + ':' + biru.name + ':' + biru.address
#      end
    end
  rescue => e
    if biru.name.nil? or biru.address.nil?
      p e
    else
      p e
    end

	# エラー処理
    biru.gmaps = false
    biru.delete_flg = true
    
  end
  
  return msg
end

# type: 1=自社 2=他社 を初期化します
def before_imp_init(type)

  # 削除フラグをON して自社物の初期化
  if type == 1
    relation_arr = Building.unscoped.where("code is not null")
  else
    relation_arr = Building.unscoped.where("attack_code is not null")
  end

  relation_arr.each do|biru|

    # 部屋の初期化
    biru.rooms.each do |room|
      room.delete_flg = true
      room.save!
    end

    # 貸主の初期化
    biru.owners.each do |owner|
      owner.delete_flg = true
      owner.save!
    end

    # 管理委託契約CDの初期化
    biru.trusts.each do |trust|
      trust.delete_flg = true
      trust.save!
    end

    biru.delete_flg = true
    biru.save!

  end

end

##########################
# 自社物の登録
##########################
def regist_oneself(filename)

  # バッチコード
  batch_code = "JS" + Time.now.strftime("%Y%m%d%H%M%S")
  
	# 自社データのインポート
  import_data_oneself(filename, batch_code)

	# インポートしたデータのシステム反映
	update_imp_oneself(batch_code)
  
  p "バッチコード：" + batch_code

end

# importデータの読み込み（自社）
def import_data_oneself(filename, batch_code)

  # ファイル存在チェック
  unless File.exist?(filename)
    puts 'file not exist'
    return false
  end

  # imp_tablesを初期化
  #ImpTable.delete_all

  # データを登録
  cnt = 0
  open(filename).each do |line|
    catch :not_header do

      if cnt == 0
        cnt = cnt + 1
        throw :not_header
      end

      cnt = cnt + 1

      row = line.split(",")

      unless row[10]
        throw :not_header
      end

      imp = ImpTable.new
      imp.batch_code = batch_code
      imp.siten_cd = row[0]
      imp.eigyo_order = row[1]
      imp.eigyo_cd = row[2]
      imp.eigyo_nm = row[3]
      imp.manage_type_cd = row[4]
      imp.manage_type_nm = row[5]
      imp.trust_cd = row[6]
      imp.building_cd = row[7]
      imp.building_nm = row[8]
      imp.building_type_cd = row[9]
      imp.building_address = row[10]
      imp.room_cd = row[11]
      imp.room_nm = row[12]
      imp.room_aki = row[15]
      imp.room_type_cd = row[16]
      imp.room_type_nm = row[17]
      imp.room_layout_cd = row[18]
      imp.room_layout_nm = row[19]
      imp.owner_cd = row[20]
      imp.owner_nm = row[21]
      imp.owner_kana = row[22]
      imp.owner_address = row[23]
      imp.build_day = row[24]
      imp.moyori_id = row[25]
      imp.line_cd = row[26]
      imp.line_nm = row[27]
      imp.station_cd = row[28]
      imp.station_nm = row[29]
      imp.bus_exists = row[30]
      imp.minuite = row[31]

      imp.save!

      if imp
        p cnt.to_s + " " + imp.building_nm + " " + imp.room_nm
      else
        p cnt.to_s
      end
    end
  end

end

# データの更新(自社)
def update_imp_oneself(batch_code)

  # 自社物の初期化(削除フラグをON)
  p "■自社情報の初期化（" + Time.now.to_s(:db) + "）"
  before_imp_init(1)
  msg = ""

  ####################
  # 貸主の登録
  ####################
  p "■自社貸主登録（" + Time.now.to_s(:db) + "）"
  ImpTable.where("batch_code = ?", batch_code).group(:owner_cd, :owner_nm, :owner_address ).select(:owner_cd).select(:owner_nm).select(:owner_address).each do |imp|

    owner = Owner.unscoped.find_or_create_by_code(imp.owner_cd)
    owner.code = imp.owner_cd.chomp
    owner.name = imp.owner_nm.chomp
    owner.address = imp.owner_address.chomp
    owner.delete_flg = false

    # 一時対応
    if owner.latitude
      biru_geocode(owner, false)
    else
      biru_geocode(owner, true)
    end

    begin
      owner.save!
      #p owner.name + " " + owner.address.chomp
    rescue => e
      #p "エラー:save " + biru.name + ':' + biru.address
      p "貸主登録エラー:save " + e.message
    end
  end

  ####################
  # 建物・部屋の登録
  ####################
  p "■自社物件登録（" + Time.now.to_s(:db) + "）"
  ImpTable.where("batch_code = ?", batch_code).group(:eigyo_cd, :eigyo_nm, :trust_cd,  :building_cd, :building_nm, :building_address, :owner_cd, :building_type_cd, :room_type_nm, :biru_age, :build_day, :line_cd ,:station_cd ,:moyori_id ,:bus_exists,:minuite ).select(:eigyo_cd).select(:eigyo_nm).select(:trust_cd).select(:building_cd).select(:building_nm).select(:building_address).select(:owner_cd).select(:building_type_cd).select(:room_type_nm).select(:biru_age).select(:build_day).select(:line_cd).select(:station_cd).select(:moyori_id).select(:bus_exists).select(:minuite).each do |imp|

    # 建物の登録
    biru = Building.unscoped.find_or_create_by_code(imp.building_cd)
    biru.code = imp.building_cd.chomp
    biru.name = imp.building_nm.chomp
    biru.address = imp.building_address.chomp
    biru.build_type_id = convert_biru_type(imp.building_type_cd)
    biru.room_num = imp.room_type_nm
    biru.shop_id = convert_shop(imp.eigyo_cd)

	  if imp.build_day
	    biru.build_day = imp.build_day.slice(0..3) + '/' + imp.build_day.slice(4..5) + '/' + imp.build_day.slice(6..7)
	  end
    building_day = custom_parse(biru.build_day)

    # 築年数
    biru.biru_age = nil
    if building_day
      biru.biru_age = ( Date.today - building_day ) / 365
    end

    biru.delete_flg = false

    # 一時対応
    if biru.latitude
	    biru_geocode(biru, false)
    else
	    biru_geocode(biru, true)
    end

    begin
      biru.save!
    rescue =>e
      #p "エラー:save " + biru.name + ':' + biru.address
      p "建物登録エラー:save :" + e.message
    end

    ################
    # 最寄り駅の登録
    ################
    ImpTable.where("batch_code = ?", batch_code).where("building_cd = ?", biru.code ).group(:building_cd, :line_cd, :station_cd, :moyori_id, :bus_exists, :minuite ).select(:building_cd).select(:line_cd).select(:station_cd).select(:moyori_id).select(:bus_exists).select(:minuite).each  do |imp_route|
      # 駅から建物までの位置を登録
      station = Station.find_by_line_code_and_code(imp_route.line_cd, imp_route.station_cd)
      if station

        biru_route = BuildingRoute.find_or_create_by_building_id_and_code(biru.id, imp_route.moyori_id.to_s)
        biru_route.code = imp_route.moyori_id.to_s
        biru_route.building_id = biru.id
        biru_route.station_id = station.id

        if imp_route.bus_exists == 0
          biru_route.bus = false
        else
          biru_route.bus = true
        end

        biru_route.minutes = imp_route.minuite
        biru_route.save!
      end
    end

    ################
    # 部屋の登録
    ################
    kanri_room_num = 0 # 管理戸数
    free_num = 0
    owner_stop_num = 0

#    ImpTable.find_all_by_building_cd(biru.code).each do |imp_room|
    ImpTable.where("batch_code = ?", batch_code).where("building_cd = ?", biru.code ).group(:building_cd, :room_cd, :room_nm, :room_layout_cd, :room_type_cd, :room_aki, :manage_type_cd ).select(:building_cd).select(:room_cd).select(:room_nm).select(:room_layout_cd).select(:room_type_cd).select(:room_aki).select(:manage_type_cd).each  do |imp_room|

      room = Room.unscoped.find_or_create_by_building_cd_and_code(biru.code, imp_room.room_cd)
      room.building = biru
      room.name = imp_room.room_nm
      room.room_layout = RoomLayout.find_by_code(imp_room.room_layout_cd)
      room.room_type = RoomType.find_by_code(imp_room.room_type_cd)
      room.manage_type_id = ManageType.where("code=?", imp_room.manage_type_cd.to_i).first.id

      kanri_room_num = kanri_room_num + 1 # TODO:本来はB管理以上とかが必要かも。管理方式に戸数カウントフラグを持たせてそれで判定させよう。

      # 空き状態の設定
      if imp_room.room_aki.to_i == 2
        room.free_state = true
        free_num = free_num + 1
        p room.building_cd.to_s + ' ' + room.code + ' ' + '空き'
      else
        room.free_state = false
        p room.building_cd.to_s + ' ' + room.code + ' ' + '入居'
      end

      # TODO:オーナー止も取得する。
      room.delete_flg = false
      room.save!

      #p biru.name + ' ' + room.name

    end

    # 部屋の集計値を建物に登録
    biru.kanri_room_num = kanri_room_num
    biru.free_num = free_num
    biru.owner_stop_num = owner_stop_num

    begin
      biru.save!
    rescue =>e
      p "建物登録エラー2:save :" + e.message
    end
  end

  ####################
  # 管理委託契約の登録
  ####################
  p "■委託登録（" + Time.now.to_s(:db) + "）"
  ImpTable.where("batch_code = ?", batch_code).group( :trust_cd, :owner_cd, :building_cd, :manage_type_cd ).select(:trust_cd).select(:owner_cd).select(:building_cd).select(:manage_type_cd).each do |imp|

    trust = Trust.unscoped.find_or_create_by_code(imp.trust_cd)
    biru = Building.where("code=?",imp.building_cd).first
    if biru
      owner = Owner.where("code=?", imp.owner_cd).first
      if owner
        # 建物と貸主が存在している時
        trust.code = imp.trust_cd
        trust.building_id = biru.id
        trust.owner_id = owner.id
        trust.delete_flg = false

        trust.manage_type_id = ManageType.where("code=?", imp.manage_type_cd.to_i).first.id

        trust.save!
        #p trust.code
      end

    end
  end

end


# アタック対象の貸主・物件・委託（ダミー）を登録します。
def import_data_yourself_owner(filename)

  # バッチコード
  batch_code = "TS" + Time.now.strftime("%Y%m%d%H%M%S")
  msg = ""

  # ファイル存在チェック
  unless File.exist?(filename)
    puts 'file not exist'
    return false
  end

  # imp_tablesを初期化
  # ImpTable.delete_all

  # 他社元データを一時表に登録
  cnt = 0
  open(filename).each do |line|
    catch :not_header do

      if cnt == 0
        cnt = cnt + 1
        throw :not_header
      end

      cnt = cnt + 1

      row = line.split(",")

      unless row[9]
        throw :not_header
      end

      imp = ImpTable.new
      imp.batch_code = batch_code
      imp.eigyo_cd = row[0]
      imp.eigyo_nm = row[1]
      imp.building_cd = row[2]
      imp.building_nm = row[3]
      imp.building_address = row[4]
    	imp.build_day = row[6]
    	imp.building_memo = "物件種別：" + row[5] + ", 間取り：" + row[7] + ", 戸数：" + row[8]
      
      imp.owner_cd = row[9]
      imp.owner_nm = row[10]
      imp.owner_postcode = row[12]
      imp.owner_address = row[13]
      imp.owner_tel = row[14]
      imp.owner_honorific_title = row[11]

#      imp.siten_cd = row[0]
#      imp.eigyo_order = row[1]
#      imp.kanri_cd = row[4]
#      imp.kanri_nm = row[5]
#      imp.trust_cd = row[6]
#      imp.room_cd = row[9]
#      imp.room_nm = row[10]
#      imp.kanri_start_date = row[11]
#      imp.kanri_end_date = row[12]
#      imp.room_aki = row[13]
#      imp.room_type_cd = row[14]
#      imp.room_type_nm = row[15]
#      imp.room_layout_cd = row[16]
#      imp.room_layout_nm = row[17]
#      imp.owner_kana = row[20]
      imp.save!

      if imp
        p cnt.to_s + " " + imp.building_nm
      else
        p cnt.to_s
      end
    end
  end

  # 他社の初期化(削除フラグをON)
  before_imp_init(2)
  

  ####################
  # 貸主の登録
  ####################
  ImpTable.where("batch_code = ?", batch_code).group(:owner_cd, :owner_nm, :owner_address, :owner_honorific_title, :owner_postcode, :owner_tel ).select("owner_cd, owner_nm, owner_address, owner_honorific_title, owner_postcode, owner_tel").each do |imp|
  catch :next_owner do

    owner = Owner.unscoped.find_or_create_by_attack_code(imp.owner_cd)
    owner.attack_code = imp.owner_cd
    owner.name = imp.owner_nm
    owner.honorific_title = imp.owner_honorific_title
    owner.postcode = imp.owner_postcode
    owner.address = imp.owner_address
    owner.tel = imp.owner_tel
    
    owner.delete_flg = false
    biru_geocode(owner, false)
    begin
      owner.save!
    rescue
      #p "エラー:save " + biru.name + ':' + biru.address
      p "貸主登録エラー:save "
      throw :next_owner
    end

    ##############
    # 建物
    ##############
    ImpTable.where("batch_code = ?", batch_code).where(:owner_cd=>imp.owner_cd).group(:eigyo_cd, :eigyo_nm, :building_cd, :building_nm, :building_address, :building_type_cd, :building_memo ).select("eigyo_cd, eigyo_nm, building_cd, building_nm, building_address, building_type_cd, building_memo").each do |imp_biru|
    catch :next_building do

      # 建物の登録
      biru = Building.unscoped.find_or_create_by_attack_code(imp_biru.building_cd)
      biru.attack_code = imp_biru.building_cd
      biru.name = imp_biru.building_nm
      biru.memo = imp_biru.building_memo
      biru.delete_flg = false

      biru.build_type_id = convert_biru_type(imp_biru.building_type_cd)
      if biru.build_type_id
        biru.tmp_build_type_icon = biru.build_type.icon
      end

      biru.shop_id = convert_shop(imp_biru.eigyo_cd)
      # biru.room_num = row[13]

      biru.address = imp_biru.building_address
      #biru.gmaps = true
      biru_geocode(biru, false)

      begin
        biru.save!
      rescue =>e
        #p "エラー:save " + biru.name + ':' + biru.address
        p "建物登録エラー:save :" + e.message
        throw :next_owner
      end

      # 管理委託契約を登録
      trust = Trust.unscoped.find_or_create_by_building_id_and_owner_id(biru.id, owner.id)
      
      trust.delete_flg = false
      trust.code = 99999
      trust.manage_type = ManageType.find_by_code(99)
      trust.save!

    end # catch
    end

  end # catch
  end

end

def update_gmap
  Owner.unscoped.each do |owner|
    o_has = Owner.find_by_sql("select * from backup_owners where code = " + owner.code)
    o_has.each do |o_has_one|
      owner.latitude = o_has_one.latitude
      owner.longitude = o_has_one.longitude
      owner.gmaps = true
      owner.save!
    end
  end

  Building.unscoped.each do |biru|
    a_has = Building.find_by_sql("select * from backup_buildings where code = " + biru.code)
    a_has.each do |a_has_one|
      biru.latitude = a_has_one.latitude
      biru.longitude = a_has_one.longitude
      biru.gmaps = true
      biru.save!
    end
  end
end

#update_gmap

#
# # 一括貸主登録を行います。
# # type:0 自社管理対象 1:アタックリスト
# # ▼受け取る項目
# # 0 貸主CD
# # 1 貸主名
# # 2 敬称
# # 3 郵便場号
# # 4 住所
# # 5 電話番号
# def bulk_owner_regist(type, filename)
#
#   # ファイル存在チェック
#   unless File.exist?(filename)
#     puts 'file not exist'
#     return false
#   end
#
#   # imp_tablesを初期化
#   # ImpTable.delete_all
#
#   # 元データを一時表に登録
#   open(filename).each_with_index do |line, cnt|
#     catch :not_header do
#
#       # 1行目は読み飛ばす
#       throw :not_header if cnt == 0
#
#       # 必要項目に満たないものは読み飛ばす
#       row = line.split(",")
#       unless row[5]
#         p cnt.to_s + "行目は項目が足りていないのでスキップ"
#         throw :not_header
#       end
#
#       imp = ImpTable.new
#       imp.owner_type = type
#       imp.owner_cd = row[0]
#       imp.owner_nm = row[1]
#       imp.owner_honorific_title = row[2]
#       imp.owner_postcode = row[3]
#       imp.owner_address = row[4]
#       imp.owner_tel = row[5]
#       imp.save!
#
#       p cnt.to_s + " " + imp.owner_nm
#     end
#   end
#
#
#   # typeによって貸主の登録（同じ貸主CDの人がいたら上書き）
#   ImpTable.where("execute_status = 0").each do |imp|
#
#     # 貸主CDを取得する
#     if type == 0
#       owner = Owner.find_or_create_by_code(imp.owner_cd)
#       owner.code = imp.owner_cd
#     else
#       owner = Owner.find_or_create_by_attack_code(imp.owner_cd)
#       owner.attack_code = imp.owner_cd
#     end
#
#     owner.name = imp.owner_nm
#     owner.honorific_title = imp.owner_honorific_title
#
#
#     owner.name = imp.owner_nm
#     owner.honorific_title = imp.owner_honorific_title
#     owner.postcode = imp.owner_postcode
#     owner.address = imp.owner_address
#     owner.tel = imp.owner_tel
#
#     owner.delete_flg = false
#     biru_geocode(owner, false)
#     begin
#       owner.save!
#       imp.execute_status = 1 #正常終了
#       imp.save!
#     rescue
#       p "貸主登録エラー:save " + owner.name
#       # 登録できなかったらimoprtテーブルへログを書き込み
#       imp.execute_status = 2 # error
#       imp.execute_msg = owner.errors.full_messages
#       imp.save!
#     end
#   end
# end
#
#
# # 一括建物登録を行います。
# # type:0 自社管理対象 1:アタックリスト
# # ▼受け取る項目（自は自社管理物件、他はアタックリスト）
# # 0 管理営業所CD（自他）
# # 1 管理営業所名（自他）
# # 2 建物CD（自他）
# # 3 建物名（自他）
# # 4 郵便場号（自他）
# # 5 住所（自他）
# # 6 築年月日（自他）
# # 7 物件種別CD（自）
# # 8 物件種別名
# # 9 総戸数
# # 10 間取り(他)
# # 11 貸主CD
# # 12 管理方式CD（自）
# # 13 管理方式名（自）
# # 14 管理委託契約CD(自)
#
# def bulk_building_regist(type, filename)
#   # ファイル存在チェック
#   unless File.exist?(filename)
#     puts 'file not exist'
#     return false
#   end
#
#   # 元データを一時表に登録
#   open(filename).each_with_index do |line, cnt|
#     catch :not_header do
#
#       # 1行目は読み飛ばす
#       throw :not_header if cnt == 0
#
#       # 必要項目に満たないものは読み飛ばす
#       row = line.split(",")
#       unless row[11]
#         p cnt.to_s + "行目は項目が足りていないのでスキップ"
#         throw :not_header
#       end
#
#       imp = ImpTable.new
#       imp.building_type = type
#       imp.eigyo_cd = row[0]
#       imp.eigyo_nm = row[1]
#       imp.building_cd = row[2]
#       imp.building_nm = row[3]
#       imp.building_postcode = row[4]
#       imp.building_address = row[5]
#       imp.build_day = row[6]
#       imp.building_type_cd = row[7]
#       imp.owner_cd = row[11]
#       imp.manage_type_cd = row[12]
#       imp.manage_type_nm = row[13]
#       imp.trust_cd = row[14]
#
#       imp.building_memo = "物件種別：" + row[8] + ", 間取り：" + row[10] + ", 戸数：" + row[9]
#       imp.save!
#
#       p cnt.to_s + " " + imp.owner_nm
#     end
#   end
#
#
#
#   # typeによって建物の登録（同じ建物CDが存在したら上書き）
#
#   # 管理委託CDの取得
# end

# 指定した受託担当者のアタックリストのExcelの情報を登録します。
# -ファイル要素-----------------------------
# 0：NO
# 1：登録年月日（リスト記載日）
# 2：ランク
# 3：物件所在地①（市区町村丁目）
# 4：物件所在地②（番地等）
# 5：地番
# 6：駅
# 7：距離
# 8：時間
# 9：物件名
# 10：総戸数
# 11：間取①
# 12：戸数
# 13：間取②
# 14：戸数
# 15：建築年月(1999/1)と入力してください。
# 16：築年数（自動計算のため入力禁止）
# 17：構造（リスト）
# 18：階数
# 19：貸主様名
# 20：敬称
# 21：フリガナ
# 22：〒
# 23：貸主住所①（都道府県）
# 24：貸主住所②（市区町村丁目）
# 25：貸主住所③（番地等）
# 26：貸主住所④マンション名等
# 27：貸主電話
# 28：現管理会社
# 29：募集会社
# 30：サブリース会社
# 31：連絡先
# 32：備考1（貸主へ飛ばす）
# 33：備考2（建物へ飛ばす）
# 34：DM送付区分（DMをお送りする方に○を記載してください。）
# 35：アプローチ状況①
# 36：アプローチ状況②
# 37：アプローチ状況①
# 38：アプローチ状況②
# 39：アプローチ状況①
def reg_attack_owner_building(biru_user_code, shop_name, filename)
	
  # バッチコード
  batch_code = "AT" + Time.now.strftime("%Y%m%d%H%M%S")
  msg = ""
  
	# 指定された担当者が存在するかチェック
	biru_user = BiruUser.find_by_code(biru_user_code)
	unless biru_user	
		puts 'user not exist'
		return false
  end
  
  shop = Shop.find_by_name(shop_name)
	unless shop	
		puts 'shop not exist'
		return false
  end

  # ファイル存在チェック
  unless File.exist?(filename)
    puts 'file not exist'
    return false
  end
	
	# imp_tableへ書き込み
	#ImpTable.delete_all("imp_tables.biru_user_id = " + biru_user.id.to_s)
  owner_dm_ng = []
  open(filename).each_with_index do |line, cnt|
    catch :not_header do

      # 1行目は読み飛ばす
      throw :not_header if cnt == 0
        
      # 必要項目に満たないものは読み飛ばす
      row = line.split(",")
#      unless row[40] 
#        p cnt.to_s + "行目は項目が足りていないのでスキップ" 
#        throw :not_header
#      end

      imp = ImpTable.new
      imp.batch_code = batch_code
      imp.biru_user_id = biru_user.id
      imp.list_no = row[0]
      imp.biru_rank = row[2]
      
      if row[4].strip.length > 0
      	# 住所２が入っている時
	      imp.building_address = (row[3] + ' ' + row[4]).strip
      	
   		elsif row[5].strip.length
   			# 地番が入っている時
	      imp.building_address = (row[3] + ' ' + row[5]).strip
  		else
  			# 住所２も地番も入っていない時
	      imp.building_address = (row[3]).strip
			end
      
      imp.building_address = Moji.han_to_zen(imp.building_address)

      # imp.building_nm = row[9]
      imp.building_nm = Moji.han_to_zen(row[9].strip)
      
      # building_cdは、building.idを使うのでコメントアウト。ただしimport時に特定する必要があるので、代わりにbuilding_hash列を設ける
      # imp.building_cd = conv_code(imp.biru_user_id.to_s + '_' + imp.building_address + '_' + imp.building_nm)
      # imp.building_hash = conv_code(imp.biru_user_id.to_s + '_' + imp.building_address + '_' + imp.building_nm)
      
      app_con = ApplicationController.new
      imp.building_hash = app_con.conv_code_building(imp.biru_user_id.to_s, imp.building_address, imp.building_nm)
      

      imp.owner_nm = Moji.han_to_zen(row[19].strip)
      imp.owner_honorific_title = row[20]
      imp.owner_kana = row[21]
      imp.owner_postcode = row[22]
      imp.owner_address = Moji.han_to_zen((row[23] + ' ' + row[24] + ' ' + row[25] + ' ' + row[26]).strip)
      imp.owner_tel = row[27]
      
      # 現管理会社、募集会社、サブリース
      imp.proprietary_company = row[28]
      unless row[29].blank?
        
        if imp.proprietary_company.blank?
          imp.proprietary_company = row[29]
        else
          imp.proprietary_company = imp.proprietary_company + '／' + row[29]
        end
        
      end
      
      unless row[30].blank?
        if imp.proprietary_company.blank?
          imp.proprietary_company = row[30]
        else
          imp.proprietary_company = imp.proprietary_company + '／' + row[30]
        end
      end
      
      imp.owner_memo = row[32]
      imp.building_memo = row[33]
      
      # owner_cdは、owner.idを使うのでコメントアウト。ただしimport時に特定する必要があるので、代わりにowner_hash列を設ける
      #imp.owner_cd = conv_code(imp.biru_user_id.to_s + '_' + imp.owner_address + '_' + imp.owner_nm)
      #imp.owner_hash = conv_code(imp.biru_user_id.to_s + '_' + imp.owner_address + '_' + imp.owner_nm)
      imp.owner_hash = app_con.conv_code_owner(imp.biru_user_id.to_s, imp.owner_address, imp.owner_nm)
      
      # オーナー発送区分 発送区分が対象外のOWNER_HASHを保存
      if row[34]
	      if row[34].strip == "×" || row[34].strip == "対象外"
	        owner_dm_ng.push(imp.owner_hash)
	      end
      end
      
      # アプローチ履歴を登録する。
      imp.approach_01 = row[35]
      imp.approach_02 = row[36]
      imp.approach_03 = row[37]
      imp.approach_04 = row[38]
      imp.approach_05 = row[39]
      
      # アプローチメモ
      imp.save!
      p cnt.to_s + " " + imp.owner_nm
    end
  end
  
	# 指定された担当者、建物ユニークキーを元に該当のオーナーを取得(なければ新規作成)
		#空白の項目があったらupdateしてあげよう(確定はまた今度で)
		# エラーだったら以下を読み飛ばす。
	#ImpTable.find_all_by_biru_user_id(biru_user.id).each do |imp|
	ImpTable.where("batch_code = ?", batch_code).each do |imp|
    
	  catch :next_rec do
	  	######################
	  	# 貸主の登録・特定
	  	######################
			owner = Owner.unscoped.find_or_create_by_hash_key(imp.owner_hash)
      owner.hash_key = imp.owner_hash
			owner.name = imp.owner_nm
			owner.address = imp.owner_address
			owner.postcode = imp.owner_postcode
			owner.honorific_title = imp.owner_honorific_title
			owner.tel = imp.owner_tel
			owner.biru_user_id = biru_user.id
			
			if owner.memo
				# メモ内容で同一のものが存在しない時、書込み
				owner.memo = owner.memo + ' ' + imp.owner_memo unless owner.memo.index(imp.owner_memo)
			else
				owner.memo = imp.owner_memo
			end
			
			owner.delete_flg = false
			msg = biru_geocode(owner, false)
			
	    begin
	      owner.save!
  			owner.attack_code = "OA%06d"%owner.id # 貸主idをattack_codeとする
        owner.save!
	    rescue => e
	      # p $!.to_s
	      p "エラーメッセージ:" + msg
        imp.execute_status = 2
        imp.execute_msg = batch_code + "：No." + imp.list_no + "：貸主：" + owner.name + "：" + owner.address + "：" + msg
        imp.save!
        
	      throw :next_rec
	    end
	    
	  	######################
	  	# アプローチ履歴の登録
	  	######################
	  	approach_list = []
	  	approach_list.push(imp.approach_01) unless imp.approach_01.blank?
	  	approach_list.push(imp.approach_02) unless imp.approach_02.blank?
	  	approach_list.push(imp.approach_03) unless imp.approach_03.blank?
	  	approach_list.push(imp.approach_04) unless imp.approach_04.blank?
	  	approach_list.push(imp.approach_05) unless imp.approach_05.blank?
	  	
	  	approach_list.each do |approach|
	  		#owner_app = OwnerApproach.new
	  		owner_app = OwnerApproach.find_or_create_by_owner_id_and_biru_user_id_and_content_and_approach_date(owner.id, biru_user.id, approach, "1900/01/01")
	  		owner_app.owner_id = owner.id
	  		
	  		#owner_app = owner.approaches.build
	  		
	  		owner_app.biru_user_id = biru_user.id
	  		owner_app.approach_date = "1900/01/01"
	  		owner_app.approach_kind_id = ApproachKind.find_by_code("0055").id
	  		owner_app.content = approach
	  		
	  		owner_app.save!
	  	end
	    
	  	######################
	  	# 建物の登録・特定
	  	######################
	  	trust_space_regist = false # 委託契約を空白で登録
	  	building = Building.unscoped.find_or_create_by_hash_key(imp.building_hash)
      building.hash_key = imp.building_hash
	  	building.address = imp.building_address
	  	building.name = imp.building_nm
	  	building.delete_flg = false
			building.shop_id = shop.id
      building.biru_user_id = biru_user.id
			msg = biru_geocode(building, false)

      building.memo = imp.building_memo
      building.proprietary_company = imp.proprietary_company
			
	    begin
	      building.save!
  	  	building.attack_code = "BA%06d"%building.id # 建物idをattack_codeとする
	      building.save!
	    rescue      
	      # p $!
        imp.execute_status = 2
        imp.execute_msg = batch_code + "：No." + imp.list_no + "：建物：" + building.name + "：" + building.address + "：" + msg
        
        imp.save!

	      # throw :next_rec 2014/08/16 エラーであってもアタックリストに出す為に建物無しで委託契約登録を行う。
	      trust_space_regist = true
	    end
	  	
	  	######################
	  	# 委託契約の登録
	  	######################
	  	if trust_space_regist 
	  		# 建物登録に失敗したので、建物は空白で委託登録（ただしすでに空白の委託が１つ存在していたらそれを再利用）
	  		trust = Trust.unscoped.find_or_create_by_owner_id_and_building_id(owner.id, nil)
		  	trust.owner_id = owner.id
		  	trust.building_id = nil
	      trust.biru_user_id = biru_user.id
		  	trust.manage_type_id = ManageType.find_by_code('99').id # 管理外
		  	trust.delete_flg = false
	      p "空白オーナー登録: " + owner.name
		  else
		  	trust = Trust.unscoped.find_or_create_by_owner_id_and_building_id(owner.id, building.id)
		  	trust.owner_id = owner.id
		  	trust.building_id = building.id
	      trust.biru_user_id = biru_user.id
		  	trust.manage_type_id = ManageType.find_by_code('99').id # 管理外
		  	trust.delete_flg = false
		  	
				# 物件ランクの登録
				if imp.biru_rank
					rank = AttackState.find_by_code( Moji.han_to_zen(imp.biru_rank.upcase.encode('utf-8')).strip )
					if rank
						trust.attack_state_id = rank.id
					end
				end
	  	end
	  	
	    begin
	      trust.save!
        trust.code = "TA%06d"%trust.id
	      trust.save!
	    rescue
	      p "委託契約登録失敗:save "
        imp.execute_status = 2
        imp.execute_msg = "委託契約登録失敗:save "
        imp.save!
        
	      throw :next_rec
	    end
	    
	  end
    
    imp.execute_status = 1
    imp.save!
  
  end
	
  # DM出力対象外の人を更新
  Owner.find_all_by_hash_key(owner_dm_ng).each do |owner|
    owner.dm_delivery = false
    owner.save!
  end
  
end

# geocode されていないものをアップデート
def update_geocode

  # 貸主
  Owner.unscoped.where(:latitude => nil).each do |owner|
    #unless biru_geocode(owner, true)
    if biru_geocode(owner, true) != ""
      owner.delete_flg = true
    end
    owner.save!
  end

  # 建物
  Building.unscoped.where(:latitude => nil).each do |biru|
    if biru_geocode(biru, true) != ""
      biru.delete_flg = true
    end
    biru.save!
  end

end

#update_geocode



#####################################################
# 業績管理情報登録
#####################################################
def performance_init

  ################
  # 項目マスタ登録
  ################
  item_arr = []

  item_arr.push(:code=>'41010', :name=>'売買仲介手数料')
  item_arr.push(:code=>'41020', :name=>'賃貸仲介手数料')
  item_arr.push(:code=>'41030', :name=>'広告代理店収入')
  item_arr.push(:code=>'41040', :name=>'管理手数料')
  item_arr.push(:code=>'41050', :name=>'つなぎ売上')
  item_arr.push(:code=>'41060', :name=>'保険代理店収入　計上')
  item_arr.push(:code=>'41070', :name=>'建物管理売上')
  item_arr.push(:code=>'41080', :name=>'完成工事高中古土地')
  item_arr.push(:code=>'41090', :name=>'完成工事高中古建物')
  item_arr.push(:code=>'43010', :name=>'受取手数料')
  item_arr.push(:code=>'44010', :name=>'賃貸料')
  item_arr.push(:code=>'44020', :name=>'サブリース等売上')
  item_arr.push(:code=>'45010', :name=>'賃貸付随売上')
  item_arr.push(:code=>'45011', :name=>'グランテック紹介手数料')
  item_arr.push(:code=>'51010', :name=>'つなぎ売上原価')
  item_arr.push(:code=>'51020', :name=>'原価メンテナンス')
  item_arr.push(:code=>'51030', :name=>'サブリース等原価')
  item_arr.push(:code=>'51040', :name=>'付随原価')
  item_arr.push(:code=>'51080', :name=>'材料費　中古土地')
  item_arr.push(:code=>'51090', :name=>'材料費　中古建物')
  item_arr.push(:code=>'61010', :name=>'販売員給与')
  item_arr.push(:code=>'61020', :name=>'販売手数料')
  item_arr.push(:code=>'61030', :name=>'広告宣伝費')
  item_arr.push(:code=>'61040', :name=>'アフターサービス')
  item_arr.push(:code=>'61050', :name=>'販売促進費')
  item_arr.push(:code=>'61060', :name=>'物件管理費')
  item_arr.push(:code=>'61090', :name=>'貸倒引当金繰入')
  item_arr.push(:code=>'61100', :name=>'貸倒損失')
  item_arr.push(:code=>'62020', :name=>'役員報酬')
  item_arr.push(:code=>'62030', :name=>'事務員給与')
  item_arr.push(:code=>'62040', :name=>'賞与')
  item_arr.push(:code=>'62050', :name=>'賞与引当金繰入高')
  item_arr.push(:code=>'62060', :name=>'雑給')
  item_arr.push(:code=>'62070', :name=>'退職金')
  item_arr.push(:code=>'62080', :name=>'退職年金掛金')
  item_arr.push(:code=>'62081', :name=>'退職給付費用')
  item_arr.push(:code=>'62090', :name=>'法定福利費')
  item_arr.push(:code=>'62100', :name=>'福利厚生費')
  item_arr.push(:code=>'62110', :name=>'研修費')
  item_arr.push(:code=>'62120', :name=>'社員採用費')
  item_arr.push(:code=>'62130', :name=>'修繕費')
  item_arr.push(:code=>'62140', :name=>'事務消耗品費')
  item_arr.push(:code=>'62150', :name=>'通信費')
  item_arr.push(:code=>'62160', :name=>'旅費交通費')
  item_arr.push(:code=>'62161', :name=>'ガソリン費')
  item_arr.push(:code=>'62170', :name=>'水道光熱費')
  item_arr.push(:code=>'62180', :name=>'接待交際費')
  item_arr.push(:code=>'62190', :name=>'会議費')
  item_arr.push(:code=>'62200', :name=>'寄付金')
  item_arr.push(:code=>'62210', :name=>'地代家賃')
  item_arr.push(:code=>'62220', :name=>'賃借料')
  item_arr.push(:code=>'62230', :name=>'減価償却費')
  item_arr.push(:code=>'62240', :name=>'即時償却費')
  item_arr.push(:code=>'62250', :name=>'租税公課')
  item_arr.push(:code=>'62260', :name=>'保険料')
  item_arr.push(:code=>'62270', :name=>'諸会費')
  item_arr.push(:code=>'62280', :name=>'支払手数料')
  item_arr.push(:code=>'62290', :name=>'備品消耗品費')
  item_arr.push(:code=>'62300', :name=>'新聞図書費')
  item_arr.push(:code=>'62310', :name=>'長期前払費用償却')
  item_arr.push(:code=>'62700', :name=>'雑費')
  item_arr.push(:code=>'62800', :name=>'経費分担金')
  item_arr.push(:code=>'62900', :name=>'支払事業税')
  item_arr.push(:code=>'71010', :name=>'受取利息')
  item_arr.push(:code=>'71020', :name=>'受取配当金')
  item_arr.push(:code=>'71030', :name=>'有価証券利息')
  item_arr.push(:code=>'71040', :name=>'有価証券売却益')
  item_arr.push(:code=>'71200', :name=>'雑収入')
  item_arr.push(:code=>'72010', :name=>'支払利息割引料')
  item_arr.push(:code=>'72040', :name=>'有価証券売却益')
  item_arr.push(:code=>'72200', :name=>'雑損失')
  item_arr.push(:code=>'A0001', :name=>'売上高')
  item_arr.push(:code=>'A0002', :name=>'原価合計')
  item_arr.push(:code=>'A0003', :name=>'人件費')
  item_arr.push(:code=>'A0004', :name=>'経費')
  item_arr.push(:code=>'A0005', :name=>'営業利益')
  item_arr.push(:code=>'A0006', :name=>'営業外損益')
  item_arr.push(:code=>'A0007', :name=>'経常利益')
  item_arr.push(:code=>'A0008', :name=>'本部費')
  item_arr.push(:code=>'A0009', :name=>'経常/売上')
  item_arr.push(:code=>'A0010', :name=>'人件費/粗利')
  item_arr.push(:code=>'B0001', :name=>'新規受託管理戸数　他社')
  item_arr.push(:code=>'B0002', :name=>'新規受託管理戸数　自社')
  item_arr.push(:code=>'B0003', :name=>'売買粗利益　契約')
  item_arr.push(:code=>'B0004', :name=>'家賃立替サービス代理店手数料')
  item_arr.push(:code=>'B0005', :name=>'総管理戸数')
  item_arr.push(:code=>'B0006', :name=>'空室率')
  item_arr.push(:code=>'B0007', :name=>'入居率')
  item_arr.push(:code=>'B0008', :name=>'建築紹介')
  item_arr.push(:code=>'B0009', :name=>'賃貸仲介件数')
  item_arr.push(:code=>'B0010', :name=>'粗利益')
  item_arr.push(:code=>'B0011', :name=>'社員')
  item_arr.push(:code=>'B0012', :name=>'通勤費')
  item_arr.push(:code=>'B0013', :name=>'提案受注工事')
  item_arr.push(:code=>'B0014', :name=>'付随契約件数')
  item_arr.push(:code=>'B0015', :name=>'売上ＰＨ')
  item_arr.push(:code=>'B0016', :name=>'粗利益ＰＨ')
  item_arr.push(:code=>'B0017', :name=>'経常利益ＰＨ')
  item_arr.push(:code=>'B0018', :name=>'原状回復工事所要日数')
  item_arr.push(:code=>'B0019', :name=>'原状回復工事売上')
  item_arr.push(:code=>'B0020', :name=>'定期設備メンテナンス売上')
  item_arr.push(:code=>'B0021', :name=>'提案設備メンテナンス売上')
  item_arr.push(:code=>'B0022', :name=>'原状回復工事粗利益率')
  item_arr.push(:code=>'B0023', :name=>'提案同行数')
  item_arr.push(:code=>'B0024', :name=>'巡回清掃売上')
  item_arr.push(:code=>'B0025', :name=>'保険代理店収入　契約')
  item_arr.push(:code=>'B0026', :name=>'火災保険継続率')
  item_arr.push(:code=>'B0027', :name=>'新規契約時地震家財追加保険率')
  item_arr.push(:code=>'B0028', :name=>'火災保険独自新規契約件数')
  item_arr.push(:code=>'B0029', :name=>'自動車保険継続率')
  item_arr.push(:code=>'B0030', :name=>'自動車保険既契約者ランクアップ継続率')
  item_arr.push(:code=>'B0031', :name=>'自動車保険独自新規契約件数')
  item_arr.push(:code=>'B0032', :name=>'人身事故現場出動率')
  item_arr.push(:code=>'B0033', :name=>'入居者保険更新手続完了率')
  item_arr.push(:code=>'B0034', :name=>'生命保険新規契約手数料')
  item_arr.push(:code=>'B0035', :name=>'不動産再生売上　契約')
  item_arr.push(:code=>'B0036', :name=>'買取棟数')
  item_arr.push(:code=>'B0037', :name=>'法人賃貸紹介件数')
  item_arr.push(:code=>'B0038', :name=>'オーナー借上提案数')
  item_arr.push(:code=>'B0039', :name=>'資産売却受託件数')
  item_arr.push(:code=>'B0040', :name=>'新築・注文契約件数')
  item_arr.push(:code=>'B0041', :name=>'マンション管理手数料')
  item_arr.push(:code=>'B0042', :name=>'定期清掃売上')
  item_arr.push(:code=>'B0043', :name=>'損害サービス工事受注金額')
  item_arr.push(:code=>'B0044', :name=>'損害サービス工事受注件数')
  item_arr.push(:code=>'B0045', :name=>'クリーンサービス係売上')
  item_arr.push(:code=>'B0047', :name=>'提案リフォーム受注金額')
  item_arr.push(:code=>'B0048', :name=>'提案リフォーム受注件数')
  item_arr.push(:code=>'B0049', :name=>'マンション新規管理受託戸数')
  item_arr.push(:code=>'B0050', :name=>'長期修繕コンサル提案件数')
  item_arr.push(:code=>'B0051', :name=>'見積提出金額')
  item_arr.push(:code=>'B0052', :name=>'見積納期厳守率')
  item_arr.push(:code=>'B0053', :name=>'建築ｺﾝｻﾙﾀﾝﾄ契約件数')
  item_arr.push(:code=>'B0054', :name=>'建築ｺﾝｻﾙﾀﾝﾄ提案件数')
  item_arr.push(:code=>'B0055', :name=>'提案ﾘﾌｫｰﾑ見積提出金額')
  item_arr.push(:code=>'B0056', :name=>'提案ﾘﾌｫｰﾑ見積納期厳守率')
  item_arr.push(:code=>'B0057', :name=>'提案受注件数')
  item_arr.push(:code=>'B0058', :name=>'提案受注金額')
  item_arr.push(:code=>'B0059', :name=>'提案提出件数')
  item_arr.push(:code=>'B0060', :name=>'リースキン売上')
  item_arr.push(:code=>'B0061', :name=>'提案清掃売上')
  item_arr.push(:code=>'B0062', :name=>'分譲マンション工事売上')
  item_arr.push(:code=>'B0063', :name=>'清掃見積提出件数')
  item_arr.push(:code=>'B0064', :name=>'パート')
  item_arr.push(:code=>'B0065', :name=>'試算表部門別損益提出2.5日以内提出')
  item_arr.push(:code=>'B0066', :name=>'初回家賃滞納率5％')
  item_arr.push(:code=>'B0067', :name=>'工事代未収100万円以下（経理係）方針2.（1）')
  item_arr.push(:code=>'B0068', :name=>'更新書類再送率10％以下')
  item_arr.push(:code=>'B0069', :name=>'定期内部監査実施結果全店100点')
  item_arr.push(:code=>'B0070', :name=>'ﾙｰﾙﾌﾞｯｸ定着率100％')
  item_arr.push(:code=>'B0071', :name=>'提出書類の完成度100％')
  item_arr.push(:code=>'B0072', :name=>'新規事業支援率100％（百万）')
  item_arr.push(:code=>'B0073', :name=>'ﾋﾞﾙ管理全体ISO進捗率100％')
  item_arr.push(:code=>'B0074', :name=>'次期ｼｽﾃﾑ進捗率100％')
  item_arr.push(:code=>'B0075', :name=>'各種社員研修理解ﾃｽﾄ90％以上')
  item_arr.push(:code=>'B0076', :name=>'ｸﾚｰﾑ発生件数（前年実績5％ﾀﾞｳﾝ）')
  item_arr.push(:code=>'B0077', :name=>'ｸﾚｰﾑ処理率（％）')
  item_arr.push(:code=>'B0078', :name=>'全部署ﾉｰ残業ﾃﾞｰ実施率100％')
  item_arr.push(:code=>'B0079', :name=>'振替休日取得率100％')
  item_arr.push(:code=>'B0080', :name=>'入社後1年以内新入社員　中途社員定着率100％')
  item_arr.push(:code=>'B0081', :name=>'内部売上')
  item_arr.push(:code=>'B0082', :name=>'内部振分')
  item_arr.push(:code=>'B0083', :name=>'内部費用')
  item_arr.push(:code=>'B0084', :name=>'再生事業粗利益（契約）')
  item_arr.push(:code=>'B0085', :name=>'見積提出件数')
  item_arr.push(:code=>'B0086', :name=>'B管理手数料')
  item_arr.push(:code=>'B0087', :name=>'Bサブリース売上')
  item_arr.push(:code=>'B0088', :name=>'現場労災（休業３日）')
  item_arr.push(:code=>'B0089', :name=>'収益物件期間収支')
  item_arr.push(:code=>'B0090', :name=>'家賃回収滞納率')
  item_arr.push(:code=>'B0091', :name=>'解約精算・工事所要日数')
  item_arr.push(:code=>'B0092', :name=>'サブリース等粗利率')
  item_arr.push(:code=>'B0093', :name=>'自己開拓契約件数')
  item_arr.push(:code=>'B0094', :name=>'火災保険独自新規契約手数料')
  item_arr.push(:code=>'B0095', :name=>'火災保険更新手数料')
  item_arr.push(:code=>'B0096', :name=>'建物点検報告書提出件数')
  item_arr.push(:code=>'B0097', :name=>'提案リフォーム引継件数')
  item_arr.push(:code=>'B0098', :name=>'派遣社員')
  item_arr.push(:code=>'B0100', :name=>'月1回のNO残業DAYの実施と9時以降の残業なし(企画課)')
  item_arr.push(:code=>'B0101', :name=>'各プロジェクト・キャンペ－ン等　月5つ以上の支援(企画課)')
  item_arr.push(:code=>'B0102', :name=>'新規見積り提出件数(分譲マン)')
  item_arr.push(:code=>'B0103', :name=>'分譲マンション新規管理受託戸数(分譲マン)')
  item_arr.push(:code=>'B0104', :name=>'訪問から1週間以内完了率80%(センター)')
  item_arr.push(:code=>'B0105', :name=>'初期修理発生率4.5%以内（センター）')
  item_arr.push(:code=>'B0106', :name=>'売上確定報告書締め日後1日18：00提出（業務管理）')
  item_arr.push(:code=>'B0107', :name=>'総家賃延滞率7％以下（業務管理）')
  item_arr.push(:code=>'B0108', :name=>'更新書類再送率2%以下(業務管理)')
  item_arr.push(:code=>'B0109', :name=>'売買事業契約達成率100%(契約支援)')
  item_arr.push(:code=>'B0110', :name=>'管理書・PDS期日内登録100%(契約支援)')
  item_arr.push(:code=>'B0200', :name=>'コインパーキング売上')
  item_arr.push(:code=>'B0201', :name=>'コインランドリー売上')
  item_arr.push(:code=>'B0210', :name=>'事業部全体月2回部署別消灯デー 実施(総務係)')
  item_arr.push(:code=>'B0211', :name=>'広告宣伝費販売促進費合計前年比25％削減(企画係)')
  item_arr.push(:code=>'B0212', :name=>'付随商品手数料計画達成')
  item_arr.push(:code=>'B0213', :name=>'総家賃延滞率6.5％以下（家賃更新係）方針2.（2）')
  item_arr.push(:code=>'B0214', :name=>'工事代未収金80万以下(経理係)')
  item_arr.push(:code=>'B0215', :name=>'修理受付件数前年比5％削減(工事受付センター)')
  item_arr.push(:code=>'B0216', :name=>'初期修理発生件数前年比5％以下(品質管理係)')
  item_arr.push(:code=>'B0217', :name=>'分譲マンション新規管理受託数')
  item_arr.push(:code=>'B0218', :name=>'売買粗利益等計画達成')
  item_arr.push(:code=>'B0219', :name=>'初期修理発生率前年比4.5％以下(品質管理係)')
  item_arr.push(:code=>'B0220', :name=>'更新書類回収率95％以上（家賃更新係）方針2.（3）')
  item_arr.push(:code=>'B0221', :name=>'新規システム開発進捗率100％（企画係）方針4.（1）')
  item_arr.push(:code=>'B0222', :name=>'広告宣伝費販売促進費合計前年比25％削減(企画係)')
  item_arr.push(:code=>'B0223', :name=>'就業管理システム申請不備率0％(総務係)')
  item_arr.push(:code=>'B0224', :name=>'巡回清掃契約件数')
  item_arr.push(:code=>'B0225', :name=>'サブリース管理戸数')
  item_arr.push(:code=>'B0226', :name=>'従業員退社時間10％削減（総務係）方針1.（1）')
  item_arr.push(:code=>'B0227', :name=>'リーダー候補生育成（総務係）方針1.（3）')
  item_arr.push(:code=>'B0228', :name=>'事業部全体二次クレームゼロ（工事受付センター）方針1.（1）④')
  item_arr.push(:code=>'B0229', :name=>'初期修理割合15％以下（品質管理係）方針3.（2）①')
  item_arr.push(:code=>'B0230', :name=>'原状回復工期厳守率7日以内　（品質企画課）')
  item_arr.push(:code=>'B0231', :name=>'賃貸仲介手数料計画達成')
  item_arr.push(:code=>'B0232', :name=>'損害調査受注件数')
  item_arr.push(:code=>'B0233', :name=>'損害調査受注金額')
  item_arr.push(:code=>'B0234', :name=>'新規保険拠点開拓数')
  item_arr.push(:code=>'B0235', :name=>'30日以内工事完了報告率')
  item_arr.push(:code=>'B0236', :name=>'事故現場社員出勤率')
  item_arr.push(:code=>'B0237', :name=>'エアコン受注台数')
  item_arr.push(:code=>'B0238', :name=>'エアコン受完了台数')
  item_arr.push(:code=>'B0239', :name=>'定期清掃作業件数')
  item_arr.push(:code=>'B0340', :name=>'巡回清掃受託棟数')
  item_arr.push(:code=>'B0400', :name=>'工事売上')
  item_arr.push(:code=>'B0401', :name=>'設備保守売上')
  item_arr.push(:code=>'B0402', :name=>'管理業務報告書提出日数')
  item_arr.push(:code=>'B0403', :name=>'管理委託見積書提出件数')
  item_arr.push(:code=>'B0410', :name=>'新規委託契約組合数')
  item_arr.push(:code=>'B0411', :name=>'新規見積り提出件数')
  item_arr.push(:code=>'B0412', :name=>'管理移行検討組合数')
  item_arr.push(:code=>'B0413', :name=>'報告書20日以内提出率')
  item_arr.push(:code=>'B0500', :name=>'他社管理受託戸数（計上）')
  item_arr.push(:code=>'B0501', :name=>'建物管理契約受託棟数')
  item_arr.push(:code=>'B0502', :name=>'サブリ－ス受託戸数（契約）')
  item_arr.push(:code=>'B0503', :name=>'一般媒介受託戸数')
  item_arr.push(:code=>'B0504', :name=>'資産売買紹介件数')
  item_arr.push(:code=>'B0505', :name=>'提案ポイント件数')
  item_arr.push(:code=>'B0600', :name=>'職場巡回指摘改善数（総）')
  item_arr.push(:code=>'B0601', :name=>'18：00以降在社時間ﾗｲﾝ短縮（総）')
  item_arr.push(:code=>'B0602', :name=>'新規管理受託他社（品）')
  item_arr.push(:code=>'B0603', :name=>'システム開発進捗率（品）')
  item_arr.push(:code=>'B0604', :name=>'初期修理発生率（品）')
  item_arr.push(:code=>'B0605', :name=>'室内デザインパック受注（品）')
  item_arr.push(:code=>'B0606', :name=>'修理未完了件数（カ）')
  item_arr.push(:code=>'B0607', :name=>'売買粗利益（売）')
  item_arr.push(:code=>'C0001', :name=>'営業紹介契約棟数')
  item_arr.push(:code=>'C0002', :name=>'業者紹介契約棟数')
  item_arr.push(:code=>'C0003', :name=>'社員紹介契約棟数')
  item_arr.push(:code=>'D0001', :name=>'契約書取得率')
  item_arr.push(:code=>'D0002', :name=>'立替サービス契約総件数')
  item_arr.push(:code=>'D0003', :name=>'滞納賃料当月内回収率')
  item_arr.push(:code=>'D0004', :name=>'前月分滞納賃料回収率')
  item_arr.push(:code=>'D0005', :name=>'新規立替サービス契約件数')
  item_arr.push(:code=>'D0006', :name=>'新規立替サービス契約手数料')
  item_arr.push(:code=>'D0007', :name=>'他社切替え立替えサービス契約件数')
  item_arr.push(:code=>'D0008', :name=>'他社切替え立替えサービス契約手数料')
  item_arr.push(:code=>'D0009', :name=>'立替サービス引受保有件数')
  item_arr.push(:code=>'D0010', :name=>'外販保証契約件数')
  item_arr.push(:code=>'D0011', :name=>'外販保証契約手数料')
  item_arr.push(:code=>'D0012', :name=>'滞納賃料立替金額')
  item_arr.push(:code=>'D0013', :name=>'滞納賃料立替件数')
  item_arr.push(:code=>'D0014', :name=>'立替未収残高')
  item_arr.push(:code=>'Z0002', :name=>'賃貸仲介手数料　合算')
  item_arr.push(:code=>'Z0003', :name=>'売買仲介手数料　合算')
  item_arr.push(:code=>'Z0004', :name=>'賃貸付随売上　合算')
  item_arr.push(:code=>'Z0005', :name=>'再生事業売上　合算')
  item_arr.push(:code=>'Z0006', :name=>'営業外損益　合算')

  item_arr.push(:code=>'E0001', :name=>'新規来店客数')
  item_arr.push(:code=>'E0002', :name=>'賃貸契約件数')

  item_arr.each do |obj|
    item = Item.find_or_create_by_code(obj[:code])
    item.code = obj[:code]
    item.name = obj[:name]
    item.save!
  end


  ################
  # 部署マスタ登録
  ################
  dept_arr = []
	dept_arr.push(:busyo_id=>'304', :code=>'W0053', :name=>'常盤エリア固有')
	dept_arr.push(:busyo_id=>'302', :code=>'50122', :name=>'戸田公園営業所')
	dept_arr.push(:busyo_id=>'295', :code=>'90012', :name=>'千葉資産活用課')
	dept_arr.push(:busyo_id=>'294', :code=>'90011', :name=>'さいたま資産活用課')
	dept_arr.push(:busyo_id=>'293', :code=>'90010', :name=>'東武資産活用課')
	dept_arr.push(:busyo_id=>'290', :code=>'W0052', :name=>'さいたま南エリア固有')
	dept_arr.push(:busyo_id=>'289', :code=>'W0051', :name=>'さいたま北エリア固有')
	dept_arr.push(:busyo_id=>'287', :code=>'50095', :name=>'分譲マンション管理課')
	dept_arr.push(:busyo_id=>'268', :code=>'W0060', :name=>'法人事業係')
	dept_arr.push(:busyo_id=>'266', :code=>'W0050', :name=>'常磐西エリア固有')
	dept_arr.push(:busyo_id=>'265', :code=>'W0049', :name=>'常磐中央エリア固有')
	dept_arr.push(:busyo_id=>'264', :code=>'W0048', :name=>'さいたま東エリア固有')
	dept_arr.push(:busyo_id=>'263', :code=>'W0047', :name=>'さいたま中央エリア固有')
	dept_arr.push(:busyo_id=>'262', :code=>'W0046', :name=>'さいたま西エリア固有')
	dept_arr.push(:busyo_id=>'261', :code=>'W0045', :name=>'東武北エリア固有')
	dept_arr.push(:busyo_id=>'260', :code=>'W0044', :name=>'東武中央エリア固有')
	dept_arr.push(:busyo_id=>'259', :code=>'W0043', :name=>'東武南エリア固有')
	dept_arr.push(:busyo_id=>'258', :code=>'30301', :name=>'ポラスアルファ')
	dept_arr.push(:busyo_id=>'257', :code=>'W0042', :name=>'千葉支店固有')
	dept_arr.push(:busyo_id=>'256', :code=>'W0041', :name=>'さいたま支店固有')
	dept_arr.push(:busyo_id=>'255', :code=>'W0040', :name=>'東武支店固有')
	dept_arr.push(:busyo_id=>'232', :code=>'50302', :name=>'千葉不動産流通課')
	dept_arr.push(:busyo_id=>'231', :code=>'50202', :name=>'さいたま不動産流通課')
	dept_arr.push(:busyo_id=>'230', :code=>'50145', :name=>'東武不動産流通課')
	dept_arr.push(:busyo_id=>'229', :code=>'50121', :name=>'せんげん台営業所')
	dept_arr.push(:busyo_id=>'228', :code=>'50107', :name=>'春日部営業所')
	dept_arr.push(:busyo_id=>'227', :code=>'50108', :name=>'北越谷営業所')
	dept_arr.push(:busyo_id=>'225', :code=>'W0035', :name=>'中央ビル管理単体ハートフル固有')
	dept_arr.push(:busyo_id=>'224', :code=>'W0031', :name=>'アセットマネジメント部固有')
	dept_arr.push(:busyo_id=>'223', :code=>'W0030', :name=>'賃貸工事部固有')
	dept_arr.push(:busyo_id=>'218', :code=>'W0210', :name=>'業務管理部合計')
	dept_arr.push(:busyo_id=>'216', :code=>'W0027', :name=>'旧千葉建物管理係')
	dept_arr.push(:busyo_id=>'215', :code=>'W0026', :name=>'旧さいたま建物管理係')
	dept_arr.push(:busyo_id=>'214', :code=>'W0025', :name=>'旧東武建物管理係')
	dept_arr.push(:busyo_id=>'211', :code=>'AF005', :name=>'ビル管理事業部合計')
	dept_arr.push(:busyo_id=>'209', :code=>'50040', :name=>'保険課')
	dept_arr.push(:busyo_id=>'208', :code=>'50023', :name=>'リフォーム課')
	dept_arr.push(:busyo_id=>'207', :code=>'50021', :name=>'サービス課')
	dept_arr.push(:busyo_id=>'187', :code=>'50028', :name=>'分譲マンション管理PJ')
	dept_arr.push(:busyo_id=>'186', :code=>'50022', :name=>'クリーンサービス課')
	dept_arr.push(:busyo_id=>'185', :code=>'50343', :name=>'損害サービス課')
	dept_arr.push(:busyo_id=>'184', :code=>'50342', :name=>'リフォーム係')
	dept_arr.push(:busyo_id=>'183', :code=>'50341', :name=>'建物コンサル係')
	dept_arr.push(:busyo_id=>'182', :code=>'50070', :name=>'不動産流通課')
	dept_arr.push(:busyo_id=>'181', :code=>'50050', :name=>'法人課')
	dept_arr.push(:busyo_id=>'180', :code=>'50044', :name=>'生命保険係')
	dept_arr.push(:busyo_id=>'179', :code=>'50292', :name=>'自動車保険係')
	dept_arr.push(:busyo_id=>'178', :code=>'50291', :name=>'入居者保険係')
	dept_arr.push(:busyo_id=>'177', :code=>'50290', :name=>'火災保険係')
	dept_arr.push(:busyo_id=>'176', :code=>'50301', :name=>'千葉営業支援係')
	dept_arr.push(:busyo_id=>'175', :code=>'50027', :name=>'千葉建物管理課')
	dept_arr.push(:busyo_id=>'174', :code=>'50112', :name=>'南流山営業所')
	dept_arr.push(:busyo_id=>'173', :code=>'50109', :name=>'柏営業所')
	dept_arr.push(:busyo_id=>'172', :code=>'50104', :name=>'北松戸営業所')
	dept_arr.push(:busyo_id=>'171', :code=>'50119', :name=>'松戸営業所')
	dept_arr.push(:busyo_id=>'170', :code=>'50201', :name=>'さいたま営業支援係')
	dept_arr.push(:busyo_id=>'169', :code=>'50026', :name=>'さいたま建物管理課')
	dept_arr.push(:busyo_id=>'168', :code=>'50114', :name=>'戸塚安行営業所')
	dept_arr.push(:busyo_id=>'167', :code=>'50106', :name=>'東川口営業所')
	dept_arr.push(:busyo_id=>'166', :code=>'50110', :name=>'東浦和営業所')
	dept_arr.push(:busyo_id=>'165', :code=>'50113', :name=>'与野営業所')
	dept_arr.push(:busyo_id=>'164', :code=>'50117', :name=>'浦和営業所')
	dept_arr.push(:busyo_id=>'163', :code=>'50115', :name=>'川口営業所')
	dept_arr.push(:busyo_id=>'162', :code=>'50105', :name=>'武蔵浦和営業所')
	dept_arr.push(:busyo_id=>'161', :code=>'50102', :name=>'戸田営業所')
	dept_arr.push(:busyo_id=>'160', :code=>'50150', :name=>'東武営業支援係')
	dept_arr.push(:busyo_id=>'159', :code=>'50025', :name=>'東武建物管理課')
	dept_arr.push(:busyo_id=>'156', :code=>'50118', :name=>'越谷営業所')
	dept_arr.push(:busyo_id=>'155', :code=>'50101', :name=>'南越谷本店')
	dept_arr.push(:busyo_id=>'154', :code=>'50116', :name=>'北千住営業所')
	dept_arr.push(:busyo_id=>'153', :code=>'50111', :name=>'草加新田営業所')
	dept_arr.push(:busyo_id=>'152', :code=>'50103', :name=>'草加営業所')
	dept_arr.push(:busyo_id=>'151', :code=>'50024', :name=>'工事受付センター')
	dept_arr.push(:busyo_id=>'148', :code=>'50034', :name=>'更新管理係')
	dept_arr.push(:busyo_id=>'147', :code=>'50031', :name=>'家賃管理係')
	dept_arr.push(:busyo_id=>'146', :code=>'50035', :name=>'工事経理係')
	dept_arr.push(:busyo_id=>'145', :code=>'50082', :name=>'経理係')
	dept_arr.push(:busyo_id=>'144', :code=>'50081', :name=>'新規事業課')
	dept_arr.push(:busyo_id=>'143', :code=>'50080', :name=>'総合企画課')
	dept_arr.push(:busyo_id=>'142', :code=>'50010', :name=>'人事総務課')
	dept_arr.push(:busyo_id=>'141', :code=>'50910', :name=>'債権回収PJ')

  dept_arr.each do |obj|
    dept = Dept.find_or_create_by_busyo_id(obj[:busyo_id])
    dept.busyo_id = obj[:busyo_id]
    dept.code = obj[:code]
    dept.name = obj[:name]
    dept.save!
    p dept.name
  end


  ######################
  # グループ部署マスタ登録
  ######################
  dept_group_arr = []
	dept_group_arr.push(:busyo_id=>'301', :code=>'80030', :name=>'常磐エリア')
	dept_group_arr.push(:busyo_id=>'300', :code=>'80021', :name=>'さいたま東エリア')
	dept_group_arr.push(:busyo_id=>'299', :code=>'80020', :name=>'さいたま中央エリア')
	dept_group_arr.push(:busyo_id=>'297', :code=>'80011', :name=>'東武北エリア')
	dept_group_arr.push(:busyo_id=>'296', :code=>'80010', :name=>'東武南エリア')
	dept_group_arr.push(:busyo_id=>'269', :code=>'T0002', :name=>'ビル管理_ポラスアルファ合算')
	dept_group_arr.push(:busyo_id=>'254', :code=>'50020', :name=>'建物管理係')
	dept_group_arr.push(:busyo_id=>'253', :code=>'W0900', :name=>'営業店合計')
	dept_group_arr.push(:busyo_id=>'252', :code=>'T0001', :name=>'中央ビル管理単体')
	dept_group_arr.push(:busyo_id=>'249', :code=>'50000', :name=>'株式会社中央ビル管理')
	dept_group_arr.push(:busyo_id=>'248', :code=>'50260', :name=>'ライフサービス課')
	dept_group_arr.push(:busyo_id=>'247', :code=>'50300', :name=>'千葉支店')
	dept_group_arr.push(:busyo_id=>'246', :code=>'50200', :name=>'さいたま支店')
	dept_group_arr.push(:busyo_id=>'245', :code=>'50100', :name=>'東武支店')
	dept_group_arr.push(:busyo_id=>'244', :code=>'50210', :name=>'業務管理部')
	dept_group_arr.push(:busyo_id=>'243', :code=>'50250', :name=>'アセットマネジメント部')
	dept_group_arr.push(:busyo_id=>'235', :code=>'50085', :name=>'家賃更新課')
	dept_group_arr.push(:busyo_id=>'234', :code=>'50030', :name=>'経理課')

  dept_group_arr.each do |obj|
    dept_group = DeptGroup.find_or_create_by_busyo_id(obj[:busyo_id])
    dept_group.busyo_id = obj[:busyo_id]
    dept_group.code = obj[:code]
    dept_group.name = obj[:name]
    dept_group.save!
    p dept_group.name
  end

  ##########################
  # グループ部署マスタ詳細登録
  ##########################

  dept_group_detail_arr = []
  dept_group_detail_arr.push(:group_busyo_id=>'149', :busyo_id=>'145')
  dept_group_detail_arr.push(:group_busyo_id=>'149', :busyo_id=>'146')
  dept_group_detail_arr.push(:group_busyo_id=>'150', :busyo_id=>'147')
  dept_group_detail_arr.push(:group_busyo_id=>'150', :busyo_id=>'148')
  dept_group_detail_arr.push(:group_busyo_id=>'188', :busyo_id=>'152')
  dept_group_detail_arr.push(:group_busyo_id=>'188', :busyo_id=>'153')
  dept_group_detail_arr.push(:group_busyo_id=>'188', :busyo_id=>'154')
  dept_group_detail_arr.push(:group_busyo_id=>'189', :busyo_id=>'155')
  dept_group_detail_arr.push(:group_busyo_id=>'189', :busyo_id=>'156')
  dept_group_detail_arr.push(:group_busyo_id=>'190', :busyo_id=>'227')
  dept_group_detail_arr.push(:group_busyo_id=>'190', :busyo_id=>'228')
  dept_group_detail_arr.push(:group_busyo_id=>'190', :busyo_id=>'229')
  dept_group_detail_arr.push(:group_busyo_id=>'192', :busyo_id=>'163')
  dept_group_detail_arr.push(:group_busyo_id=>'192', :busyo_id=>'164')
  dept_group_detail_arr.push(:group_busyo_id=>'192', :busyo_id=>'165')
  dept_group_detail_arr.push(:group_busyo_id=>'193', :busyo_id=>'166')
  dept_group_detail_arr.push(:group_busyo_id=>'193', :busyo_id=>'167')
  dept_group_detail_arr.push(:group_busyo_id=>'193', :busyo_id=>'168')
  dept_group_detail_arr.push(:group_busyo_id=>'194', :busyo_id=>'171')
  dept_group_detail_arr.push(:group_busyo_id=>'194', :busyo_id=>'172')
  dept_group_detail_arr.push(:group_busyo_id=>'195', :busyo_id=>'173')
  dept_group_detail_arr.push(:group_busyo_id=>'195', :busyo_id=>'174')
  dept_group_detail_arr.push(:group_busyo_id=>'197', :busyo_id=>'181')
  dept_group_detail_arr.push(:group_busyo_id=>'197', :busyo_id=>'182')
  dept_group_detail_arr.push(:group_busyo_id=>'197', :busyo_id=>'224')
  dept_group_detail_arr.push(:group_busyo_id=>'200', :busyo_id=>'211')
  dept_group_detail_arr.push(:group_busyo_id=>'200', :busyo_id=>'218')
  dept_group_detail_arr.push(:group_busyo_id=>'201', :busyo_id=>'152')
  dept_group_detail_arr.push(:group_busyo_id=>'201', :busyo_id=>'153')
  dept_group_detail_arr.push(:group_busyo_id=>'201', :busyo_id=>'154')
  dept_group_detail_arr.push(:group_busyo_id=>'201', :busyo_id=>'155')
  dept_group_detail_arr.push(:group_busyo_id=>'201', :busyo_id=>'156')
  dept_group_detail_arr.push(:group_busyo_id=>'201', :busyo_id=>'159')
  dept_group_detail_arr.push(:group_busyo_id=>'201', :busyo_id=>'160')
  dept_group_detail_arr.push(:group_busyo_id=>'201', :busyo_id=>'227')
  dept_group_detail_arr.push(:group_busyo_id=>'201', :busyo_id=>'228')
  dept_group_detail_arr.push(:group_busyo_id=>'201', :busyo_id=>'229')
  dept_group_detail_arr.push(:group_busyo_id=>'202', :busyo_id=>'161')
  dept_group_detail_arr.push(:group_busyo_id=>'202', :busyo_id=>'162')
  dept_group_detail_arr.push(:group_busyo_id=>'202', :busyo_id=>'163')
  dept_group_detail_arr.push(:group_busyo_id=>'202', :busyo_id=>'164')
  dept_group_detail_arr.push(:group_busyo_id=>'202', :busyo_id=>'165')
  dept_group_detail_arr.push(:group_busyo_id=>'202', :busyo_id=>'166')
  dept_group_detail_arr.push(:group_busyo_id=>'202', :busyo_id=>'167')
  dept_group_detail_arr.push(:group_busyo_id=>'202', :busyo_id=>'168')
  dept_group_detail_arr.push(:group_busyo_id=>'202', :busyo_id=>'169')
  dept_group_detail_arr.push(:group_busyo_id=>'202', :busyo_id=>'170')
  dept_group_detail_arr.push(:group_busyo_id=>'203', :busyo_id=>'171')
  dept_group_detail_arr.push(:group_busyo_id=>'203', :busyo_id=>'172')
  dept_group_detail_arr.push(:group_busyo_id=>'203', :busyo_id=>'173')
  dept_group_detail_arr.push(:group_busyo_id=>'203', :busyo_id=>'174')
  dept_group_detail_arr.push(:group_busyo_id=>'203', :busyo_id=>'175')
  dept_group_detail_arr.push(:group_busyo_id=>'203', :busyo_id=>'176')
  dept_group_detail_arr.push(:group_busyo_id=>'204', :busyo_id=>'186')
  dept_group_detail_arr.push(:group_busyo_id=>'204', :busyo_id=>'207')
  dept_group_detail_arr.push(:group_busyo_id=>'204', :busyo_id=>'208')
  dept_group_detail_arr.push(:group_busyo_id=>'204', :busyo_id=>'223')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'141')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'142')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'143')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'144')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'145')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'146')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'147')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'148')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'151')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'152')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'153')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'154')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'155')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'156')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'159')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'160')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'161')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'162')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'163')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'164')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'165')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'166')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'167')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'168')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'169')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'170')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'171')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'172')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'173')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'174')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'175')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'176')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'177')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'178')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'179')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'180')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'181')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'182')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'183')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'184')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'185')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'186')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'187')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'209')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'227')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'228')
  dept_group_detail_arr.push(:group_busyo_id=>'205', :busyo_id=>'229')
  dept_group_detail_arr.push(:group_busyo_id=>'206', :busyo_id=>'161')
  dept_group_detail_arr.push(:group_busyo_id=>'206', :busyo_id=>'162')
  dept_group_detail_arr.push(:group_busyo_id=>'219', :busyo_id=>'209')
  dept_group_detail_arr.push(:group_busyo_id=>'220', :busyo_id=>'211')
  dept_group_detail_arr.push(:group_busyo_id=>'220', :busyo_id=>'225')
  dept_group_detail_arr.push(:group_busyo_id=>'221', :busyo_id=>'152')
  dept_group_detail_arr.push(:group_busyo_id=>'221', :busyo_id=>'153')
  dept_group_detail_arr.push(:group_busyo_id=>'221', :busyo_id=>'154')
  dept_group_detail_arr.push(:group_busyo_id=>'221', :busyo_id=>'155')
  dept_group_detail_arr.push(:group_busyo_id=>'221', :busyo_id=>'156')
  dept_group_detail_arr.push(:group_busyo_id=>'221', :busyo_id=>'159')
  dept_group_detail_arr.push(:group_busyo_id=>'221', :busyo_id=>'160')
  dept_group_detail_arr.push(:group_busyo_id=>'221', :busyo_id=>'161')
  dept_group_detail_arr.push(:group_busyo_id=>'221', :busyo_id=>'162')
  dept_group_detail_arr.push(:group_busyo_id=>'221', :busyo_id=>'163')
  dept_group_detail_arr.push(:group_busyo_id=>'221', :busyo_id=>'164')
  dept_group_detail_arr.push(:group_busyo_id=>'221', :busyo_id=>'165')
  dept_group_detail_arr.push(:group_busyo_id=>'221', :busyo_id=>'166')
  dept_group_detail_arr.push(:group_busyo_id=>'221', :busyo_id=>'167')
  dept_group_detail_arr.push(:group_busyo_id=>'221', :busyo_id=>'168')
  dept_group_detail_arr.push(:group_busyo_id=>'221', :busyo_id=>'169')
  dept_group_detail_arr.push(:group_busyo_id=>'221', :busyo_id=>'170')
  dept_group_detail_arr.push(:group_busyo_id=>'221', :busyo_id=>'171')
  dept_group_detail_arr.push(:group_busyo_id=>'221', :busyo_id=>'172')
  dept_group_detail_arr.push(:group_busyo_id=>'221', :busyo_id=>'173')
  dept_group_detail_arr.push(:group_busyo_id=>'221', :busyo_id=>'174')
  dept_group_detail_arr.push(:group_busyo_id=>'221', :busyo_id=>'175')
  dept_group_detail_arr.push(:group_busyo_id=>'221', :busyo_id=>'176')
  dept_group_detail_arr.push(:group_busyo_id=>'221', :busyo_id=>'227')
  dept_group_detail_arr.push(:group_busyo_id=>'221', :busyo_id=>'228')
  dept_group_detail_arr.push(:group_busyo_id=>'221', :busyo_id=>'229')
  dept_group_detail_arr.push(:group_busyo_id=>'222', :busyo_id=>'159')
  dept_group_detail_arr.push(:group_busyo_id=>'222', :busyo_id=>'169')
  dept_group_detail_arr.push(:group_busyo_id=>'222', :busyo_id=>'175')
  dept_group_detail_arr.push(:group_busyo_id=>'234', :busyo_id=>'145')
  dept_group_detail_arr.push(:group_busyo_id=>'234', :busyo_id=>'146')
  dept_group_detail_arr.push(:group_busyo_id=>'235', :busyo_id=>'147')
  dept_group_detail_arr.push(:group_busyo_id=>'235', :busyo_id=>'148')
  dept_group_detail_arr.push(:group_busyo_id=>'236', :busyo_id=>'152')
  dept_group_detail_arr.push(:group_busyo_id=>'236', :busyo_id=>'153')
  dept_group_detail_arr.push(:group_busyo_id=>'236', :busyo_id=>'154')
  dept_group_detail_arr.push(:group_busyo_id=>'236', :busyo_id=>'259')
  dept_group_detail_arr.push(:group_busyo_id=>'237', :busyo_id=>'155')
  dept_group_detail_arr.push(:group_busyo_id=>'237', :busyo_id=>'156')
  dept_group_detail_arr.push(:group_busyo_id=>'237', :busyo_id=>'260')
  dept_group_detail_arr.push(:group_busyo_id=>'238', :busyo_id=>'227')
  dept_group_detail_arr.push(:group_busyo_id=>'238', :busyo_id=>'228')
  dept_group_detail_arr.push(:group_busyo_id=>'238', :busyo_id=>'229')
  dept_group_detail_arr.push(:group_busyo_id=>'238', :busyo_id=>'261')
  dept_group_detail_arr.push(:group_busyo_id=>'239', :busyo_id=>'163')
  dept_group_detail_arr.push(:group_busyo_id=>'239', :busyo_id=>'164')
  dept_group_detail_arr.push(:group_busyo_id=>'239', :busyo_id=>'165')
  dept_group_detail_arr.push(:group_busyo_id=>'239', :busyo_id=>'263')
  dept_group_detail_arr.push(:group_busyo_id=>'240', :busyo_id=>'166')
  dept_group_detail_arr.push(:group_busyo_id=>'240', :busyo_id=>'167')
  dept_group_detail_arr.push(:group_busyo_id=>'240', :busyo_id=>'168')
  dept_group_detail_arr.push(:group_busyo_id=>'240', :busyo_id=>'264')
  dept_group_detail_arr.push(:group_busyo_id=>'241', :busyo_id=>'171')
  dept_group_detail_arr.push(:group_busyo_id=>'241', :busyo_id=>'172')
  dept_group_detail_arr.push(:group_busyo_id=>'241', :busyo_id=>'265')
  dept_group_detail_arr.push(:group_busyo_id=>'242', :busyo_id=>'173')
  dept_group_detail_arr.push(:group_busyo_id=>'242', :busyo_id=>'174')
  dept_group_detail_arr.push(:group_busyo_id=>'242', :busyo_id=>'266')
  dept_group_detail_arr.push(:group_busyo_id=>'243', :busyo_id=>'181')
  dept_group_detail_arr.push(:group_busyo_id=>'243', :busyo_id=>'209')
  dept_group_detail_arr.push(:group_busyo_id=>'243', :busyo_id=>'224')
  dept_group_detail_arr.push(:group_busyo_id=>'244', :busyo_id=>'211')
  dept_group_detail_arr.push(:group_busyo_id=>'244', :busyo_id=>'218')
  dept_group_detail_arr.push(:group_busyo_id=>'245', :busyo_id=>'152')
  dept_group_detail_arr.push(:group_busyo_id=>'245', :busyo_id=>'153')
  dept_group_detail_arr.push(:group_busyo_id=>'245', :busyo_id=>'154')
  dept_group_detail_arr.push(:group_busyo_id=>'245', :busyo_id=>'155')
  dept_group_detail_arr.push(:group_busyo_id=>'245', :busyo_id=>'156')
  dept_group_detail_arr.push(:group_busyo_id=>'245', :busyo_id=>'159')
  dept_group_detail_arr.push(:group_busyo_id=>'245', :busyo_id=>'160')
  dept_group_detail_arr.push(:group_busyo_id=>'245', :busyo_id=>'227')
  dept_group_detail_arr.push(:group_busyo_id=>'245', :busyo_id=>'228')
  dept_group_detail_arr.push(:group_busyo_id=>'245', :busyo_id=>'229')
  dept_group_detail_arr.push(:group_busyo_id=>'245', :busyo_id=>'230')
  dept_group_detail_arr.push(:group_busyo_id=>'245', :busyo_id=>'255')
  dept_group_detail_arr.push(:group_busyo_id=>'245', :busyo_id=>'259')
  dept_group_detail_arr.push(:group_busyo_id=>'245', :busyo_id=>'260')
  dept_group_detail_arr.push(:group_busyo_id=>'245', :busyo_id=>'261')
  dept_group_detail_arr.push(:group_busyo_id=>'245', :busyo_id=>'293')
  dept_group_detail_arr.push(:group_busyo_id=>'246', :busyo_id=>'161')
  dept_group_detail_arr.push(:group_busyo_id=>'246', :busyo_id=>'162')
  dept_group_detail_arr.push(:group_busyo_id=>'246', :busyo_id=>'163')
  dept_group_detail_arr.push(:group_busyo_id=>'246', :busyo_id=>'164')
  dept_group_detail_arr.push(:group_busyo_id=>'246', :busyo_id=>'165')
  dept_group_detail_arr.push(:group_busyo_id=>'246', :busyo_id=>'166')
  dept_group_detail_arr.push(:group_busyo_id=>'246', :busyo_id=>'167')
  dept_group_detail_arr.push(:group_busyo_id=>'246', :busyo_id=>'168')
  dept_group_detail_arr.push(:group_busyo_id=>'246', :busyo_id=>'169')
  dept_group_detail_arr.push(:group_busyo_id=>'246', :busyo_id=>'170')
  dept_group_detail_arr.push(:group_busyo_id=>'246', :busyo_id=>'231')
  dept_group_detail_arr.push(:group_busyo_id=>'246', :busyo_id=>'256')
  dept_group_detail_arr.push(:group_busyo_id=>'246', :busyo_id=>'262')
  dept_group_detail_arr.push(:group_busyo_id=>'246', :busyo_id=>'263')
  dept_group_detail_arr.push(:group_busyo_id=>'246', :busyo_id=>'264')
  dept_group_detail_arr.push(:group_busyo_id=>'246', :busyo_id=>'289')
  dept_group_detail_arr.push(:group_busyo_id=>'246', :busyo_id=>'290')
  dept_group_detail_arr.push(:group_busyo_id=>'246', :busyo_id=>'294')
  dept_group_detail_arr.push(:group_busyo_id=>'246', :busyo_id=>'302')
  dept_group_detail_arr.push(:group_busyo_id=>'247', :busyo_id=>'171')
  dept_group_detail_arr.push(:group_busyo_id=>'247', :busyo_id=>'172')
  dept_group_detail_arr.push(:group_busyo_id=>'247', :busyo_id=>'173')
  dept_group_detail_arr.push(:group_busyo_id=>'247', :busyo_id=>'174')
  dept_group_detail_arr.push(:group_busyo_id=>'247', :busyo_id=>'175')
  dept_group_detail_arr.push(:group_busyo_id=>'247', :busyo_id=>'176')
  dept_group_detail_arr.push(:group_busyo_id=>'247', :busyo_id=>'232')
  dept_group_detail_arr.push(:group_busyo_id=>'247', :busyo_id=>'257')
  dept_group_detail_arr.push(:group_busyo_id=>'247', :busyo_id=>'265')
  dept_group_detail_arr.push(:group_busyo_id=>'247', :busyo_id=>'266')
  dept_group_detail_arr.push(:group_busyo_id=>'247', :busyo_id=>'295')
  dept_group_detail_arr.push(:group_busyo_id=>'248', :busyo_id=>'185')
  dept_group_detail_arr.push(:group_busyo_id=>'248', :busyo_id=>'186')
  dept_group_detail_arr.push(:group_busyo_id=>'248', :busyo_id=>'207')
  dept_group_detail_arr.push(:group_busyo_id=>'248', :busyo_id=>'208')
  dept_group_detail_arr.push(:group_busyo_id=>'248', :busyo_id=>'223')
  dept_group_detail_arr.push(:group_busyo_id=>'248', :busyo_id=>'287')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'141')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'142')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'143')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'144')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'145')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'146')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'147')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'148')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'151')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'152')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'153')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'154')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'155')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'156')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'159')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'160')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'161')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'162')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'163')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'164')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'165')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'166')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'167')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'168')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'169')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'170')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'171')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'172')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'173')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'174')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'175')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'176')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'177')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'178')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'179')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'180')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'181')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'182')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'183')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'184')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'185')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'186')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'187')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'209')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'227')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'228')
  dept_group_detail_arr.push(:group_busyo_id=>'249', :busyo_id=>'229')
  dept_group_detail_arr.push(:group_busyo_id=>'250', :busyo_id=>'161')
  dept_group_detail_arr.push(:group_busyo_id=>'250', :busyo_id=>'162')
  dept_group_detail_arr.push(:group_busyo_id=>'250', :busyo_id=>'262')
  dept_group_detail_arr.push(:group_busyo_id=>'252', :busyo_id=>'211')
  dept_group_detail_arr.push(:group_busyo_id=>'252', :busyo_id=>'225')
  dept_group_detail_arr.push(:group_busyo_id=>'253', :busyo_id=>'152')
  dept_group_detail_arr.push(:group_busyo_id=>'253', :busyo_id=>'153')
  dept_group_detail_arr.push(:group_busyo_id=>'253', :busyo_id=>'154')
  dept_group_detail_arr.push(:group_busyo_id=>'253', :busyo_id=>'155')
  dept_group_detail_arr.push(:group_busyo_id=>'253', :busyo_id=>'156')
  dept_group_detail_arr.push(:group_busyo_id=>'253', :busyo_id=>'159')
  dept_group_detail_arr.push(:group_busyo_id=>'253', :busyo_id=>'160')
  dept_group_detail_arr.push(:group_busyo_id=>'253', :busyo_id=>'161')
  dept_group_detail_arr.push(:group_busyo_id=>'253', :busyo_id=>'162')
  dept_group_detail_arr.push(:group_busyo_id=>'253', :busyo_id=>'163')
  dept_group_detail_arr.push(:group_busyo_id=>'253', :busyo_id=>'164')
  dept_group_detail_arr.push(:group_busyo_id=>'253', :busyo_id=>'165')
  dept_group_detail_arr.push(:group_busyo_id=>'253', :busyo_id=>'166')
  dept_group_detail_arr.push(:group_busyo_id=>'253', :busyo_id=>'167')
  dept_group_detail_arr.push(:group_busyo_id=>'253', :busyo_id=>'168')
  dept_group_detail_arr.push(:group_busyo_id=>'253', :busyo_id=>'169')
  dept_group_detail_arr.push(:group_busyo_id=>'253', :busyo_id=>'170')
  dept_group_detail_arr.push(:group_busyo_id=>'253', :busyo_id=>'171')
  dept_group_detail_arr.push(:group_busyo_id=>'253', :busyo_id=>'172')
  dept_group_detail_arr.push(:group_busyo_id=>'253', :busyo_id=>'173')
  dept_group_detail_arr.push(:group_busyo_id=>'253', :busyo_id=>'174')
  dept_group_detail_arr.push(:group_busyo_id=>'253', :busyo_id=>'175')
  dept_group_detail_arr.push(:group_busyo_id=>'253', :busyo_id=>'176')
  dept_group_detail_arr.push(:group_busyo_id=>'253', :busyo_id=>'227')
  dept_group_detail_arr.push(:group_busyo_id=>'253', :busyo_id=>'228')
  dept_group_detail_arr.push(:group_busyo_id=>'253', :busyo_id=>'229')
  dept_group_detail_arr.push(:group_busyo_id=>'253', :busyo_id=>'230')
  dept_group_detail_arr.push(:group_busyo_id=>'253', :busyo_id=>'231')
  dept_group_detail_arr.push(:group_busyo_id=>'253', :busyo_id=>'232')
  dept_group_detail_arr.push(:group_busyo_id=>'254', :busyo_id=>'159')
  dept_group_detail_arr.push(:group_busyo_id=>'254', :busyo_id=>'169')
  dept_group_detail_arr.push(:group_busyo_id=>'254', :busyo_id=>'175')
  dept_group_detail_arr.push(:group_busyo_id=>'269', :busyo_id=>'211')
  dept_group_detail_arr.push(:group_busyo_id=>'269', :busyo_id=>'225')
  dept_group_detail_arr.push(:group_busyo_id=>'269', :busyo_id=>'258')
  dept_group_detail_arr.push(:group_busyo_id=>'277', :busyo_id=>'164')
  dept_group_detail_arr.push(:group_busyo_id=>'277', :busyo_id=>'165')
  dept_group_detail_arr.push(:group_busyo_id=>'277', :busyo_id=>'263')
  dept_group_detail_arr.push(:group_busyo_id=>'279', :busyo_id=>'161')
  dept_group_detail_arr.push(:group_busyo_id=>'279', :busyo_id=>'162')
  dept_group_detail_arr.push(:group_busyo_id=>'279', :busyo_id=>'163')
  dept_group_detail_arr.push(:group_busyo_id=>'279', :busyo_id=>'262')
  dept_group_detail_arr.push(:group_busyo_id=>'296', :busyo_id=>'152')
  dept_group_detail_arr.push(:group_busyo_id=>'296', :busyo_id=>'153')
  dept_group_detail_arr.push(:group_busyo_id=>'296', :busyo_id=>'154')
  dept_group_detail_arr.push(:group_busyo_id=>'296', :busyo_id=>'155')
  dept_group_detail_arr.push(:group_busyo_id=>'296', :busyo_id=>'259')
  dept_group_detail_arr.push(:group_busyo_id=>'297', :busyo_id=>'156')
  dept_group_detail_arr.push(:group_busyo_id=>'297', :busyo_id=>'227')
  dept_group_detail_arr.push(:group_busyo_id=>'297', :busyo_id=>'228')
  dept_group_detail_arr.push(:group_busyo_id=>'297', :busyo_id=>'229')
  dept_group_detail_arr.push(:group_busyo_id=>'297', :busyo_id=>'261')
  dept_group_detail_arr.push(:group_busyo_id=>'299', :busyo_id=>'161')
  dept_group_detail_arr.push(:group_busyo_id=>'299', :busyo_id=>'162')
  dept_group_detail_arr.push(:group_busyo_id=>'299', :busyo_id=>'164')
  dept_group_detail_arr.push(:group_busyo_id=>'299', :busyo_id=>'165')
  dept_group_detail_arr.push(:group_busyo_id=>'299', :busyo_id=>'263')
  dept_group_detail_arr.push(:group_busyo_id=>'299', :busyo_id=>'302')
  dept_group_detail_arr.push(:group_busyo_id=>'300', :busyo_id=>'163')
  dept_group_detail_arr.push(:group_busyo_id=>'300', :busyo_id=>'166')
  dept_group_detail_arr.push(:group_busyo_id=>'300', :busyo_id=>'167')
  dept_group_detail_arr.push(:group_busyo_id=>'300', :busyo_id=>'168')
  dept_group_detail_arr.push(:group_busyo_id=>'300', :busyo_id=>'264')
  dept_group_detail_arr.push(:group_busyo_id=>'301', :busyo_id=>'171')
  dept_group_detail_arr.push(:group_busyo_id=>'301', :busyo_id=>'172')
  dept_group_detail_arr.push(:group_busyo_id=>'301', :busyo_id=>'173')
  dept_group_detail_arr.push(:group_busyo_id=>'301', :busyo_id=>'174')
  dept_group_detail_arr.push(:group_busyo_id=>'301', :busyo_id=>'304')


  DeptGroupDetail.delete_all
  dept_group_detail_arr.each do |obj|
    # グループ部署を取得する
    dept_group = DeptGroup.find_by_busyo_id(obj[:group_busyo_id])
    if dept_group
      p dept_group
      dept = Dept.find_by_busyo_id(obj[:busyo_id])
      if dept
        dept_group_detail = DeptGroupDetail.new
        dept_group_detail.dept_group_id = dept_group.id
        dept_group_detail.dept_id = dept.id

        dept_group_detail.save!
      end
    end
  end
end

# 月次情報登録
def monthly_regist(filename)
  # ファイル存在チェック
  unless File.exist?(filename)
    puts 'file not exist'
    return false
  end

  # データを登録
  cnt = 0
  open(filename).each do |line|
    catch :not_header do

      if cnt == 0
        cnt = cnt + 1
        throw :not_header
      end

      cnt = cnt + 1
      row = line.split(",")

      #dept_id
      dept = Dept.find_by_busyo_id(row[0])
      unless dept
        p "skip dept " + row[0]
        throw :not_header
      end

      # item_id
      item = Item.find_by_code(row[1])
      unless item
        p "skip item " + row[1]
        throw :not_header
      end

      month = MonthlyStatement.find_or_create_by_dept_id_and_item_id_and_yyyymm(dept.id, item.id, row[2])
      month.dept_id = dept.id
      month.item_id = item.id
      month.yyyymm = row[2]
      month.plan_value = row[3]
      month.result_value = row[4]
      month.save!

      p sprintf("%05d", cnt)  + ' ' + month.dept.name + ' ' + month.item.name + ' ' + month.yyyymm + ' ' + month.plan_value.to_s + '/' + month.result_value.to_s
    end
  end

end


# 空日数の情報を登録する
def regist_vacant_room(yyyymm, filename)

  # 本来は最初にYYYYMMで削除するべきかもしれないが
  # データを消してしまい、登録データに失敗すると永遠にそれが失われてしまうので
  # データを消させないで、もし既存のデータが登録されている時は、手動で削除させる。

  tmp = VacantRoom.find_all_by_yyyymm(yyyymm)
  if tmp.length > 0
    p yyyymm + 'の空日数情報はすでに登録されています。削除してから実行してください。'
    return
  end

  unless File.exist?(filename)
    puts 'file not exist'
    return false
  end

  # データを登録
  cnt = 0
  open(filename).each do |line|
    catch :not_header do

      if cnt == 0
        cnt = cnt + 1
        throw :not_header
      end

      row = line.split(",")

      # shop_id
      shop = Shop.find_by_code(row[0])
      unless shop
        p "skip shop " + row[0]
        throw :not_header
      end

      # building_id
      building = Building.find_by_code(row[9])
      unless building
        p "skip building " + row[9]
        throw :not_header
      end

      # room_id
      room = Room.find_by_building_cd_and_code(row[9], row[11])
      unless room
        p "skip room " + row[9] + ' ' + row[11]
        throw :not_header
      end

      # TODO:空室一覧で管理方式コードも取るようにする。
      # TODO:間取り別の空室数も確認できるようにする。
      manage_type = ManageType.find_by_code(row[15])
      unless manage_type
        p "skip manage_type " + row[15]
        throw :not_header
      end

      room_layout = RoomLayout.find_by_code(row[13])
      unless room_layout
        p "skip room_layout " + row[13]
        throw :not_header
      end

      vacant_room = VacantRoom.find_or_create_by_yyyymm_and_room_id(yyyymm, room.id)
      vacant_room.yyyymm = yyyymm
      vacant_room.room_id = room.id
      vacant_room.shop_id = shop.id
      vacant_room.building_id = building.id
      vacant_room.manage_type_id = manage_type.id
      vacant_room.room_layout_id = room_layout.id
      vacant_room.vacant_start_day = row[4]
      vacant_room.vacant_cnt = row[5]
      vacant_room.save!

      p vacant_room.building.name + ' ' + vacant_room.room.name + ' ' + vacant_room.vacant_cnt.to_s + '日'
      cnt = cnt + 1

    end
  end
end

# 賃貸借契約を登録する
def regist_lease_contract(filename)

  unless File.exist?(filename)
    puts 'file not exist'
    return false
  end

  # データを登録
  cnt = 0
  open(filename).each do |line|
    catch :not_header do

      if cnt == 0
        cnt = cnt + 1
        throw :not_header
      end

      row = line.split(",")

      #建物の取得
      build = Building.find_by_code(row[1])
      unless build
        p "skip build " + row[1]
        throw :not_header
      end

      #部屋の取得
      room = Room.find_by_building_cd_and_code(row[1], row[2])
      unless room
        p "skip room " + row[1]
        throw :not_header
      end

      lease_contract = LeaseContract.find_or_create_by_code(row[0])
      lease_contract.code = row[0]
      lease_contract.start_date = row[3]
      lease_contract.leave_date = row[4]
      lease_contract.building_id = build.id
      lease_contract.room_id = room.id
      lease_contract.lease_month = row[12]
      lease_contract.rent = row[9]
      lease_contract.save!

      p lease_contract.building.name + ' ' + lease_contract.room.name + ' ' + lease_contract.lease_month.to_s + 'ヶ月'
      cnt = cnt + 1

    end
  end
end


# レンターズデータのアップデートをする。
def create_work_renters_rooms
	
    batch_cd = Time.now.strftime('%Y%m%d%H%M%S')
    
    get_cnt = 50
    start_idx = 1
    
    loop do
      
      url = URI.parse("http://api.rentersnet.jp/room/?key=136MAyXy&count=#{get_cnt.to_s}&start=#{start_idx.to_s}&vacant_div=3,4&torihiki_mode=1,2,3,4")
      xml = open(url).read
      doc = REXML::Document.new(xml)
      
      # １件も取得できなかったら終了
      ret_status = doc.elements['results/results_returned']
      break unless ret_status
      break if ret_status.text == "0"

      # 次の取得の準備
      start_idx = start_idx + get_cnt
      
      #break if start_idx > 100
      
      # 配列がなくなるまで建物・部屋を作成
      doc.elements.each_with_index('results/room') do |room, i|
        p room.elements['room_cd'].text
        
        # レンターズ 部屋情報の取得
        work_renters_room = WorkRentersRoom.create
        work_renters_room.batch_cd = batch_cd
        work_renters_room.batch_cd_idx = start_idx + i
        work_renters_room.room_cd = room.elements['room_cd'].text if room.elements['room_cd']
        work_renters_room.building_cd = room.elements['building_cd'].text if room.elements['building_cd']
        work_renters_room.clientcorp_room_cd = room.elements['clientcorp_room_cd'].text if room.elements['clientcorp_room_cd']
        work_renters_room.clientcorp_building_cd = room.elements['clientcorp_building_cd'].text if room.elements['clientcorp_building_cd']
        work_renters_room.store_code = room.elements['store/code'].text if room.elements['store/code']
        work_renters_room.store_name = room.elements['store/name'].text if room.elements['store/name']
        work_renters_room.building_name = room.elements['building_name'].text if room.elements['building_name']
        work_renters_room.gaikugoutou = room.elements['gaikugoutou'].text if room.elements['gaikugoutou']
        work_renters_room.room_no = room.elements['room_no'].text if room.elements['room_no']
        work_renters_room.real_building_name = room.elements['real_building_name'].text if room.elements['real_building_name']
        work_renters_room.real_gaikugoutou = room.elements['real_gaikugoutou'].text if room.elements['real_gaikugoutou']
        work_renters_room.real_room_no = room.elements['real_room_no'].text if room.elements['real_room_no']
        work_renters_room.floor = room.elements['floor'].text if room.elements['floor']
        work_renters_room.building_type = room.elements['building_type'].text if room.elements['building_type']
        work_renters_room.structure = room.elements['structure'].text if room.elements['structure']
        work_renters_room.construction = room.elements['construction'].text if room.elements['construction']
        work_renters_room.room_num = room.elements['room_num'].text if room.elements['room_num']
        work_renters_room.address = room.elements['address'].text if room.elements['address']
        work_renters_room.detail_address = room.elements['detail_address'].text if room.elements['detail_address']
        work_renters_room.pref_code = room.elements['pref/code'].text if room.elements['pref/code']
        work_renters_room.pref_name = room.elements['pref/name'].text if room.elements['pref/name']
        work_renters_room.city_code = room.elements['city/code'].text if room.elements['city/code']
        work_renters_room.city_name = room.elements['city/name'].text if room.elements['city/name']
        work_renters_room.choume_code = room.elements['choume/code'].text if room.elements['choume/code']
        work_renters_room.choume_name = room.elements['choume/name'].text if room.elements['choume/name']
        work_renters_room.latitude = room.elements['latitude'].text if room.elements['latitude']
        work_renters_room.longitude = room.elements['longitude'].text if room.elements['longitude']
        work_renters_room.vacant_div = room.elements['vacant_div'].text if room.elements['vacant_div']
        work_renters_room.enter_ym = room.elements['enter_ym'].text if room.elements['enter_ym']
        work_renters_room.new_status = room.elements['new_status'].text if room.elements['new_status']
        work_renters_room.completion_ym = room.elements['completion_ym'].text if room.elements['completion_ym']
        work_renters_room.square = room.elements['square'].text if room.elements['square']
        work_renters_room.room_layout_type = room.elements['room_layout_type'].text if room.elements['room_layout_type']
#        work_renters_room.        #renters_room.work_renters_room_layout_id = room.elements['#renters_room.work_renters_room_layout_id'].text if room.elements['#renters_room.layout_id']
#        work_renters_room.        #renters_room.work_renters_access_id = room.elements['#renters_room.work_renters_access_id'].text if room.elements['#renters_room.work_renters_access_id']
        work_renters_room.cond = room.elements['cond'].text if room.elements['cond']
        work_renters_room.contract_div = room.elements['contract_div'].text if room.elements['contract_div']
        work_renters_room.contract_comment = room.elements['contract_comment'].text if room.elements['contract_comment']
        work_renters_room.rent_amount = room.elements['rent_amount'].text if room.elements['rent_amount']
        work_renters_room.managing_fee = room.elements['managing_fee'].text if room.elements['managing_fee']
        work_renters_room.reikin = room.elements['reikin'].text if room.elements['reikin']
        work_renters_room.shikihiki = room.elements['shikihiki'].text if room.elements['shikihiki']
        work_renters_room.shikikin = room.elements['shikikin'].text if room.elements['shikikin']
        work_renters_room.shoukyakukin = room.elements['shoukyakukin'].text if room.elements['shoukyakukin']
        work_renters_room.hoshoukin = room.elements['hoshoukin'].text if room.elements['hoshoukin']
        work_renters_room.renewal_fee = room.elements['renewal_fee'].text if room.elements['renewal_fee']
        work_renters_room.insurance = room.elements['insurance'].text if room.elements['insurance']
        work_renters_room.agent_fee = room.elements['agent_fee'].text if room.elements['agent_fee']
        work_renters_room.other_fee = room.elements['other_fee'].text if room.elements['other_fee']
        work_renters_room.airconditioner = room.elements['airconditioner'].text if room.elements['airconditioner']
        work_renters_room.washer_space = room.elements['washer_space'].text if room.elements['washer_space']
        work_renters_room.burner = room.elements['burner'].text if room.elements['burner']
        work_renters_room.equipment = room.elements['equipment'].text if room.elements['equipment']
        work_renters_room.carpark_status = room.elements['carpark/status'].text if room.elements['carpark/status']
        work_renters_room.carpark_fee = room.elements['carpark/carpark_fee'].text if room.elements['carpark/carpark_fee']
        work_renters_room.carpark_reikin = room.elements['carpark/reikin'].text if room.elements['carpark/reikin']
        work_renters_room.carpark_shikikin = room.elements['carpark/shikikin'].text if room.elements['carpark/shikikin']
        work_renters_room.carpark_distance_to_nearby = room.elements['carpark/distance_to_nearby'].text if room.elements['carpark/distance_to_nearby']
        work_renters_room.carpark_car_num = room.elements['carpark/car_num'].text if room.elements['carpark/car_num']
        work_renters_room.carpark_indoor = room.elements['carpark/indoor'].text if room.elements['carpark/indoor']
        work_renters_room.carpark_shape = room.elements['carpark/shape'].text if room.elements['carpark/shape']
        work_renters_room.carpark_underground = room.elements['carpark/underground'].text if room.elements['carpark/underground']
        work_renters_room.carpark_roof = room.elements['carpark/roof'].text if room.elements['carpark/roof']
        work_renters_room.carpark_shutter = room.elements['carpark/shutter'].text if room.elements['carpark/shutter']
        
        # tmo_notice = ""
        # tmo_notice = tmo_notice + ' / ' + room.elements['notice[1]'].text if room.elements['notice[1]']
        # tmo_notice = tmo_notice + ' / ' + room.elements['notice[2]'].text if room.elements['notice[2]']
        # tmo_notice = tmo_notice + ' / ' + room.elements['notice[3]'].text if room.elements['notice[3]']
        # tmo_notice = tmo_notice + ' / ' + room.elements['notice[4]'].text if room.elements['notice[4]']
        # tmo_notice = tmo_notice + ' / ' + room.elements['notice[5]'].text if room.elements['notice[5]']
        # tmo_notice = tmo_notice + ' / ' + room.elements['notice[6]'].text if room.elements['notice[6]']
        # work_renters_room.notice =  tmo_notice
        
        work_renters_room.notice_a = room.elements['notice[1]'].text if room.elements['notice[1]']
        work_renters_room.notice_b = room.elements['notice[2]'].text if room.elements['notice[2]']
        work_renters_room.notice_c = room.elements['notice[3]'].text if room.elements['notice[3]']
        work_renters_room.notice_d = room.elements['notice[4]'].text if room.elements['notice[4]']
        work_renters_room.notice_e = room.elements['notice[5]'].text if room.elements['notice[5]']
        work_renters_room.notice_f = room.elements['notice[6]'].text if room.elements['notice[6]']
        
        work_renters_room.building_main_catch = room.elements['building_main_catch'].text if room.elements['building_main_catch']
        work_renters_room.room_main_catch = room.elements['room_main_catch'].text if room.elements['room_main_catch']
        work_renters_room.recruit_catch = room.elements['recruit_catch'].text if room.elements['recruit_catch']
        work_renters_room.room_updated_at = room.elements['room_updated_at'].text if room.elements['room_updated_at']
#        work_renters_room.        #renters_room.work_renters_picture_id = room.elements['#renters_room.work_renters_picture_id'].text if room.elements['#renters_room.work_renters_picture_id']
        work_renters_room.zumen_url = room.elements['zumen_url'].text if room.elements['zumen_url']
        work_renters_room.location = room.elements['location'].text if room.elements['location']
        work_renters_room.net_use_freecomment = room.elements['net_use_freecomment'].text if room.elements['net_use_freecomment']
        work_renters_room.athome_pro_comment = room.elements['athome_pro_comment'].text if room.elements['athome_pro_comment']
    
        work_renters_room.save!

        # # 画像を登録

        picture_num = 0
        room.elements.each_with_index('picture') do |pic, i|
          room_picture = WorkRentersRoomPicture.create
          room_picture.batch_cd = batch_cd
          room_picture.batch_cd_idx = work_renters_room.batch_cd_idx
          room_picture.room_cd = work_renters_room.room_cd
          room_picture.batch_picture_idx = i
          
          room_picture.true_url = pic.elements['true_url'].text
          room_picture.large_url = pic.elements['large_url'].text
          room_picture.mini_url = pic.elements['mini_url'].text
          
          room_picture.sub_category_code = pic.elements['sub_category/code'].text
          room_picture.sub_category_name = pic.elements['sub_category/name'].text
          room_picture.caption = pic.elements['caption'].text
          room_picture.priority = pic.elements['priority'].text

          #room_picture.delete_flg = false
          room_picture.save!

          picture_num = picture_num + 1
        end
        
        if work_renters_room.building_name
          p work_renters_room.building_name + ' ' + picture_num.to_s + "枚登録"
        end

        # 画像の枚数を保存
        # renters_room.picture_num = picture_num
        # renters_room.save!
        #
        # if renters_room.building_name
        #   p renters_room.building_name + ' ' + picture_num.to_s + "枚登録"
        # end

      end
    end    
    
	  p "バッチコード" + batch_cd
	
end

# 定期メンテナンスを登録します。
def regist_trust_maintenance_all(filename)
  
  # ファイルの存在チェック
  unless File.exist?(filename)
    puts 'file not exist'
    return false
  end
  
  # 削除フラグをたてる
  TrustMaintenance.unscoped.update_all(:delete_flg => true )
  cnt = 0
  unknown_cnt = 0
  
  # 委託の定期メンテナンスの登録
  open(filename).each do |line|
    catch :not_header do

      if cnt == 0
        cnt = cnt + 1
        throw :not_header
      end

      row = line.split(",")

      # 委託契約の取得
      trust = Trust.find_by_code(row[0])
      unless trust
        p "不明な委託契約が指定されました。 コード：" + row[0] 
        unknown_cnt = unknown_cnt + 1
        throw :not_header
      end
      
      trust_maintenance = TrustMaintenance.unscoped.find_by_trust_id_and_idx(trust.id, row[1])
      unless trust_maintenance
        # 最初に登録するときは新規作成
        trust_maintenance = TrustMaintenance.create
      end
      
      trust_maintenance.trust_id = trust.id
      trust_maintenance.idx = row[1]
      trust_maintenance.code = row[2]
      trust_maintenance.name = row[3]
      trust_maintenance.price = row[4]
      trust_maintenance.delete_flg = false
      
      trust_maintenance.save!
      p trust_maintenance.code + ' ' + trust_maintenance.name
      cnt = cnt + 1
    end
  end  
  
  p "出力結果:登録：" + cnt.to_s + '　不明：' + unknown_cnt.to_s + '件'

end


########################
# マスタ登録
########################

# 駅マスタ登録
#init_station

# 営業所登録
#init_shop

# 物件種別登録
#init_biru_type('/biruweb')

# 管理方式登録
#init_manage_type('/biruweb')

# 部屋種別登録
#init_room_type

# 部屋間取登録
#init_room_layout

# アプローチ種別登録
#init_approach_kind

# アタックステータス登録
#init_attack_state

# システムアップデート管理
#init_data_update

# 社員マスタ登録
#init_biru_user

########################
# 地図管理物件登録
########################

# データの登録(自社)
# regist_oneself(Rails.root.join( "tmp", "imp_data_20140208.csv"))
# regist_oneself(Rails.root.join( "tmp", "imp_data_20140312.csv"))
# regist_oneself(Rails.root.join( "tmp", "imp_data_20140529.csv"))
# regist_oneself(Rails.root.join( "tmp", "imp_data_20140628.csv"))
# regist_oneself(Rails.root.join( "tmp", "imp_data_20140707.csv"))
# regist_oneself(Rails.root.join( "tmp", "imp_data_20140720.csv"))
# regist_oneself(Rails.root.join( "tmp", "imp_data_20140820.csv"))
# regist_oneself(Rails.root.join( "tmp", "imp_data_20141020.csv"))
# regist_oneself(Rails.root.join( "tmp", "imp_data_20141120.csv"))
# regist_oneself(Rails.root.join( "tmp", "imp_data_20150120.csv"))
# regist_oneself(Rails.root.join( "tmp", "imp_data_20150320.csv"))


# データの登録(他社)
#import_data_yourself_owner(Rails.root.join( "tmp", "attack_02_sinden.csv"))
#import_data_yourself_owner(Rails.root.join( "tmp", "attack_01_soka.csv"))

# データの登録(他社貸主）
# bulk_owner_regist(1, Rails.root.join( "tmp", "attack_kasi_20140623.csv"))

###########################
# アタックリストの登録
###########################

#reg_attack_owner_building('6365', '草加営業所', Rails.root.join( "tmp", "01_01_souka.csv")) # 草加 松本
#reg_attack_owner_building('6487', '草加新田営業所', Rails.root.join( "tmp", "01_02_shinden.csv")) # 草加新田　氏家
# reg_attack_owner_building('5952', '北千住営業所', Rails.root.join( "tmp", "01_02_kitasenju.csv")) # 北千住営業所　山口


#reg_attack_owner_building('6464', '南越谷営業所', Rails.root.join( "tmp", "01_04_minami_kosigaya.csv")) # 南越谷　猪原
#reg_attack_owner_building('6406', '越谷営業所', Rails.root.join( "tmp", "01_05_koshigaya.csv")) # 越谷　末吉
#reg_attack_owner_building('6425', '北越谷営業所', Rails.root.join( "tmp", "01_07_kitakoshigaya.csv")) # 北越谷　赤坂
#reg_attack_owner_building('6425', '北越谷営業所', Rails.root.join( "tmp", "akasaka_add.csv")) # 北越谷　赤坂


#reg_attack_owner_building('5684', 'せんげん台営業所', Rails.root.join( "tmp", "01_08_sengendai.csv")) # せんげん台　帰山

#reg_attack_owner_building('6461', '戸田公園営業所', Rails.root.join( "tmp", "02_01_todakoenn.csv")) # 戸田公園 中野主任
#reg_attack_owner_building('7844', '戸田営業所', Rails.root.join( "tmp", "02_02_toda.csv")) # 戸田　辻社員’
####reg_attack_owner_building('6338', '川口営業所', Rails.root.join( "tmp", "02_04_kawaguchi.csv")) # 川口営業所　鈴木

####reg_attack_owner_building('5313', '与野営業所', Rails.root.join( "tmp", "02_05_yono.csv")) # 与野営業所　宮川

#reg_attack_owner_building('5473', '東浦和営業所', Rails.root.join( "tmp", "02_07_higashi_urawa.csv")) # 東浦和 小泉主任
#reg_attack_owner_building('5841', '戸塚安行営業所', Rails.root.join( "tmp", "02_09_totukaangyo.csv")) # 戸塚安行 下地社員
#reg_attack_owner_building('5841', '戸塚安行営業所', Rails.root.join( "tmp", "02_09_totukaangyo_02.csv")) # 戸塚安行 下地社員



# 千葉支店 市橋主任
#reg_attack_owner_building('4917', '松戸営業所', Rails.root.join( "tmp", "03_01_matudo.csv"))
#reg_attack_owner_building('4917', '北松戸営業所', Rails.root.join( "tmp", "03_02_kitamatudo.csv"))
#reg_attack_owner_building('4917', '南流山営業所', Rails.root.join( "tmp", "03_03_minaminagareyama.csv"))
#reg_attack_owner_building('4917', '柏営業所', Rails.root.join( "tmp", "03_04_kasiwa.csv"))


###########################
# 業績分析(月次)
###########################

# 初期化処理
#performance_init

# 月次情報登録
#monthly_regist(Rails.root.join( "tmp", "monthley.csv"))
#monthly_regist(Rails.root.join( "tmp", "monthley_getuji_201403.csv"))
#monthly_regist(Rails.root.join( "tmp", "monthley_201402_201403.csv"))
#monthly_regist(Rails.root.join( "tmp", "monthley_201404_201405.csv"))
#monthly_regist(Rails.root.join( "tmp", "monthley_getuji_201406.csv"))
#monthly_regist(Rails.root.join( "tmp", "monthley_getuji_201407.csv"))
#monthly_regist(Rails.root.join( "tmp", "monthley_getuji_201408.csv"))
#monthly_regist(Rails.root.join( "tmp", "monthley_getuji_201409_201412.csv"))


# 来店客数／契約件数
#monthly_regist(Rails.root.join( "tmp", "monthley_raiten.csv"))
#monthly_regist(Rails.root.join( "tmp", "monthley_raiten_201405.csv"))
#monthly_regist(Rails.root.join( "tmp", "monthley_raiten_201406.csv"))
#monthly_regist(Rails.root.join( "tmp", "monthley_raiten_201407.csv"))
#monthly_regist(Rails.root.join( "tmp", "monthley_raiten_201408.csv"))
#monthly_regist(Rails.root.join( "tmp", "monthley_raiten_201409.csv"))
#monthly_regist(Rails.root.join( "tmp", "monthley_raiten_201410.csv"))
#monthly_regist(Rails.root.join( "tmp", "monthley_raiten_201411.csv"))
#monthly_regist(Rails.root.join( "tmp", "monthley_raiten_201412.csv"))
#monthly_regist(Rails.root.join( "tmp", "monthley_raiten_201501.csv"))
#monthly_regist(Rails.root.join( "tmp", "monthley_raiten_201502.csv"))
monthly_regist(Rails.root.join( "tmp", "monthley_raiten_201503.csv"))

###########################
# 業績分析(空室)
###########################
#regist_vacant_room("201401", Rails.root.join( "tmp", "vacant_201401.csv"))
#regist_vacant_room("201402", Rails.root.join( "tmp", "vacant_201402.csv"))
#regist_vacant_room("201403", Rails.root.join( "tmp", "vacant_201403.csv"))
#regist_vacant_room("201404", Rails.root.join( "tmp", "vacant_201404.csv"))
#regist_vacant_room("201405", Rails.root.join( "tmp", "vacant_201405.csv"))
#regist_vacant_room("201406", Rails.root.join( "tmp", "vacant_201406.csv"))
#regist_vacant_room("201407", Rails.root.join( "tmp", "vacant_201407.csv"))
#regist_vacant_room("201408", Rails.root.join( "tmp", "vacant_201408.csv"))
#regist_vacant_room("201409", Rails.root.join( "tmp", "vacant_201409.csv"))
#regist_vacant_room("201410", Rails.root.join( "tmp", "vacant_201410.csv"))
#regist_vacant_room("201411", Rails.root.join( "tmp", "vacant_201411.csv"))
#regist_vacant_room("201412", Rails.root.join( "tmp", "vacant_201412.csv"))
#regist_vacant_room("201501", Rails.root.join( "tmp", "vacant_201501.csv"))
#regist_vacant_room("201502", Rails.root.join( "tmp", "vacant_201502.csv"))
#regist_vacant_room("201503", Rails.root.join( "tmp", "vacant_201503.csv"))

###########################
# 賃貸借契約登録
###########################
#regist_lease_contract(Rails.root.join( "tmp", "imp_tikeiyaku_20140305.csv"))

###########################
# レンターズデータ取得
###########################
# create_work_renters_rooms

############################
# 定期メンテナンス登録
############################
#regist_trust_maintenance_all(Rails.root.join( "tmp", "trust_maintenance_20141117.csv"))
