class RoomLayout < ActiveRecord::Base
  attr_accessible :code, :name
  has_many :rooms


  # 検索条件をidに変換したものを、arrにpushします。
  def self.conv_param(param_code, arr)

    tmp_code = []

    case param_code
    when 5 # 1R
      tmp_code.push('18100')
    when 10 # 1K
      tmp_code.push('18105')
    when 11 # 1DK
      tmp_code.push('18110')
    when 12 # 1LDK
      tmp_code.push('18120')
      tmp_code.push('18125')
    when 20 # 2K
      tmp_code.push('18200')
    when 21 # 2DK
      tmp_code.push('18205')
      tmp_code.push('18210')
    when 22 # 2LDK
      tmp_code.push('18215')
      tmp_code.push('18220')
    when 30 # 3K
      tmp_code.push('18300')
      tmp_code.push('18311')
    when 31 # 3DK
      tmp_code.push('18305')
      tmp_code.push('18310')
    when 32 # 3LDK
      tmp_code.push('18315')
      tmp_code.push('18320')
    when 40 # 4K
      tmp_code.push('18400')

      tmp_code.push('18500')
      tmp_code.push('18511')

      tmp_code.push('18600')
      tmp_code.push('')
    when 41 # 4DK
      tmp_code.push('18405')
      tmp_code.push('18410')

      tmp_code.push('18505')
      tmp_code.push('18510')

      tmp_code.push('18605')
      tmp_code.push('18610')

      tmp_code.push('18705')

    when 42 # 4LDK
      tmp_code.push('18415')
      tmp_code.push('18420')

      tmp_code.push('18515')
      tmp_code.push('18520')

      tmp_code.push('18615')
      tmp_code.push('18620')
    else
    end

    # 配列にroom_layoutのidを登録
    tmp_code.each do |code|
      room_layout = RoomLayout.find_by_code(code)
      arr.push(room_layout.id) if room_layout
    end
    
  end

end

