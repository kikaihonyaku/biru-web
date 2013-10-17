class ImpTable < ActiveRecord::Base
  attr_accessible :siten_cd ,:eigyo_order,:eigyo_cd,:eigyo_nm,:kanri_cd,:kanri_nm,:trust_cd,:building_cd,:building_nm,:room_cd,:room_nm,:kanri_start_date,:kanri_end_date,:room_aki,:room_type_cd,:room_type_nm,:room_layout_cd,:room_layout_nm,:owner_cd,:owner_nm,:owner_kana,:owner_address,:owner_tel
end
